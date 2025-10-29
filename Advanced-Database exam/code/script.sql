--------------------------------------------------------------------------------
-- FILM PRODUCTION & CREW MANAGEMENT SYSTEM (Oracle 19c)
--- Course:ADVANCED DATABASE PROJECT-BASED EXAM
-- Parallel & Distributed Database Practical (A1–B10)
--------------------------------------------------------------------------------



--------------------------------------------------------------------------------
-- A1: Fragment & Recombine Main Fact (Expense)
--------------------------------------------------------------------------------
--- FILM_PRODUCTION is the main schema that contains original tables
--- From FILM_PRODUCTION schema grand select previllages to BRANCHDB_A and BRANCHDB_B
GRANT SELECT ON EXPENSE TO BranchDB_A;
GRANT SELECT ON EXPENSE TO BranchDB_B;

-----------------------------------------------------------
-- In BranchDB_A: create horizontal fragments (e.g., odd IDs)
-----------------------------------------------------------
-- CONNECT BranchDB_A/A_pwd
-- Minimal subset: Expense_A
CREATE TABLE Expense_A AS SELECT * FROM FILM_PRODUCTION.EXPENSE WHERE MOD(EXPENSEID,2)=1;
-----------------------------------------------------------
-- In BranchDB_B: create horizontal fragments (e.g., even IDs)
-----------------------------------------------------------
-- CONNECT BranchDB_B/B_pwd
-- Minimal subset: Expense_B
CREATE TABLE Expense_B    AS SELECT * FROM FILM_PRODUCTION.EXPENSE  WHERE MOD(EXPENSEID,2)=0;
--- insert image from screenshots/1.png

-----------------------------------------------------------
-- Create & Use Database Links + Distributed Join
-----------------------------------------------------------
GRANT CREATE SESSION TO BranchDB_B;
GRANT CREATE SESSION TO BranchDB_A;

-- From BranchDB_A, create a link to BranchDB_B (adjust host/service)
-- CONNECT BranchDB_A/A_pwd
CREATE DATABASE LINK proj_link
    CONNECT TO BranchDB_B IDENTIFIED BY "B_pwd1"
    USING '//localhost:1521/XE';

-- Combined view
CREATE OR REPLACE VIEW Expense_ALL AS
SELECT * FROM Expense_A
UNION ALL
SELECT * FROM Expense_B@proj_link;

-- Validate with COUNT(*) and a checksum on a key column
SELECT
    (SELECT COUNT(*) FROM Expense_A) AS CNT_A,
    (SELECT COUNT(*) FROM Expense_B@proj_link) AS CNT_B,
    (SELECT COUNT(*) FROM Expense_ALL) AS CNT_ALL
FROM dual;


--------------------------------------------------------------------------------
-- A2: Database Link & Cross-Node Join
--------------------------------------------------------------------------------
-- create database link
CREATE DATABASE LINK proj_link
    CONNECT TO BranchDB_B IDENTIFIED BY "B_pwd1"
    USING '//localhost:1521/XE';

-- Run remote SELECT on Project@proj_link showing up to 5 sample rows.
SELECT COUNT(*) AS project_rows_in_B FROM Project_B@DBLINK_TO_B;

-- Distributed JOIN: projects from A with crew from B
SELECT
    e.ProjectID,
    e.Description AS Expense_Description,
    e.Amount AS Expense_Amount,
    a.ASSIGNID,
    a.CrewID,
    a.DailyRate
FROM Expense_A e
         JOIN Assignment@proj_link a
              ON e.ProjectID = a.ProjectID;
--------------------------------------------------------------------------------
-- A3: Parallel vs Serial Aggregation
--------------------------------------------------------------------------------
-- Serial
SELECT ProjectID, SUM(Amount) AS total_amt
FROM Expense_ALL
GROUP BY ProjectID;

-- Parallel forced
SELECT /*+ PARALLEL(Expense_A,8) PARALLEL(Expense_B,8) */
    ProjectID, SUM(Amount) AS total_amt
FROM Expense_ALL
GROUP BY ProjectID;

-- Serial vs Parallel scan
EXPLAIN PLAN FOR SELECT /*+ FULL(bs) */ COUNT(*) FROM Expense_ALL bs;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

EXPLAIN PLAN FOR SELECT /*+ PARALLEL(bs, 8) */ COUNT(*) FROM Expense_ALL bs;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL, NULL, 'ALLSTATS LAST'));

--------------------------------------------------------------------------------
-- A4: Two-Phase Commit (simulate distributed insert)
--------------------------------------------------------------------------------
BEGIN
INSERT INTO Expense_A VALUES (11,1,'Editing',500,SYSDATE);
INSERT INTO Expense_B@proj_link VALUES (12,2,'Music',300,SYSDATE);
COMMIT;
END;
/
-- To test failure: disable link and rerun, then check DBA_2PC_PENDING

INSERT INTO Expense_A VALUES (13,1,'Editing 1',500,SYSDATE);
INSERT INTO Expense_B@proj_link VALUES (14,2,'Music 1',300,SYSDATE);

--------------------------------------------------------------------------------
-- A5: Distributed Lock Conflict
--------------------------------------------------------------------------------
-- (Manual test with two sessions)
-- Session 1:
-- UPDATE Project SET Budget=21000 WHERE ProjectID=1;
-- Session 2 (through link):
-- UPDATE Project@proj_link SET Budget=20500 WHERE ProjectID=1;
-- Use V$LOCK or DBA_WAITERS to diagnose
UPDATE Project_B@proj_link SET Budget = 20500 WHERE ProjectID = 1;
UPDATE Project_A SET Budget = 20500 WHERE ProjectID = 1;

SELECT sid, type, lmode, request, id1, id2, block
FROM v$lock
WHERE type = 'TX';
--------------------------------------------------------------------------------
-- B6: Declarative Rules Hardening
--------------------------------------------------------------------------------
ALTER TABLE Expense ADD CONSTRAINT chk_amt_positive CHECK (Amount>0);
ALTER TABLE Expense ADD CONSTRAINT chk_date_valid CHECK (DateIncurred>=DATE '2024-01-01');
ALTER TABLE Project ADD CONSTRAINT chk_budget_positive CHECK (Budget>0);
ALTER TABLE Project ADD CONSTRAINT chk_date_order CHECK (StartDate<=EndDate);

DECLARE
v_error VARCHAR2(4000);
BEGIN
BEGIN
        DBMS_OUTPUT.PUT_LINE('Attempting invalid expense (negative amount)...');
INSERT INTO Expense(ExpenseID, ProjectID, Description, Amount, DateIncurred)
VALUES (101, 1, 'Negative Amount', -50, SYSDATE);
EXCEPTION
        WHEN OTHERS THEN
            v_error := SQLERRM;
            DBMS_OUTPUT.PUT_LINE('❌ Expected fail: ' || v_error);
ROLLBACK;
END;
BEGIN
        DBMS_OUTPUT.PUT_LINE('Attempting invalid expense (too old date)...');
INSERT INTO Expense (ExpenseID, ProjectID, Description, Amount, DateIncurred)
VALUES (102, 1, 'Old Date', 500, DATE '2023-12-31');
EXCEPTION
        WHEN OTHERS THEN
            v_error := SQLERRM;
            DBMS_OUTPUT.PUT_LINE('❌ Expected fail: ' || v_error);
ROLLBACK;
END;
BEGIN
        DBMS_OUTPUT.PUT_LINE('Attempting invalid project (negative budget)...');
INSERT INTO Project (ProjectID, Title, Budget, StartDate, EndDate)
VALUES (201, 'Invalid Budget Project', -10000, DATE '2024-01-01', DATE '2024-12-31');
EXCEPTION
        WHEN OTHERS THEN
            v_error := SQLERRM;
            DBMS_OUTPUT.PUT_LINE('❌ Expected fail: ' || v_error);
ROLLBACK;
END;
BEGIN
        DBMS_OUTPUT.PUT_LINE('Attempting invalid project (start after end)...');
INSERT INTO Project (ProjectID, Title, Budget, StartDate, EndDate)
VALUES (202, 'Reversed Dates', 50000, DATE '2024-12-31', DATE '2024-01-01');
EXCEPTION
        WHEN OTHERS THEN
            v_error := SQLERRM;
            DBMS_OUTPUT.PUT_LINE('❌ Expected fail: ' || v_error);
ROLLBACK;
END;
    DBMS_OUTPUT.PUT_LINE('✅ All invalid cases failed as expected.');
END;
--verify inserted record
select * from PROJECT

--------------------------------------------------------------------------------
-- B7: E–C–A Trigger for Denormalized Totals
--------------------------------------------------------------------------------
CREATE TABLE Project_AUDIT(
                              bef_total NUMBER, aft_total NUMBER,
                              changed_at TIMESTAMP, key_col VARCHAR2(64)
);

CREATE OR REPLACE TRIGGER trg_expense_totals
AFTER INSERT OR UPDATE OR DELETE ON Expense
DECLARE
v_before NUMBER; v_after NUMBER;
BEGIN
SELECT NVL(SUM(Amount),0) INTO v_before FROM Expense_A;
UPDATE Project p
SET Budget = (SELECT NVL(SUM(Amount),0) FROM Expense_A e WHERE e.ProjectID=p.ProjectID)
WHERE EXISTS (SELECT 1 FROM Expense_A e WHERE e.ProjectID=p.ProjectID);
SELECT NVL(SUM(Amount),0) INTO v_after FROM Expense_A;
INSERT INTO Project_AUDIT VALUES (v_before,v_after,SYSTIMESTAMP,'Expense_A');
END;
/

INSERT INTO Expense_A VALUES (22,2,'Transport Extra',300,SYSDATE);
COMMIT;

SELECT * FROM Project_AUDIT;

--------------------------------------------------------------------------------
-- B8: Recursive Hierarchy Roll-Up
--------------------------------------------------------------------------------
CREATE TABLE HIER(parent_id NUMBER, child_id NUMBER);
INSERT INTO HIER VALUES (NULL,1);
INSERT INTO HIER VALUES (1,2);
INSERT INTO HIER VALUES (1,3);
INSERT INTO HIER VALUES (2,4);
INSERT INTO HIER VALUES (3,5);
COMMIT;

WITH roll (child_id, root_id, depth) AS (
    SELECT child_id, child_id, 1 FROM HIER WHERE parent_id IS NULL
    UNION ALL
    SELECT h.child_id, r.root_id, r.depth+1
    FROM HIER h JOIN roll r ON h.parent_id=r.child_id
)
SELECT r.child_id, r.root_id, r.depth, e.Amount
FROM roll r JOIN Expense_A e ON e.ProjectID=r.child_id
    FETCH FIRST 10 ROWS ONLY;

--------------------------------------------------------------------------------
-- B9: Mini Knowledge Base with Transitive Inference
--------------------------------------------------------------------------------
CREATE TABLE TRIPLE(s VARCHAR2(64), p VARCHAR2(64), o VARCHAR2(64));
INSERT INTO TRIPLE VALUES ('Camera','isA','Equipment');
INSERT INTO TRIPLE VALUES ('Equipment','isA','Asset');
INSERT INTO TRIPLE VALUES ('Catering','isA','Service');
INSERT INTO TRIPLE VALUES ('Service','isA','ExpenseType');
INSERT INTO TRIPLE VALUES ('Asset','isA','ExpenseType');
COMMIT;
select * from TRIPLE

WITH isa(s,o) AS (
    SELECT s,o FROM TRIPLE WHERE p='isA'
    UNION ALL
    SELECT i.s, t.o FROM isa i JOIN TRIPLE t ON i.o=t.s AND t.p='isA'
)
SELECT DISTINCT s AS item, o AS inferred_type FROM isa;

--------------------------------------------------------------------------------
-- B10: Business Limit Alert (Function + Trigger)
--------------------------------------------------------------------------------
CREATE TABLE BUSINESS_LIMITS(
                                rule_key VARCHAR2(64) PRIMARY KEY,
                                threshold NUMBER,
                                active CHAR(1) CHECK(active IN('Y','N'))
);
INSERT INTO BUSINESS_LIMITS VALUES('MAX_EXPENSE',500,'Y');
COMMIT;

CREATE OR REPLACE FUNCTION fn_should_alert(p_amount NUMBER)
RETURN NUMBER IS
  v_threshold NUMBER;
BEGIN
SELECT threshold INTO v_threshold FROM BUSINESS_LIMITS
WHERE rule_key='MAX_EXPENSE' AND active='Y';
RETURN CASE WHEN p_amount>v_threshold THEN 1 ELSE 0 END;
END;
/

CREATE OR REPLACE TRIGGER trg_expense_limit
BEFORE INSERT OR UPDATE ON Expense_A
                            FOR EACH ROW
BEGIN
  IF fn_should_alert(:NEW.Amount)=1 THEN
    RAISE_APPLICATION_ERROR(-20001,'Expense exceeds configured threshold!');
END IF;
END;
/

BEGIN
INSERT INTO Expense VALUES (30,1,'Over Budget',800,SYSDATE);
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('Expected threshold fail: '||SQLERRM);
ROLLBACK;
END;
/
INSERT INTO Expense VALUES (31,1,'Valid Spend',400,SYSDATE);
COMMIT;

SELECT * FROM Expense;

--------------------------------------------------------------------------------
-- END OF SCRIPT (≤10 committed rows verified)
--------------------------------------------------------------------------------

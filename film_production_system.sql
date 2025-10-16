-- ==========================================================
-- 🎬 FILM PRODUCTION AND CREW MANAGEMENT SYSTEM (UUID Version)
-- Database: PostgreSQL
-- Author: Kwibuka Frank
-- RegNo: 216128218
-- ==========================================================

-- CREATE DATABASE
DROP DATABASE IF EXISTS film_production_db;
CREATE DATABASE film_production_db;
\c film_production_db;

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ==========================================================
-- TABLE DEFINITIONS
-- ==========================================================

-- PROJECT TABLE
CREATE TABLE Project (
                         ProjectID UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                         Title VARCHAR(100) NOT NULL,
                         Director VARCHAR(100),
                         StartDate DATE,
                         EndDate DATE,
                         Budget NUMERIC(12,2) CHECK (Budget >= 0)
);

-- CREW TABLE
CREATE TABLE Crew (
                      CrewID UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                      FullName VARCHAR(100) NOT NULL,
                      Role VARCHAR(50),
                      Contact VARCHAR(50),
                      ExperienceYears INT CHECK (ExperienceYears >= 0)
);

-- ASSIGNMENT TABLE
CREATE TABLE Assignment (
                            AssignID UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                            ProjectID UUID REFERENCES Project(ProjectID) ON DELETE CASCADE,
                            CrewID UUID REFERENCES Crew(CrewID) ON DELETE CASCADE,
                            StartDate DATE,
                            EndDate DATE,
                            DailyRate NUMERIC(10,2) CHECK (DailyRate > 0)
);

-- SCHEDULE TABLE
CREATE TABLE Schedule (
                          ScheduleID UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                          ProjectID UUID REFERENCES Project(ProjectID) ON DELETE CASCADE,
                          Scene VARCHAR(100),
                          Location VARCHAR(100),
                          ShootDate DATE,
                          Status VARCHAR(20) CHECK (Status IN ('Planned', 'Ongoing', 'Completed'))
);

-- EXPENSE TABLE
CREATE TABLE Expense (
                         ExpenseID UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                         ProjectID UUID REFERENCES Project(ProjectID) ON DELETE CASCADE,
                         Description TEXT,
                         Amount NUMERIC(10,2) CHECK (Amount > 0),
                         DateIncurred DATE DEFAULT CURRENT_DATE
);

-- PAYMENT TABLE
CREATE TABLE Payment (
                         PaymentID UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                         AssignID UUID UNIQUE REFERENCES Assignment(AssignID) ON DELETE CASCADE,
                         Amount NUMERIC(10,2) CHECK (Amount > 0),
                         PaymentDate DATE DEFAULT CURRENT_DATE,
                         Method VARCHAR(20) CHECK (Method IN ('Cash', 'Bank Transfer', 'Cheque'))
);

-- ==========================================================
-- SAMPLE DATA
-- ==========================================================

-- INSERT SAMPLE PROJECTS
INSERT INTO Project (Title, Director, StartDate, EndDate, Budget) VALUES
                                                                      ('Echoes of Kigali', 'Eric Niyonsenga', '2025-01-10', '2025-03-10', 80000),
                                                                      ('Shadows of the Hills', 'Aline Uwase', '2025-02-01', '2025-04-30', 120000),
                                                                      ('The Rising Drum', 'Patrick Mugisha', '2025-03-15', '2025-06-15', 95000);

-- INSERT SAMPLE CREW MEMBERS
INSERT INTO Crew (FullName, Role, Contact, ExperienceYears) VALUES
                                                                ('Jean Claude Ndayisenga', 'Cinematographer', '0788000001', 5),
                                                                ('Alice Uwamahoro', 'Sound Engineer', '0788000002', 3),
                                                                ('Eric Hakizimana', 'Editor', '0788000003', 4),
                                                                ('Moses Gatera', 'Lighting Technician', '0788000004', 2),
                                                                ('Patricia Uwitonze', 'Makeup Artist', '0788000005', 6),
                                                                ('Charles Mugabo', 'Producer', '0788000006', 10),
                                                                ('Rebecca Mutoni', 'Camera Assistant', '0788000007', 1),
                                                                ('Josephine Ingabire', 'Director Assistant', '0788000008', 2),
                                                                ('Kevin Kamanzi', 'Grip', '0788000009', 3),
                                                                ('Ange Uwimana', 'Costume Designer', '0788000010', 4);

-- We’ll use temporary variables to link data with UUIDs
DO $$
DECLARE
p1 UUID;
    p2 UUID;
    p3 UUID;
    c1 UUID;
    c2 UUID;
    c3 UUID;
    c4 UUID;
    c5 UUID;
    c6 UUID;
    c7 UUID;
    c8 UUID;
    c9 UUID;
    c10 UUID;
BEGIN
SELECT ProjectID INTO p1 FROM Project WHERE Title = 'Echoes of Kigali';
SELECT ProjectID INTO p2 FROM Project WHERE Title = 'Shadows of the Hills';
SELECT ProjectID INTO p3 FROM Project WHERE Title = 'The Rising Drum';

SELECT CrewID INTO c1 FROM Crew WHERE FullName = 'Jean Claude Ndayisenga';
SELECT CrewID INTO c2 FROM Crew WHERE FullName = 'Alice Uwamahoro';
SELECT CrewID INTO c3 FROM Crew WHERE FullName = 'Eric Hakizimana';
SELECT CrewID INTO c4 FROM Crew WHERE FullName = 'Moses Gatera';
SELECT CrewID INTO c5 FROM Crew WHERE FullName = 'Patricia Uwitonze';
SELECT CrewID INTO c6 FROM Crew WHERE FullName = 'Charles Mugabo';
SELECT CrewID INTO c7 FROM Crew WHERE FullName = 'Rebecca Mutoni';
SELECT CrewID INTO c8 FROM Crew WHERE FullName = 'Josephine Ingabire';
SELECT CrewID INTO c9 FROM Crew WHERE FullName = 'Kevin Kamanzi';
SELECT CrewID INTO c10 FROM Crew WHERE FullName = 'Ange Uwimana';

-- Assign crew to projects
INSERT INTO Assignment (ProjectID, CrewID, StartDate, EndDate, DailyRate) VALUES
                                                                              (p1, c1, '2025-01-10', '2025-02-20', 300),
                                                                              (p1, c2, '2025-01-12', '2025-02-18', 250),
                                                                              (p1, c3, '2025-01-15', '2025-02-25', 270),
                                                                              (p2, c4, '2025-02-05', '2025-03-25', 200),
                                                                              (p2, c5, '2025-02-10', '2025-03-30', 220),
                                                                              (p3, c6, '2025-03-20', '2025-05-10', 400),
                                                                              (p3, c7, '2025-03-22', '2025-05-15', 180),
                                                                              (p3, c8, '2025-03-25', '2025-05-25', 220),
                                                                              (p2, c9, '2025-02-08', '2025-04-08', 210),
                                                                              (p1, c10, '2025-01-18', '2025-02-28', 230);

-- Insert expenses
INSERT INTO Expense (ProjectID, Description, Amount, DateIncurred) VALUES
                                                                       (p1, 'Camera rental', 5000, '2025-01-15'),
                                                                       (p1, 'Transport', 2500, '2025-01-18'),
                                                                       (p2, 'Lighting equipment', 7000, '2025-02-20'),
                                                                       (p3, 'Sound system', 4000, '2025-03-25');
END $$;

-- ==========================================================
--  VIEW FOR COST BREAKDOWN BY FILM
-- ==========================================================

CREATE OR REPLACE VIEW FilmCostBreakdown AS
SELECT
    p.title,
    COALESCE(SUM(e.amount), 0) AS TotalExpenses,
    COALESCE(SUM(pay.amount), 0) AS TotalPayments,
    p.budget AS RemainingBudget
FROM Project p
         LEFT JOIN Expense e ON p.projectid = e.projectid
         LEFT JOIN Assignment a ON p.projectid = a.projectid
         LEFT JOIN Payment pay ON a.assignid = pay.assignid
GROUP BY p.projectid, p.title, p.budget;

-- ==========================================================
-- TRIGGERS
-- ==========================================================

-- (a) UPDATE PROJECT BUDGET AFTER INSERTING EXPENSE
CREATE OR REPLACE FUNCTION update_project_budget()
RETURNS TRIGGER AS $$
BEGIN
UPDATE Project
SET budget = project.budget - NEW.amount
WHERE project.projectid = NEW.projectid;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_budget
    AFTER INSERT ON Expense
    FOR EACH ROW
    EXECUTE FUNCTION update_project_budget();

-- (b) PREVENT PAYMENT IF PROJECT BUDGET IS EXCEEDED
CREATE OR REPLACE FUNCTION prevent_overpayment()
RETURNS TRIGGER AS $$
DECLARE
remaining_budget NUMERIC;
BEGIN
SELECT Budget INTO remaining_budget
FROM Project
WHERE ProjectID = (
    SELECT ProjectID FROM Assignment WHERE AssignID = NEW.AssignID
);

IF remaining_budget < NEW.Amount THEN
        RAISE EXCEPTION '❌ Payment of % exceeds remaining project budget: %', NEW.Amount, remaining_budget;
END IF;

RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_prevent_overpayment
    BEFORE INSERT ON Payment
    FOR EACH ROW
    EXECUTE FUNCTION prevent_overpayment();

-- ==========================================================
-- TEST QUERIES (OPTIONAL)
-- ==========================================================

-- Retrieve total expenses per film
SELECT p.title, SUM(e.amount) AS TotalExpenses
FROM Project p
LEFT JOIN Expense e ON p.ProjectID = e.ProjectID
GROUP BY p.projectid, p.title;

-- Identify crew members working on multiple projects
SELECT c.fullname, COUNT(DISTINCT a.projectid) AS ProjectsWorkedOn
FROM crew c
JOIN assignment a ON c.crewid = a.crewid
GROUP BY c.crewid, c.fullName
HAVING COUNT(DISTINCT a.ProjectID) > 1;

-- View cost breakdown
SELECT * FROM filmcostbreakdown;

-- ==========================================================
--INSERT SAMPLE PAYMENTS
-- ==========================================================
DO $$
    DECLARE
        a1 UUID;
        a2 UUID;
        a3 UUID;
        a4 UUID;
        a6 UUID;
    BEGIN
        SELECT AssignID INTO a1 FROM Assignment LIMIT 1 OFFSET 0; -- first assignment
        SELECT AssignID INTO a2 FROM Assignment LIMIT 1 OFFSET 1;
        SELECT AssignID INTO a3 FROM Assignment LIMIT 1 OFFSET 2;
        SELECT AssignID INTO a4 FROM Assignment LIMIT 1 OFFSET 3;
        SELECT AssignID INTO a6 FROM Assignment LIMIT 1 OFFSET 5;
        INSERT INTO Payment (AssignID, Amount, PaymentDate, Method) VALUES
                                                                        (a1, 6000, '2025-02-22', 'Bank Transfer'),
                                                                        (a2, 5000, '2025-02-25', 'Cash'),
                                                                        (a3, 5400, '2025-02-28', 'Bank Transfer'),
                                                                        (a4, 4500, '2025-03-28', 'Cheque'),
                                                                        (a6, 8000, '2025-04-30', 'Bank Transfer');
    END $$;
-- ==========================================================
--  Test the trigger
-- ==========================================================
INSERT INTO Payment (AssignID, Amount, PaymentDate, Method)
SELECT AssignID, 999999, CURRENT_DATE, 'Cash' FROM Assignment LIMIT 1;

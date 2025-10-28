-- 2) Active DBs (E–C–A): Statement-level trigger with transition tables
-- Prereqs
CREATE TABLE IF NOT EXISTS bill (
                                    id    BIGINT PRIMARY KEY,
                                    total NUMERIC(12,2) NOT NULL DEFAULT 0
    );

CREATE TABLE IF NOT EXISTS bill_item (
                                         bill_id    BIGINT NOT NULL REFERENCES bill(id),
    amount     NUMERIC(12,2) NOT NULL,
    updated_at TIMESTAMPTZ   NOT NULL DEFAULT now()
    );

CREATE TABLE IF NOT EXISTS bill_audit (
                                          bill_id    BIGINT,
                                          old_total  NUMERIC(12,2),
    new_total  NUMERIC(12,2),
    changed_at TIMESTAMPTZ DEFAULT now()
    );

INSERT INTO bill(id) VALUES (10) ON CONFLICT DO NOTHING;
INSERT INTO bill(id) VALUES (20) ON CONFLICT DO NOTHING;

-- Statement-level trigger using transition tables (PostgreSQL 10+)
CREATE OR REPLACE FUNCTION trg_bill_total_stmt_fn()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE
affected_ids BIGINT[];
  bid BIGINT;
  v_old NUMERIC(12,2);
  v_new NUMERIC(12,2);
BEGIN
  -- Collect distinct affected bill_ids from NEW TABLE and OLD TABLE
SELECT ARRAY(
           SELECT DISTINCT x.bill_id
           FROM (
             SELECT bill_id FROM new_table
             UNION
             SELECT bill_id FROM old_table
           ) AS x
         )
INTO affected_ids;

IF affected_ids IS NULL OR array_length(affected_ids,1) IS NULL THEN
    RETURN NULL;
END IF;

  -- Recompute once per bill_id
  FOREACH bid IN ARRAY affected_ids LOOP
SELECT COALESCE(total,0) INTO v_old FROM bill WHERE id = bid;
SELECT COALESCE(SUM(amount),0) INTO v_new FROM bill_item WHERE bill_id = bid;

UPDATE bill SET total = v_new WHERE id = bid;

INSERT INTO bill_audit(bill_id, old_total, new_total) VALUES (bid, v_old, v_new);
END LOOP;

RETURN NULL;
END;
$$;

DROP TRIGGER IF EXISTS trg_bill_total_stmt ON bill_item;

CREATE TRIGGER trg_bill_total_stmt
    AFTER INSERT OR UPDATE OR DELETE ON bill_item
    REFERENCING NEW TABLE AS new_table OLD TABLE AS old_table
    FOR EACH STATEMENT
    EXECUTE FUNCTION trg_bill_total_stmt_fn();

-- 🔬 Mixed-DML test (single statements that affect multiple rows)
INSERT INTO bill_item (bill_id, amount) VALUES
                                            (10, 100), (10,  50), (20, 200);

UPDATE bill_item SET amount = amount + 10 WHERE bill_id IN (10,20);

DELETE FROM bill_item
WHERE bill_id = 10
  AND ctid IN (SELECT ctid FROM bill_item WHERE bill_id = 10 LIMIT 1);

-- Verify
SELECT * FROM bill ORDER BY id;
SELECT * FROM bill_audit ORDER BY changed_at, bill_id;

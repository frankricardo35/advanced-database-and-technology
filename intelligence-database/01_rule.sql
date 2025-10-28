-- Schema setup (optional)
-- CREATE SCHEMA healthnet;
-- SET search_path = healthnet, public;
-- 1) Declarative constraints (Rules): PATIENT_MED----
-- Prereq
CREATE TABLE IF NOT EXISTS patient (
                                       id   BIGINT PRIMARY KEY,
                                       name VARCHAR(100) NOT NULL
    );
-- Fixed table with proper NOT NULL, CHECK, and FK constraints
CREATE TABLE IF NOT EXISTS patient_med (
                                           patient_med_id BIGINT PRIMARY KEY,                          -- unique id
                                           patient_id     BIGINT NOT NULL REFERENCES patient(id),      -- FK
    med_name       VARCHAR(80) NOT NULL,                        -- mandatory
    dose_mg        NUMERIC(6,2) NOT NULL CHECK (dose_mg >= 0),  -- non-negative
    start_dt       DATE NOT NULL,
    end_dt         DATE NOT NULL,
    CONSTRAINT ck_rx_dates CHECK (start_dt <= end_dt)           -- sensible dates
    );

-- Demo patients
INSERT INTO patient(id, name) VALUES (1,'Alice')
    ON CONFLICT (id) DO NOTHING;
INSERT INTO patient(id, name) VALUES (2,'Bob')
    ON CONFLICT (id) DO NOTHING;

-- 1) Negative dose -> ck violation
INSERT INTO patient_med(patient_med_id, patient_id, med_name, dose_mg, start_dt, end_dt)
VALUES (101, 1, 'Amoxicillin', -5, DATE '2025-10-01', DATE '2025-10-05');
-- ERROR:  new row for relation "patient_med" violates check constraint "patient_med_dose_mg_check"

-- 2) Inverted dates -> ck_rx_dates violation
INSERT INTO patient_med(patient_med_id, patient_id, med_name, dose_mg, start_dt, end_dt)
VALUES (102, 1, 'Ibuprofen', 200, DATE '2025-10-10', DATE '2025-10-01');
-- ERROR:  new row for relation "patient_med" violates check constraint "ck_rx_dates"

-- (Also fails: missing patient -> FK)
-- INSERT INTO patient_med VALUES (103, 999, 'Paracetamol', 500, DATE '2025-10-01', DATE '2025-10-02');

--Passing inserts
INSERT INTO patient_med VALUES (201, 1, 'Amoxicillin', 500, DATE '2025-10-01', DATE '2025-10-07');
INSERT INTO patient_med VALUES (202, 2, 'Ibuprofen',   200, DATE '2025-10-03', DATE '2025-10-05');

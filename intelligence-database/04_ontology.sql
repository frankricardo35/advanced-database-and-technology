--4) Knowledge Bases (Triples & Ontology): isA* InfectiousDisease
-- Prereqs
DROP TABLE IF EXISTS triple;
CREATE TABLE triple (s TEXT, p TEXT, o TEXT);

INSERT INTO triple VALUES
                       ('patient1','hasDiagnosis','Influenza'),
                       ('patient2','hasDiagnosis','CommonCold'),
                       ('patient3','hasDiagnosis','Hypertension'),
                       ('Influenza','isA','ViralInfection'),
                       ('CommonCold','isA','ViralInfection'),
                       ('ViralInfection','isA','InfectiousDisease'),
                       ('Hypertension','isA','ChronicDisease'),
                       ('ChronicDisease','isA','NonInfectiousDisease');

WITH RECURSIVE isa(child, ancestor) AS (
    -- direct isA edges
    SELECT s, o FROM triple WHERE p = 'isA'
    UNION ALL
    -- climb child -> ancestor -> higher ancestor
    SELECT t.s, i.ancestor
    FROM triple t
             JOIN isa i
                  ON t.p = 'isA' AND t.o = i.child
),
               infectious_patients AS (
                   SELECT DISTINCT t.s AS patient_id
                   FROM triple t
                            JOIN isa
                                 ON t.p = 'hasDiagnosis'
                                     AND t.o = isa.child
                   WHERE isa.ancestor = 'InfectiousDisease'
               )
SELECT patient_id
FROM infectious_patients
ORDER BY patient_id;
-- -> patient1, patient2

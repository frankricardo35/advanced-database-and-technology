-- 3) Deductive DBs (Recursive CTE): Top supervisor & hops (cycle-safe)
-- Prereqs
DROP TABLE IF EXISTS staff_supervisor;
CREATE TABLE staff_supervisor (
                                  employee   TEXT,
                                  supervisor TEXT
);

INSERT INTO staff_supervisor VALUES
                                 ('Ann','Beth'),
                                 ('Beth','Cara'),
                                 ('Cara','Dana'),
                                 ('Evan','Beth'),
                                 ('Fay','Gus'),
                                 ('Gus','Fay'); -- cycle example

WITH RECURSIVE supers AS (
    -- Anchor: direct supervisor (1 hop)
    SELECT
        employee AS emp,
        supervisor AS sup,
        1 AS hops,
        ARRAY[employee, supervisor]::TEXT[] AS path
FROM staff_supervisor
UNION ALL
-- Recurse upward via supervisor -> that supervisor's supervisor
SELECT
    s.emp,
    t.supervisor AS sup,
    supers.hops + 1,
    path || t.supervisor
FROM staff_supervisor t
         JOIN supers s
              ON t.employee = s.sup
WHERE NOT t.supervisor = ANY (s.path)   -- cycle guard
    ),
ranked AS (
  SELECT
    emp,
    sup AS top_supervisor,
    hops,
    ROW_NUMBER() OVER (PARTITION BY emp ORDER BY hops DESC) AS rn
  FROM supers
)
SELECT emp, top_supervisor, hops
FROM ranked
WHERE rn = 1
ORDER BY emp;


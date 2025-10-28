-- 5) Spatial DBs (PostGIS): Within 1 km & nearest 3
-- Prereqs
-- Enable PostGIS
CREATE EXTENSION IF NOT EXISTS postgis;

-- Clinics table; store as geography(Point,4326) for km/m support
DROP TABLE IF EXISTS clinic;
CREATE TABLE clinic (
                        id   BIGSERIAL PRIMARY KEY,
                        name TEXT NOT NULL,
                        geom GEOGRAPHY(POINT, 4326) NOT NULL   -- lon/lat in WGS84
);

-- Spatial index
CREATE INDEX clinic_gix ON clinic USING GIST (geom);

-- Sample data (lon, lat)
INSERT INTO clinic (name, geom) VALUES
                                    ('Kigali Clinic A', ST_SetSRID(ST_MakePoint(30.0605, -1.9572),4326)::geography),
                                    ('Kigali Clinic B', ST_SetSRID(ST_MakePoint(30.0550, -1.9560),4326)::geography),
                                    ('Kigali Clinic C', ST_SetSRID(ST_MakePoint(30.0700, -1.9600),4326)::geography),
                                    ('Far Clinic D',    ST_SetSRID(ST_MakePoint(30.1200, -1.9800),4326)::geography);

-- Ambulance point: lon=30.0600, lat=-1.9570
WITH amb AS (
    SELECT ST_SetSRID(ST_MakePoint(30.0600, -1.9570),4326)::geography AS p
)

-- 1) Within 1 km
SELECT c.id, c.name
FROM clinic c, amb
WHERE ST_DWithin(c.geom, amb.p, 1000);   -- meters

-- 2) Nearest 3 with distance in KM
WITH amb AS (
    SELECT ST_SetSRID(ST_MakePoint(30.0600, -1.9570),4326)::geography AS p
)
SELECT
    c.id,
    c.name,
    ROUND(ST_Distance(c.geom, amb.p) / 1000.0, 3) AS km
FROM clinic c, amb
ORDER BY ST_Distance(c.geom, amb.p)
    LIMIT 3;

# 🧠 Intelligence Databases — PostgreSQL Assignments

**Author:** Kwibuka Frank
**Reg No:** 216 128 218
**Course:** Intelligence Databases  
**Database:** PostgreSQL 15+ (with PostGIS for Task 5)  
**Date:** October 2025

---

## 📘 Overview

This project demonstrates five components of **Intelligent Database Systems**, from rule-based validation to spatial reasoning.  
Each `.sql` file showcases a unique intelligence aspect:

| Task | Theme | Core Concept |
|------|--------|--------------|
| 1 | Declarative Constraints | Rules & Validation |
| 2 | Active Databases | Triggers (Event–Condition–Action) |
| 3 | Deductive Databases | Recursive Knowledge Derivation |
| 4 | Knowledge Bases | Ontological Reasoning (Triples) |
| 5 | Spatial Databases | Geospatial Intelligence & Distance Queries |

---

## 🧩 1. Declarative Constraints — Safe Prescriptions
**File:** `01_rules.sql`

This script enforces **data correctness** using declarative constraints before any application logic runs.

### Highlights
- **Non-negative dose:** `CHECK (dose_mg >= 0)`
- **Mandatory fields:** `NOT NULL` on patient, med name, dates
- **Referential integrity:** `patient_id REFERENCES patient(id)`
- **Date logic:** `start_dt <= end_dt`

### Expected Behavior
- Rejects negative doses, missing patients, and reversed dates
- Accepts logically valid prescriptions only

Represents **rule-based intelligence** at the schema level.

---

## ⚙️ 2. Active Databases — Bill Totals That Stay Correct
**File:** `02_triggers.sql`

Implements **Event–Condition–Action (E–C–A)** logic using a **statement-level trigger**.

### Functionality
- Detects changes in `bill_item`
- Gathers all affected `bill_id`s (once per statement)
- Recomputes `bill.total` and records to `bill_audit`
- Avoids redundant recomputation and mutating-table errors

### Result
Totals remain consistent automatically — a form of **reactive database intelligence**.

---

## 🔁 3. Deductive Databases — Referral / Supervision Chain
**File:** `03_recursive_with.sql`

Uses **recursive CTE (`WITH RECURSIVE`)** to infer hierarchical knowledge.

### Goal
From `(employee, supervisor)` pairs, derive:
- Each employee’s **top supervisor**
- The number of **hops** to reach them

### Features
- Recursive logic climbs supervision hierarchy
- Guards against infinite loops (cycle detection)
- Uses window functions to find the furthest supervisor

This models **deductive reasoning** — deriving new facts from existing facts.

---

## 🧠 4. Knowledge Bases — Infectious Disease Roll-Up
**File:** `04_ontology.sql`

Models semantic knowledge using triples (`subject`, `predicate`, `object`).

### Purpose
- Store relationships like `hasDiagnosis` and `isA`
- Compute **transitive closure** of `isA` relations
- Return patients whose diagnosis ultimately **isA\*** `InfectiousDisease`

### Output
- Lists patients with direct or indirect infectious diseases
- Demonstrates **ontological reasoning** in a relational model

---

## 🗺️ 5. Spatial Databases — Radius & Nearest-3 Clinics
**File:** `05_spatial.sql`

Applies **PostGIS spatial intelligence** to find clinics near an ambulance.

### Configuration
- Geometry type: `GEOGRAPHY(POINT,4326)` (lon/lat, WGS84)
- Spatial index: GiST on `geom`

### Queries
1. Clinics **within 1 km** of a given point
2. **Nearest 3** clinics with distance in kilometers

### Functions Used
- `ST_DWithin()` → filters by radius
- `ST_Distance()` → calculates real-world distance (km)

Represents **spatial reasoning**, part of location-aware intelligent systems.

---

## 🧪 Testing & Execution

Each SQL file includes:
- Table creation
- Sample data
- Failing & passing test cases
- Expected outputs in comments

### Run all scripts in sequence:
```sql
\i 01_rules.sql
\i 02_triggers.sql
\i 03_recursive_with.sql
\i 04_ontology.sql
\i 05_spatial.sql

# 🎬 Film Production & Crew Management System (Oracle 19c)

[![Oracle SQL](https://img.shields.io/badge/Database-Oracle%2019c-red?logo=oracle&logoColor=white)](https://www.oracle.com/database/)
[![SQL Developer](https://img.shields.io/badge/Tool-SQL%20Developer-blue?logo=databricks&logoColor=white)](https://www.oracle.com/tools/downloads/sqldev-downloads.html)
[![License](https://img.shields.io/badge/License-Academic--Use-lightgrey)](#)
[![Language](https://img.shields.io/badge/Language-SQL-green)](#)

**Author:** Frank KWIBUKA  
**Reg. No:** 216128218  
**Course:** Advanced Database Systems (Practical Lab)  
**Institution:** [Add your institution name here]  
**Semester:** 2025

---

## 📖 Overview

This project implements a **Film Production & Crew Management System** designed for academic demonstration of **advanced database concepts** using **Oracle 19c**.  
It simulates a real-world film studio environment where multiple film projects, crew members, assignments, expenses, and payments are managed while enforcing **budget constraints, data integrity, and distributed transaction control**.

The script is structured to support **hands-on exercises** in:
- SQL schema design
- Constraints and triggers
- Views and analytical queries
- Parallel query processing
- Distributed databases (using database links)
- Concurrency control and two-phase commit (2PC)

---

## 🧱 Database Schema

### Core Entities

| Table | Description |
|--------|-------------|
| **Project** | Stores film projects, directors, and budgets. |
| **Crew** | Contains crew member details, roles, and experience. |
| **Assignment** | Links crew members to projects with start/end dates and daily rates. |
| **Schedule** | Manages shooting schedules and scene tracking. |
| **Expense** | Records expenses and automatically updates project budget. |
| **Payment** | Stores payments made to crew assignments and validates against remaining project budgets. |

---

## ⚙️ Key Constraints & Triggers

### ✅ Constraints
- `CK_PRJ_DATES`: Ensures `EndDate ≥ StartDate`.
- `CK_PRJ_BUDGET`: Prevents negative budgets.
- `CK_CREW_EXP`: Disallows negative experience years.
- `CK_ASS_RATE`: Enforces non-negative daily rates.

### ⚡ Triggers
| Trigger | Description |
|----------|-------------|
| `TRG_EXPENSE_UPDATE_BUDGET` | Automatically decreases project budget when a new expense is added. Prevents overspending. |
| `TRG_PAYMENT_BUDGET_GUARD` | Ensures no payment exceeds remaining budget and updates the project’s remaining funds. |

---

## 👁️ View: `VW_FILM_COST_BREAKDOWN`

A consolidated view that provides a **cost summary per project**, including:
- Total assignment cost (days × daily rate)
- Total expenses
- Total payments
- Remaining project budget

```sql
SELECT * FROM VW_FILM_COST_BREAKDOWN ORDER BY ProjectID;

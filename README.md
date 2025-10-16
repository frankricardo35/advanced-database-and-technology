# 🎬 Film Production and Crew Management System (PostgreSQL + UUID)
[![Database](https://img.shields.io/badge/Database-PostgreSQL-blue)](https://www.postgresql.org/)
[![Built With SQL](https://img.shields.io/badge/Built%20With-SQL-orange)](#)

---
## 📖 Overview
This project implements a **Film Production and Crew Management System** designed to manage multiple film projects, crew members, assignments, schedules, expenses, and payments for a film studio.  
It includes database triggers, constraints, and a cost breakdown view for effective production planning and budget control.

---

## 🧩 Features
✅ Manage multiple **film projects** with budgets and directors.  
✅ Track **crew members**, roles, and experience.  
✅ Assign crew to projects with dates and daily rates.  
✅ Manage **shooting schedules** and scene tracking.  
✅ Record **expenses** and automatically update project budgets.  
✅ Handle **crew payments** with built-in budget validation.  
✅ Generate a **cost breakdown view** for each film project.

---

## 🧱 Database Schema

| Table | Description |
|--------|-------------|
| `Project` | Stores film project details and budget information. |
| `Crew` | Stores crew member details, roles, and experience. |
| `Assignment` | Links crew members to film projects. |
| `Schedule` | Manages film scenes, locations, and shooting status. |
| `Expense` | Records project expenses and triggers automatic budget updates. |
| `Payment` | Handles crew payments with validation against remaining budget. |

### Relationships
- **Project → Assignment** (1:N)
- **Crew → Assignment** (1:N)
- **Project → Schedule** (1:N)
- **Project → Expense** (1:N)
- **Assignment → Payment** (1:1, with CASCADE DELETE)

---

## 🛠️ Setup Instructions

### 1️⃣ Clone Repository
```bash
git clone https://github.com/frankricardo35/Film-Production-and-Crew-Management-System.git
cd film-production-system
open cd cat1/sql script film_production_system.sql

```

---
## 👨‍💻 Author


- **Frank KWIBUKA** 
- **🎓 RegNo: 216128218**


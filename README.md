# ⚓ MaritimeCareerIQ 
## Maritime Sponsorship & Career Intelligence System

**Full-Stack Web Application | DBMS Mini Project**
*SRM IST — Laranya Pradhan & Garima Jand*

---

## Complete Folder Structure

```
maritime/
├── database/
│   └── schema.sql              ← 19 tables, 30 companies, triggers, views, full data
│
├── backend/
│   ├── config/
│   │   ├── db.js               ← MySQL connection pool
│   │   └── upload.js           ← Multer file upload config
│   ├── controllers/
│   │   ├── studentController.js      ← Register, login, profile, dashboard, upload
│   │   ├── companyController.js      ← Companies, fleet, doctors, deadlines, financials
│   │   ├── eligibilityController.js  ← Core SQL JOIN eligibility logic
│   │   └── applicationController.js  ← Apply, track, withdraw, analytics
│   ├── middleware/
│   │   └── auth.js             ← JWT authentication
│   ├── routes/
│   │   ├── studentRoutes.js
│   │   ├── companyRoutes.js
│   │   ├── eligibilityRoutes.js
│   │   └── applicationRoutes.js
│   ├── uploads/                ← Document uploads stored here (auto-created)
│   ├── server.js               ← Express entry point (serves API + frontend)
│   ├── package.json
│   └── .env.example
│
└── frontend/
    ├── index.html              ← Landing page + Login + Register
    ├── companies.html          ← Full company explorer with modal details
    ├── eligibility.html        ← Real-time eligibility checker (all criteria)
    ├── financial.html          ← Complete financial planner
    ├── dashboard.html          ← Student dashboard (5 tabs)
    ├── tracker.html            ← Apply + track + document upload
    ├── css/
    │   └── global.css          ← Light cream theme, all components
    └── js/
        └── api.js              ← API helpers, formatters, auth utils
```

---

## Setup in 5 Steps

### Step 1 — Prerequisites
Make sure you have:
- [Node.js v18+](https://nodejs.org) — check with `node --version`
- [MySQL 8.0+](https://dev.mysql.com/downloads/)

### Step 2 — Import the Database

Open MySQL (use full path on Windows if needed):
```
"C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -u root -p
```

Then inside MySQL prompt:
```sql
source C:/path/to/maritime/database/schema.sql
```

Replace `C:/path/to/maritime` with your actual folder path. Use **forward slashes**.

This creates `maritime_db` with:
- 19 tables (all entities)
- 30 shipping companies with full data
- 12 partner colleges
- Salary, financial, deadline, doctor, selection process data
- 8 demo student accounts
- Triggers, views

### Step 3 — Configure Environment

```bash
cd maritime/backend
copy .env.example .env
```

Open `.env` and set your MySQL password:
```
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=YOUR_MYSQL_PASSWORD_HERE
DB_NAME=maritime_db
PORT=5000
JWT_SECRET=any_long_random_string
```

### Step 4 — Install Dependencies & Start

```bash
cd maritime/backend
npm install
npm start
```

You should see:
```
✅  MySQL connected → maritime_db
🚢  Maritime System v2 → http://localhost:5000
```

### Step 5 — Open the App

Visit: **http://localhost:5000**

---

## Demo Login Accounts

| Email | Password | Profile |
|-------|----------|---------|
| arjun@maritime.com | password123 | PCM 78.5%, Rank 120, Eligible ~20 companies |
| priya@maritime.com | password123 | PCM 82%, Rank 85, Selected by Maersk |
| rohit@maritime.com | password123 | PCM 65%, No swimming, mid-tier |
| sneha@maritime.com | password123 | PCM 70%, Female, swimming certified |
| karan@maritime.com | password123 | PCM 55%, Pending medical, eye ±3.5 (harder profile) |
| ananya@maritime.com | password123 | PCM 88%, Rank 42 — top scorer |
| vivek@maritime.com | password123 | PCM 50%, No IMU rank, Pending medical (easy entry test) |
| meera@maritime.com | password123 | PCM 73%, Rank 180, female cadet |

---

## 📡 Complete API Reference

### Students
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/api/students/register` | ❌ | Register with all new fields |
| POST | `/api/students/login` | ❌ | Login, returns JWT |
| GET  | `/api/students/profile` | ✅ | Full profile |
| GET  | `/api/students/dashboard` | ✅ | All data in one call |
| GET  | `/api/students/documents` | ✅ | Document list + uploaded files |
| POST | `/api/students/documents/upload` | ✅ | Upload file (multipart/form-data) |
| GET  | `/api/students/exam-scores` | ✅ | Exam scores |

### Companies
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/api/companies` | ❌ | All 30 companies with requirements + deadlines |
| GET | `/api/companies/:id` | ❌ | Full company: fleet, colleges, process, doctors, financials, salary |
| GET | `/api/companies/stats/summary` | ❌ | Analytics overview |

### Eligibility *(Core SQL JOIN Feature)*
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/api/eligibility/check` | ❌ | Check by form inputs (no login needed) |
| GET  | `/api/eligibility/:studentId` | ✅ | Check against student DB profile |

### Applications
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST   | `/api/applications` | ✅ | Apply (eligibility auto-checked via transaction) |
| GET    | `/api/applications/my` | ✅ | My applications |
| GET    | `/api/applications/analytics` | ✅ | Platform-wide analytics |
| DELETE | `/api/applications/:id` | ✅ | Withdraw application |

---

## Pages

| Page | URL | What It Does |
|------|-----|-------------|
| Landing | `/` | Home, register, login — animated ship hero |
| Companies | `/companies.html` | 30 companies, filters, full modal with all details |
| Eligibility | `/eligibility.html` | Real-time checker — all 9 criteria, colour-coded |
| Finance | `/financial.html` | Full financial planner by company |
| Dashboard | `/dashboard.html` | Profile, applications, eligibility, docs, scores, analytics |
| Tracker | `/tracker.html` | Apply, track status, upload documents |

---

## Database Tables (19 total)

| # | Table | Purpose |
|---|-------|---------|
| 1 | SHIP_TYPES | Vessel categories (bulk, tanker, LNG, etc.) |
| 2 | COLLEGES | 12 partner institutes with fees, hostel cost |
| 3 | SHIPPING_COMPANIES | 30 companies with all details |
| 4 | SPONSORSHIP_REQUIREMENTS | Enhanced criteria per company |
| 5 | COMPANY_FLEET | Ship type breakdown per company |
| 6 | COMPANY_COLLEGE | M:N junction — company ↔ college |
| 7 | COMPANY_SELECTION_PROCESS | Step-by-step selection stages |
| 8 | COMPANY_APPROVED_DOCTORS | Medical centres per company, city-wise |
| 9 | COMPANY_DEADLINES | Forms open/close, exam, interview, joining dates |
| 10 | COMPANY_FINANCIAL | Full investment breakdown + ROI |
| 11 | COMPANY_SALARY_PROGRESSION | DNS → Captain salary ladder |
| 12 | STUDENTS | Full profile with 10th/12th/English marks, location |
| 13 | EXAMS | Exam types |
| 14 | EXAM_SCORES | Student scores and ranks |
| 15 | APPLICATIONS | Student-company applications |
| 16 | INTERVIEWS | Interview records |
| 17 | DOCUMENTS | Document master list (20 document types) |
| 18 | STUDENT_DOCUMENTS | Uploaded files + verification status |
| 19 | APPLICATION_LOG | Auto-logged by trigger |

### Triggers
- `check_pcm_trigger` — Rejects PCM < 40%, auto-computes aggregate %
- `log_application` — Auto-logs every new application
- `update_status_on_interview` — Auto-updates status when interview result recorded

---

## Eligibility Logic (Chapter 6 Core Query)

```sql
SELECT sc.company_name, sc.stipend_dns,
  (s.pcm_percentage >= sr.min_pcm)                                          AS pcm_ok,
  (s.eyesight <= sr.max_eye_power)                                           AS eye_ok,
  (s.medical_status='Fit' OR (sr.accepts_pending_medical=TRUE
    AND s.medical_status='Pending'))                                          AS med_ok,
  (sr.swimming_required=FALSE OR s.swimming_certified=TRUE)                  AS swim_ok,
  (sr.imu_cet_required=FALSE OR s.imu_cet_rank IS NOT NULL)                 AS imu_ok,
  (s.tenth_percentage >= sr.min_10th_percentage)                             AS tenth_ok,
  (s.twelfth_percentage >= sr.min_12th_percentage)                           AS twelfth_ok,
  ((sr.accepts_dns=TRUE AND s.academic_pathway='DNS') OR
   (sr.accepts_bsc=TRUE AND s.academic_pathway='BSc Nautical Science'))      AS pathway_ok,
  (s.age BETWEEN sr.age_min AND sr.age_max)                                  AS age_ok,
  -- ALL criteria combined:
  (s.pcm_percentage >= sr.min_pcm AND s.eyesight <= sr.max_eye_power
   AND ... AND ...) AS is_eligible
FROM STUDENTS s
CROSS JOIN SPONSORSHIP_REQUIREMENTS sr
JOIN SHIPPING_COMPANIES sc ON sr.company_id = sc.company_id
WHERE s.student_id = ?
ORDER BY is_eligible DESC, sc.stipend_dns DESC;
```

---

## Deploy to Railway (Free Hosting)

1. Push your project to GitHub
2. Go to [railway.app](https://railway.app) → New Project → Deploy from GitHub
3. Add a **MySQL** plugin from Railway dashboard
4. Set environment variables (DB_HOST, DB_USER, etc.) using Railway's provided values
5. Set Start Command: `cd backend && npm start`
6. Railway gives you a live public URL automatically

---

*Built with Node.js · Express · MySQL2 · Multer · Vanilla HTML/CSS/JS · Light Cream Theme*
*SRM IST DBMS Mini Project — Maritime Sponsorship & Career Intelligence System v2.0*

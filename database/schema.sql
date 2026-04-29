-- ================================================================
-- MARITIME SPONSORSHIP & CAREER INTELLIGENCE SYSTEM v2.0
-- Complete MySQL Schema | Enhanced Edition
-- ================================================================

CREATE DATABASE IF NOT EXISTS maritime_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE maritime_db;
SET FOREIGN_KEY_CHECKS = 0;

-- ─────────────────────────────────────────────
-- DROP ALL TABLES (clean reinstall)
-- ─────────────────────────────────────────────
DROP TABLE IF EXISTS APPLICATION_LOG;
DROP TABLE IF EXISTS STUDENT_DOCUMENTS;
DROP TABLE IF EXISTS DOCUMENTS;
DROP TABLE IF EXISTS INTERVIEWS;
DROP TABLE IF EXISTS APPLICATIONS;
DROP TABLE IF EXISTS EXAM_SCORES;
DROP TABLE IF EXISTS EXAMS;
DROP TABLE IF EXISTS COMPANY_COLLEGE;
DROP TABLE IF EXISTS COMPANY_FLEET;
DROP TABLE IF EXISTS COMPANY_SELECTION_PROCESS;
DROP TABLE IF EXISTS COMPANY_APPROVED_DOCTORS;
DROP TABLE IF EXISTS COMPANY_DEADLINES;
DROP TABLE IF EXISTS COMPANY_FINANCIAL;
DROP TABLE IF EXISTS COMPANY_SALARY_PROGRESSION;
DROP TABLE IF EXISTS SPONSORSHIP_REQUIREMENTS;
DROP TABLE IF EXISTS SHIP_TYPES;
DROP TABLE IF EXISTS COLLEGES;
DROP TABLE IF EXISTS SHIPPING_COMPANIES;
DROP TABLE IF EXISTS STUDENTS;

-- ─────────────────────────────────────────────
-- TABLE 1: SHIP_TYPES
-- ─────────────────────────────────────────────
CREATE TABLE SHIP_TYPES (
    ship_type_id   INT PRIMARY KEY AUTO_INCREMENT,
    ship_type_name VARCHAR(60) NOT NULL,
    description    VARCHAR(200)
);

-- ─────────────────────────────────────────────
-- TABLE 2: COLLEGES
-- ─────────────────────────────────────────────
CREATE TABLE COLLEGES (
    college_id                   INT PRIMARY KEY AUTO_INCREMENT,
    college_name                 VARCHAR(100) NOT NULL,
    location                     VARCHAR(80)  NOT NULL,
    course_type                  VARCHAR(30)  NOT NULL,
    imu_cet_cutoff_rank          INT,
    fee_structure                DECIMAL(10,2),
    duration_months              INT          NOT NULL DEFAULT 12,
    hostel_cost_monthly          DECIMAL(8,2),
    female_scholarship_available BOOLEAN DEFAULT FALSE,
    approved_by                  VARCHAR(100)
);

-- ─────────────────────────────────────────────
-- TABLE 3: SHIPPING_COMPANIES
-- ─────────────────────────────────────────────
CREATE TABLE SHIPPING_COMPANIES (
    company_id                INT PRIMARY KEY AUTO_INCREMENT,
    company_name              VARCHAR(100) NOT NULL,
    country                   VARCHAR(60)  NOT NULL,
    hq_city                   VARCHAR(60),
    india_office              VARCHAR(100),
    stipend_dns               INT          NOT NULL COMMENT 'Stipend during DNS training (INR/month)',
    stipend_onboard_trainee   INT          COMMENT 'Onboard trainee stipend (USD/month)',
    bond_years                INT          NOT NULL,
    promotion_period_years    INT          NOT NULL,
    minimum_contract_months   INT          NOT NULL,
    maximum_contract_months   INT          NOT NULL,
    waiting_period_months     INT          NOT NULL DEFAULT 6 COMMENT 'Wait after DNS before joining ship',
    tax_policy                VARCHAR(50)  NOT NULL,
    female_crew_policy        VARCHAR(50)  NOT NULL,
    company_description       TEXT,
    website                   VARCHAR(200),
    total_fleet_size          INT          DEFAULT 0
);

-- ─────────────────────────────────────────────
-- TABLE 4: SPONSORSHIP_REQUIREMENTS (enhanced)
-- ─────────────────────────────────────────────
CREATE TABLE SPONSORSHIP_REQUIREMENTS (
    requirement_id       INT PRIMARY KEY AUTO_INCREMENT,
    company_id           INT           NOT NULL,
    min_pcm              DECIMAL(5,2)  NOT NULL,
    max_eye_power        DECIMAL(3,1)  NOT NULL,
    swimming_required    BOOLEAN       NOT NULL DEFAULT FALSE,
    medical_standard     VARCHAR(80)   NOT NULL,
    accepts_pending_medical BOOLEAN    NOT NULL DEFAULT FALSE,
    imu_cet_required     BOOLEAN       NOT NULL DEFAULT FALSE,
    own_cbt_test         BOOLEAN       NOT NULL DEFAULT FALSE,
    psychometric_test    BOOLEAN       NOT NULL DEFAULT FALSE,
    min_10th_percentage  DECIMAL(5,2)  DEFAULT NULL,
    min_12th_percentage  DECIMAL(5,2)  DEFAULT NULL,
    min_10th_english     DECIMAL(5,2)  DEFAULT NULL,
    min_12th_english     DECIMAL(5,2)  DEFAULT NULL,
    min_aggregate        DECIMAL(5,2)  DEFAULT NULL COMMENT 'Combined 10+12 aggregate',
    age_min              INT           DEFAULT 17,
    age_max              INT           DEFAULT 25,
    accepts_dns          BOOLEAN       DEFAULT TRUE,
    accepts_bsc          BOOLEAN       DEFAULT TRUE,
    additional_notes     TEXT,
    FOREIGN KEY (company_id) REFERENCES SHIPPING_COMPANIES(company_id) ON DELETE CASCADE
);

-- ─────────────────────────────────────────────
-- TABLE 5: COMPANY_FLEET
-- ─────────────────────────────────────────────
CREATE TABLE COMPANY_FLEET (
    fleet_id        INT PRIMARY KEY AUTO_INCREMENT,
    company_id      INT NOT NULL,
    ship_type_id    INT NOT NULL,
    number_of_ships INT NOT NULL DEFAULT 0,
    FOREIGN KEY (company_id)   REFERENCES SHIPPING_COMPANIES(company_id) ON DELETE CASCADE,
    FOREIGN KEY (ship_type_id) REFERENCES SHIP_TYPES(ship_type_id)
);

-- ─────────────────────────────────────────────
-- TABLE 6: COMPANY_COLLEGE (M:N Junction)
-- ─────────────────────────────────────────────
CREATE TABLE COMPANY_COLLEGE (
    company_id INT NOT NULL,
    college_id INT NOT NULL,
    is_preferred BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (company_id, college_id),
    FOREIGN KEY (company_id) REFERENCES SHIPPING_COMPANIES(company_id) ON DELETE CASCADE,
    FOREIGN KEY (college_id) REFERENCES COLLEGES(college_id) ON DELETE CASCADE
);

-- ─────────────────────────────────────────────
-- TABLE 7: COMPANY_SELECTION_PROCESS
-- ─────────────────────────────────────────────
CREATE TABLE COMPANY_SELECTION_PROCESS (
    process_id     INT PRIMARY KEY AUTO_INCREMENT,
    company_id     INT NOT NULL,
    step_order     INT NOT NULL,
    step_name      VARCHAR(100) NOT NULL,
    step_desc      TEXT,
    is_eliminatory BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (company_id) REFERENCES SHIPPING_COMPANIES(company_id) ON DELETE CASCADE
);

-- ─────────────────────────────────────────────
-- TABLE 8: COMPANY_APPROVED_DOCTORS
-- ─────────────────────────────────────────────
CREATE TABLE COMPANY_APPROVED_DOCTORS (
    doctor_id    INT PRIMARY KEY AUTO_INCREMENT,
    company_id   INT NOT NULL,
    doctor_name  VARCHAR(100) NOT NULL,
    clinic_name  VARCHAR(150),
    city         VARCHAR(60)  NOT NULL,
    state        VARCHAR(60),
    contact      VARCHAR(60),
    medical_std  VARCHAR(60),
    FOREIGN KEY (company_id) REFERENCES SHIPPING_COMPANIES(company_id) ON DELETE CASCADE
);

-- ─────────────────────────────────────────────
-- TABLE 9: COMPANY_DEADLINES
-- ─────────────────────────────────────────────
CREATE TABLE COMPANY_DEADLINES (
    deadline_id       INT PRIMARY KEY AUTO_INCREMENT,
    company_id        INT NOT NULL,
    batch_year        INT NOT NULL DEFAULT 2025,
    forms_open_date   DATE,
    forms_close_date  DATE,
    exam_date         DATE,
    interview_month   VARCHAR(30),
    dns_joining_month VARCHAR(30),
    status            VARCHAR(20) NOT NULL DEFAULT 'Upcoming'
                      COMMENT 'Open Now / Upcoming / Closed',
    notes             VARCHAR(300),
    FOREIGN KEY (company_id) REFERENCES SHIPPING_COMPANIES(company_id) ON DELETE CASCADE
);

-- ─────────────────────────────────────────────
-- TABLE 10: COMPANY_FINANCIAL (full financial plan)
-- ─────────────────────────────────────────────
CREATE TABLE COMPANY_FINANCIAL (
    financial_id             INT PRIMARY KEY AUTO_INCREMENT,
    company_id               INT NOT NULL,
    dns_college_fees         DECIMAL(10,2) COMMENT 'Total DNS/BSc college tuition',
    hostel_cost_total        DECIMAL(10,2) COMMENT 'Total hostel for full course',
    food_cost_monthly        DECIMAL(8,2)  DEFAULT 5000,
    uniform_kit_cost         DECIMAL(8,2)  DEFAULT 25000,
    books_cost               DECIMAL(8,2)  DEFAULT 15000,
    imu_cet_exam_cost        DECIMAL(8,2)  DEFAULT 2000,
    company_exam_cost        DECIMAL(8,2)  DEFAULT 0,
    medical_exam_cost        DECIMAL(8,2)  DEFAULT 8000,
    document_cost            DECIMAL(8,2)  DEFAULT 5000  COMMENT 'Passport, CDC, certificates',
    travel_cost              DECIMAL(8,2)  DEFAULT 10000 COMMENT 'Travel to college/interviews',
    miscellaneous            DECIMAL(8,2)  DEFAULT 20000,
    total_investment_approx  DECIMAL(10,2) COMMENT 'Auto-computed total pre-boarding cost',
    dns_stipend_monthly      INT           COMMENT 'Company stipend during DNS',
    onboard_trainee_usd      INT           COMMENT 'USD/month as trainee on ship',
    ship_living_cost_usd     INT           DEFAULT 0    COMMENT 'Cost of living on ship (food/accommodation provided)',
    savings_per_contract_inr DECIMAL(10,2) COMMENT 'Approx savings after one contract',
    third_officer_exam_cost  DECIMAL(8,2)  DEFAULT 80000 COMMENT 'Cost of MMD/CoC exams after contract',
    roi_months               INT           COMMENT 'Months to recover total investment',
    FOREIGN KEY (company_id) REFERENCES SHIPPING_COMPANIES(company_id) ON DELETE CASCADE
);

-- ─────────────────────────────────────────────
-- TABLE 11: COMPANY_SALARY_PROGRESSION
-- ─────────────────────────────────────────────
CREATE TABLE COMPANY_SALARY_PROGRESSION (
    salary_id            INT PRIMARY KEY AUTO_INCREMENT,
    company_id           INT NOT NULL,
    rank_name            VARCHAR(60) NOT NULL,
    salary_usd_month     INT,
    salary_inr_approx    INT,
    years_experience_min INT,
    years_experience_max INT,
    FOREIGN KEY (company_id) REFERENCES SHIPPING_COMPANIES(company_id) ON DELETE CASCADE
);

-- ─────────────────────────────────────────────
-- TABLE 12: STUDENTS
-- ─────────────────────────────────────────────
CREATE TABLE STUDENTS (
    student_id          INT PRIMARY KEY AUTO_INCREMENT,
    name                VARCHAR(80)   NOT NULL,
    email               VARCHAR(100)  UNIQUE NOT NULL,
    password_hash       VARCHAR(255)  NOT NULL,
    phone               VARCHAR(20),
    age                 INT           NOT NULL,
    gender              VARCHAR(15)   NOT NULL,
    city                VARCHAR(60),
    state               VARCHAR(60),
    pincode             VARCHAR(10),
    institute           VARCHAR(100)  NOT NULL,
    academic_pathway    VARCHAR(30)   NOT NULL,
    pcm_percentage      DECIMAL(5,2)  NOT NULL,
    tenth_percentage    DECIMAL(5,2),
    twelfth_percentage  DECIMAL(5,2),
    tenth_english       DECIMAL(5,2),
    twelfth_english     DECIMAL(5,2),
    aggregate_percentage DECIMAL(5,2) COMMENT '(10th+12th)/2',
    imu_cet_rank        INT           UNIQUE,
    eyesight            DECIMAL(3,1)  NOT NULL,
    medical_status      VARCHAR(30)   NOT NULL DEFAULT 'Pending',
    swimming_certified  BOOLEAN       NOT NULL DEFAULT FALSE,
    created_at          DATETIME      DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_pcm     CHECK (pcm_percentage >= 40 AND pcm_percentage <= 100),
    CONSTRAINT chk_age     CHECK (age >= 15 AND age <= 35),
    CONSTRAINT chk_pathway CHECK (academic_pathway IN ('DNS','BSc Nautical Science'))
);

-- ─────────────────────────────────────────────
-- TABLE 13: EXAMS
-- ─────────────────────────────────────────────
CREATE TABLE EXAMS (
    exam_id   INT PRIMARY KEY AUTO_INCREMENT,
    exam_name VARCHAR(80) NOT NULL
);

-- ─────────────────────────────────────────────
-- TABLE 14: EXAM_SCORES
-- ─────────────────────────────────────────────
CREATE TABLE EXAM_SCORES (
    score_id      INT PRIMARY KEY AUTO_INCREMENT,
    student_id    INT NOT NULL,
    exam_id       INT NOT NULL,
    score         INT NOT NULL,
    rank_obtained INT,
    exam_date     DATE,
    FOREIGN KEY (student_id) REFERENCES STUDENTS(student_id) ON DELETE CASCADE,
    FOREIGN KEY (exam_id)    REFERENCES EXAMS(exam_id)
);

-- ─────────────────────────────────────────────
-- TABLE 15: APPLICATIONS
-- ─────────────────────────────────────────────
CREATE TABLE APPLICATIONS (
    application_id     INT PRIMARY KEY AUTO_INCREMENT,
    student_id         INT         NOT NULL,
    company_id         INT         NOT NULL,
    application_status VARCHAR(20) NOT NULL DEFAULT 'Applied',
    interview_date     DATE,
    applied_at         DATETIME    DEFAULT CURRENT_TIMESTAMP,
    notes              TEXT,
    FOREIGN KEY (student_id) REFERENCES STUDENTS(student_id) ON DELETE CASCADE,
    FOREIGN KEY (company_id) REFERENCES SHIPPING_COMPANIES(company_id) ON DELETE CASCADE,
    UNIQUE KEY unique_application (student_id, company_id),
    CONSTRAINT chk_appstatus CHECK (application_status IN ('Applied','Under Review','Selected','Rejected'))
);

-- ─────────────────────────────────────────────
-- TABLE 16: INTERVIEWS
-- ─────────────────────────────────────────────
CREATE TABLE INTERVIEWS (
    interview_id   INT PRIMARY KEY AUTO_INCREMENT,
    application_id INT         NOT NULL,
    interview_type VARCHAR(30) NOT NULL,
    result         VARCHAR(20) NOT NULL DEFAULT 'Pending',
    interview_date DATE,
    FOREIGN KEY (application_id) REFERENCES APPLICATIONS(application_id) ON DELETE CASCADE
);

-- ─────────────────────────────────────────────
-- TABLE 17: DOCUMENTS
-- ─────────────────────────────────────────────
CREATE TABLE DOCUMENTS (
    document_id   INT PRIMARY KEY AUTO_INCREMENT,
    document_name VARCHAR(100) NOT NULL,
    is_mandatory  BOOLEAN DEFAULT TRUE,
    description   VARCHAR(200)
);

-- ─────────────────────────────────────────────
-- TABLE 18: STUDENT_DOCUMENTS
-- ─────────────────────────────────────────────
CREATE TABLE STUDENT_DOCUMENTS (
    record_id           INT PRIMARY KEY AUTO_INCREMENT,
    student_id          INT         NOT NULL,
    document_id         INT         NOT NULL,
    company_id          INT,
    file_path           VARCHAR(500),
    file_name           VARCHAR(200),
    verification_status VARCHAR(20) NOT NULL DEFAULT 'Pending',
    submitted_at        DATETIME    DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id)  REFERENCES STUDENTS(student_id) ON DELETE CASCADE,
    FOREIGN KEY (document_id) REFERENCES DOCUMENTS(document_id),
    FOREIGN KEY (company_id)  REFERENCES SHIPPING_COMPANIES(company_id) ON DELETE SET NULL,
    CONSTRAINT chk_vstatus CHECK (verification_status IN ('Pending','Verified','Rejected'))
);

-- ─────────────────────────────────────────────
-- TABLE 19: APPLICATION_LOG
-- ─────────────────────────────────────────────
CREATE TABLE APPLICATION_LOG (
    log_id         INT AUTO_INCREMENT PRIMARY KEY,
    application_id INT,
    action         VARCHAR(80),
    log_date       DATETIME DEFAULT CURRENT_TIMESTAMP
);

SET FOREIGN_KEY_CHECKS = 1;

-- ================================================================
-- TRIGGERS
-- ================================================================
DROP TRIGGER IF EXISTS check_pcm_trigger;
DELIMITER //
CREATE TRIGGER check_pcm_trigger BEFORE INSERT ON STUDENTS FOR EACH ROW
BEGIN
    IF NEW.pcm_percentage < 40 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'PCM percentage must be at least 40%.';
    END IF;
    IF NEW.tenth_percentage IS NOT NULL AND NEW.twelfth_percentage IS NOT NULL THEN
        SET NEW.aggregate_percentage = (NEW.tenth_percentage + NEW.twelfth_percentage) / 2;
    END IF;
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS log_application;
DELIMITER //
CREATE TRIGGER log_application AFTER INSERT ON APPLICATIONS FOR EACH ROW
BEGIN
    INSERT INTO APPLICATION_LOG(application_id, action) VALUES (NEW.application_id, 'APPLICATION_CREATED');
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS update_status_on_interview;
DELIMITER //
CREATE TRIGGER update_status_on_interview AFTER INSERT ON INTERVIEWS FOR EACH ROW
BEGIN
    IF NEW.result = 'Passed' THEN
        UPDATE APPLICATIONS SET application_status = 'Selected' WHERE application_id = NEW.application_id;
    ELSEIF NEW.result = 'Failed' THEN
        UPDATE APPLICATIONS SET application_status = 'Rejected' WHERE application_id = NEW.application_id;
    END IF;
END;//
DELIMITER ;

-- ================================================================
-- VIEWS
-- ================================================================
CREATE OR REPLACE VIEW eligible_students AS
SELECT name, pcm_percentage FROM STUDENTS WHERE pcm_percentage >= 60;

CREATE OR REPLACE VIEW application_summary AS
SELECT application_status, COUNT(*) AS total FROM APPLICATIONS GROUP BY application_status;

-- ================================================================
-- SHIP TYPES
-- ================================================================
INSERT INTO SHIP_TYPES (ship_type_name, description) VALUES
('Bulk Carrier',      'Transports unpackaged bulk cargo like grain, coal, ore'),
('Oil Tanker',        'Carries crude oil and petroleum products'),
('Container Ship',    'Transports goods in intermodal containers'),
('LNG Carrier',       'Liquefied Natural Gas tankers'),
('LPG Carrier',       'Liquefied Petroleum Gas tankers'),
('Chemical Tanker',   'Carries chemicals and liquid cargo'),
('VLCC/ULCC Tanker',  'Very/Ultra Large Crude Carriers'),
('Car Carrier (PCTC)','Pure Car and Truck Carriers'),
('RORO Vessel',       'Roll-On Roll-Off vehicle vessels'),
('General Cargo',     'General purpose cargo vessels'),
('Offshore Vessel',   'Platform supply and anchor handling'),
('Multipurpose',      'Multi-purpose cargo vessels');

-- ================================================================
-- COLLEGES
-- ================================================================
INSERT INTO COLLEGES (college_name, location, course_type, imu_cet_cutoff_rank, fee_structure, duration_months, hostel_cost_monthly, female_scholarship_available, approved_by) VALUES
('MERI Mumbai',                      'Mumbai, Maharashtra',      'BSc Nautical Science', 500,  875000, 36, 8000,  TRUE,  'DG Shipping'),
('Tolani Maritime Institute',        'Pune, Maharashtra',        'BSc Nautical Science', 800,  950000, 36, 9500,  TRUE,  'DG Shipping / IMU'),
('SCI Training Centre',              'Mumbai, Maharashtra',      'DNS',                  1200, 650000, 12, 7000,  FALSE, 'DG Shipping'),
('Samundra Institute of Maritime Studies', 'Mumbai, Maharashtra','DNS',                  1500, 720000, 12, 7500,  TRUE,  'DG Shipping'),
('IMU Chennai (Main Campus)',        'Chennai, Tamil Nadu',      'BSc Nautical Science', 400,  790000, 36, 8500,  TRUE,  'IMU'),
('HIMT College',                     'Greater Noida, UP',        'DNS',                  2000, 590000, 12, 6000,  FALSE, 'DG Shipping'),
('Anglo Eastern Maritime Academy',   'Mumbai, Maharashtra',      'DNS',                  1000, 680000, 12, 7500,  TRUE,  'DG Shipping'),
('Vels University Maritime',         'Chennai, Tamil Nadu',      'BSc Nautical Science', 1800, 720000, 36, 7000,  FALSE, 'DG Shipping'),
('AMET University',                  'Chennai, Tamil Nadu',      'BSc Nautical Science', 1600, 760000, 36, 7200,  TRUE,  'IMU'),
('MSTC Kolkata',                     'Kolkata, West Bengal',     'DNS',                  2500, 560000, 12, 6500,  FALSE, 'DG Shipping'),
('Coimbatore Marine College',        'Coimbatore, Tamil Nadu',   'DNS',                  3000, 520000, 12, 5500,  FALSE, 'DG Shipping'),
('Maharashtra Maritime Training Inst','Pune, Maharashtra',       'DNS',                  2800, 540000, 12, 6000,  FALSE, 'DG Shipping');

-- ================================================================
-- SHIPPING COMPANIES (30 companies)
-- ================================================================
INSERT INTO SHIPPING_COMPANIES (company_name, country, hq_city, india_office, stipend_dns, stipend_onboard_trainee, bond_years, promotion_period_years, minimum_contract_months, maximum_contract_months, waiting_period_months, tax_policy, female_crew_policy, company_description, website, total_fleet_size) VALUES
-- 1
('Maersk Line',             'Denmark',      'Copenhagen',  'Mumbai',       45000, 1200, 3, 4, 4, 8, 4,  'Tax-Free', 'Accepted',      'World''s largest container shipping company with 700+ vessels globally.',          'www.maersk.com',           730),
-- 2
('Anglo-Eastern Ship Mgmt', 'Hong Kong',    'Hong Kong',   'Mumbai',       40000, 900,  3, 4, 4, 9, 5,  'Tax-Free', 'Accepted',      'One of the largest ship management companies managing 600+ vessels.',             'www.angloeastern.com',     620),
-- 3
('Synergy Marine Group',    'Singapore',    'Singapore',   'Mumbai',       38000, 950,  3, 4, 4, 8, 5,  'Tax-Free', 'Accepted',      'Leading ship management company with strong focus on Indian officers.',           'www.synergymarine.com',    380),
-- 4
('BW Group',                'Singapore',    'Singapore',   'Mumbai',       42000, 1100, 3, 5, 4, 9, 6,  'Tax-Free', 'Accepted',      'Global maritime company specializing in LNG, LPG, oil tankers.',                 'www.bw-group.com',         440),
-- 5
('OSM Thome',               'Norway',       'Arendal',     'Mumbai',       38000, 1000, 3, 5, 4, 8, 5,  'Tax-Free', 'Accepted',      'Merged entity of OSM Maritime and Thome Group — 470+ vessels.',                  'www.osmthome.com',         470),
-- 6
('Grieg Star / Grieg Eastern','Norway',     'Bergen',      'Mumbai',       36000, 900,  3, 5, 4, 9, 6,  'Tax-Free', 'Limited',       'Open hatch bulker specialist with fleet across Pacific trades.',                  'www.griegstar.com',        130),
-- 7
('MOL (Mitsui OSK Lines)',  'Japan',        'Tokyo',       'Mumbai',       40000, 1050, 4, 5, 4, 8, 6,  'Tax-Free', 'Accepted',      'Japanese giant operating bulk, container, tanker and LNG fleet.',                'www.mol.co.jp',            800),
-- 8
('Columbia Shipmanagement', 'Cyprus',       'Limassol',    'Mumbai',       37000, 950,  3, 4, 4, 8, 5,  'Tax-Free', 'Accepted',      'Top-10 ship manager operating 400+ vessels of all types.',                       'www.columbia-shipmanagement.com', 420),
-- 9
('BSM (Bernhard Schulte)',  'Germany',      'Hamburg',     'Mumbai',       39000, 1000, 3, 4, 4, 9, 5,  'Tax-Free', 'Accepted',      'Bernhard Schulte Shipmanagement — 650+ vessels, major Indian employer.',          'www.bs-shipmanagement.com',650),
-- 10
('V.Ships',                 'Monaco',       'Monaco',      'Mumbai',       36000, 900,  3, 5, 3, 8, 5,  'Tax-Free', 'Limited',       'One of world''s largest ship managers with 950+ vessels.',                       'www.vships.com',           960),
-- 11
('Fleet Management Ltd',    'Hong Kong',    'Hong Kong',   'Mumbai',       38000, 950,  3, 4, 4, 8, 5,  'Tax-Free', 'Accepted',      'Fuzhou-based manager operating 600+ vessels, huge Indian officer base.',          'www.fleet.com.hk',         640),
-- 12
('Scorpio Group',           'Monaco',       'Monaco',      'Mumbai',       35000, 900,  2, 3, 3, 6, 4,  'Taxable',  'Limited',       'Leading product tanker and bulker owner with 200+ vessels.',                     'www.scorpiogroup.net',     210),
-- 13
('Stena Line / Stena Bulk', 'Sweden',       'Gothenburg',  'Mumbai',       40000, 1000, 3, 4, 4, 8, 5,  'Tax-Free', 'Accepted',      'Swedish conglomerate with VLCC, MR tankers and ferry operations.',               'www.stenabulk.com',        170),
-- 14
('Thome Group',             'Singapore',    'Singapore',   'Mumbai',       37000, 950,  3, 4, 4, 8, 5,  'Tax-Free', 'Accepted',      'Thome Ship Management — specialized in tanker and gas operations.',              'www.thome.com.sg',         280),
-- 15
('Chevron Shipping',        'USA',          'San Ramon CA','Mumbai',       50000, 1500, 4, 5, 4, 8, 6,  'Tax-Free', 'Accepted',      'Chevron''s in-house fleet of VLCC and LNG carriers — highest stipend.',          'www.chevron.com',          40),
-- 16
('NYK Line',                'Japan',        'Tokyo',       'Mumbai',       41000, 1100, 4, 5, 4, 9, 6,  'Tax-Free', 'Accepted',      'Nippon Yusen Kaisha — Japanese giant in LNG, bulk and container.',               'www.nyk.com',              750),
-- 17
('COSCO Shipping',          'China',        'Shanghai',    'Mumbai',       35000, 850,  3, 5, 4, 9, 6,  'Taxable',  'Limited',       'Chinese state-owned shipping giant — largest fleet worldwide.',                   'www.coscoshipping.com',    1300),
-- 18
('Evergreen Marine Corp',   'Taiwan',       'Taipei',      'Mumbai',       36000, 900,  3, 4, 4, 9, 5,  'Tax-Free', 'Limited',       'Taiwanese container shipping leader with 200+ vessels.',                         'www.evergreen-marine.com', 200),
-- 19
('ONE (Ocean Network Express)', 'Japan',    'Tokyo',       'Mumbai',       38000, 950,  3, 4, 4, 8, 5,  'Tax-Free', 'Accepted',      'Joint venture of K-Line, MOL, NYK — 240+ container ships.',                     'www.one-line.com',         240),
-- 20
('HMM (Hyundai Merchant Marine)', 'South Korea', 'Seoul', 'Mumbai',       36000, 900,  3, 4, 4, 9, 6,  'Tax-Free', 'Limited',       'South Korean container giant — ultra-large container ships.',                     'www.hmm21.com',            130),
-- 21
('Great Eastern Shipping',  'India',        'Mumbai',      'Mumbai',       32000, 800,  4, 5, 4, 9, 3,  'Taxable',  'Not Accepted',  'India''s largest private shipping company — tankers and bulk.',                  'www.greatship.com',        50),
-- 22
('Wallem Group',            'Hong Kong',    'Hong Kong',   'Mumbai',       38000, 950,  3, 4, 3, 7, 5,  'Tax-Free', 'Accepted',      'Wallem Shipmanagement — diverse fleet including gas, tankers, bulk.',            'www.wallem.com',           130),
-- 23
('MSC Mediterranean',       'Switzerland',  'Geneva',      'Mumbai',       42000, 1100, 3, 5, 4, 9, 5,  'Tax-Free', 'Accepted',      'World''s second largest container line — 700+ vessels.',                         'www.msc.com',              730),
-- 24
('TSM (Transocean Ship Mgmt)', 'India',     'Mumbai',      'Mumbai',       30000, 750,  3, 4, 4, 8, 4,  'Taxable',  'Limited',       'Transocean Ship Management — mid-tier Indian company, entry-level friendly.',   'www.transocean.com',       80),
-- 25
('CMA CGM Group',           'France',       'Marseille',   'Mumbai',       40000, 1050, 3, 4, 4, 8, 5,  'Tax-Free', 'Accepted',      'Third largest container shipping company — 550+ vessels.',                       'www.cmacgm.com',           560),
-- 26
('Hang Wing MT (HWMT)',     'Hong Kong',    'Hong Kong',   'Mumbai',       34000, 850,  3, 4, 4, 8, 5,  'Tax-Free', 'Limited',       'Specialized in bulk carriers and tankers across Asia-Pacific routes.',           'www.hangwingmt.com',       90),
-- 27
('HYP Maritime',            'Singapore',    'Singapore',   'Mumbai',       33000, 820,  3, 4, 3, 7, 4,  'Tax-Free', 'Limited',       'HYP Maritime — growing ship management company with tanker focus.',              'www.hypmaritime.com',      70),
-- 28
('Como Shipping',           'Italy',        'Genoa',       'Mumbai',       35000, 880,  3, 5, 4, 8, 5,  'Taxable',  'Limited',       'Italian shipping company — bulk and general cargo focus.',                       'www.como-shipping.com',    60),
-- 29
('Lloyd Shipping',          'Germany',      'Bremen',      'Mumbai',       37000, 920,  3, 4, 4, 8, 5,  'Tax-Free', 'Accepted',      'Bremen-based ship management with tanker and bulk fleet.',                       'www.lloyd-shipping.com',   100),
-- 30
('CMG Maritime',            'India',        'Mumbai',      'Mumbai',       28000, 700,  3, 4, 3, 8, 3,  'Taxable',  'Accepted',      'CMG Maritime — entry-level friendly Indian company, good for freshers.',         'www.cmgmaritime.com',      45);

-- ================================================================
-- SPONSORSHIP REQUIREMENTS (30 companies)
-- ================================================================
INSERT INTO SPONSORSHIP_REQUIREMENTS (company_id, min_pcm, max_eye_power, swimming_required, medical_standard, accepts_pending_medical, imu_cet_required, own_cbt_test, psychometric_test, min_10th_percentage, min_12th_percentage, min_10th_english, min_12th_english, min_aggregate, age_min, age_max, accepts_dns, accepts_bsc, additional_notes) VALUES
(1,  60.0, 2.5, TRUE,  'ENG1',          FALSE, TRUE,  TRUE,  TRUE,  60.0, 60.0, 50.0, 50.0, 60.0, 17, 25, TRUE,  TRUE,  'IMU-CET rank must be within top 1000. Company CBT test is online.'),
(2,  55.0, 3.0, TRUE,  'ENG1',          TRUE,  FALSE, TRUE,  TRUE,  55.0, 55.0, 45.0, 45.0, 55.0, 17, 26, TRUE,  TRUE,  'Pending medical accepted if ENG1 completed before joining. Own CBT + GD + HR interview.'),
(3,  55.0, 3.0, TRUE,  'ENG1',          TRUE,  TRUE,  FALSE, TRUE,  55.0, 55.0, 45.0, 45.0, 55.0, 17, 25, TRUE,  TRUE,  'IMU-CET + medical + psychometric + HR. Pending medical OK if cleared within 60 days.'),
(4,  60.0, 2.5, TRUE,  'ENG1',          FALSE, TRUE,  TRUE,  TRUE,  60.0, 60.0, 50.0, 50.0, 60.0, 17, 25, FALSE, TRUE,  'BSc Nautical Science preferred. LNG tanker specialization available.'),
(5,  55.0, 3.0, FALSE, 'ENG1',          TRUE,  FALSE, TRUE,  TRUE,  55.0, 55.0, 45.0, 45.0, 55.0, 17, 26, TRUE,  TRUE,  'Swimming not required. Medical pending OK. Own aptitude + psychometric test.'),
(6,  60.0, 2.5, TRUE,  'ENG1',          FALSE, TRUE,  FALSE, TRUE,  60.0, 60.0, 50.0, 50.0, 60.0, 17, 25, FALSE, TRUE,  'Open hatch bulk specialists. BSc NS preferred. Psychometric mandatory.'),
(7,  62.0, 2.0, TRUE,  'STCW Medical',  FALSE, TRUE,  TRUE,  TRUE,  62.0, 62.0, 55.0, 55.0, 62.0, 17, 25, FALSE, TRUE,  'Written CBT + psychometric + 3-stage interview. Japanese management style.'),
(8,  55.0, 3.0, FALSE, 'ENG1',          TRUE,  FALSE, TRUE,  TRUE,  55.0, 55.0, 45.0, 45.0, 55.0, 17, 26, TRUE,  TRUE,  'Diverse fleet. Pending medical OK. Own aptitude test. Good for average profile.'),
(9,  58.0, 2.5, TRUE,  'ENG1',          TRUE,  FALSE, TRUE,  TRUE,  58.0, 58.0, 48.0, 48.0, 58.0, 17, 25, TRUE,  TRUE,  'BSM runs own sponsorship exam. Pending medical acceptable. Major Indian employer.'),
(10, 50.0, 3.5, FALSE, 'STCW Medical',  TRUE,  FALSE, FALSE, TRUE,  50.0, 50.0, 40.0, 40.0, 50.0, 17, 27, TRUE,  TRUE,  'Most flexible criteria. Pending medical OK. No swimming required. Good for lower PCM.'),
(11, 55.0, 3.0, FALSE, 'ENG1',          TRUE,  FALSE, TRUE,  TRUE,  55.0, 55.0, 45.0, 45.0, 55.0, 17, 26, TRUE,  TRUE,  'Fleet Management own test + interview. Pending medical OK. Good company for freshers.'),
(12, 60.0, 2.0, FALSE, 'ML-5',          FALSE, FALSE, TRUE,  FALSE, 60.0, 60.0, 50.0, 50.0, 60.0, 17, 25, TRUE,  FALSE, 'DNS only. No psychometric. Own aptitude test. Strict eyesight norms.'),
(13, 58.0, 3.0, TRUE,  'ENG1',          FALSE, FALSE, TRUE,  TRUE,  58.0, 58.0, 48.0, 48.0, 58.0, 17, 25, TRUE,  TRUE,  'VLCC / MR tanker division. Written + technical interview + medical.'),
(14, 55.0, 3.0, FALSE, 'ENG1',          TRUE,  FALSE, TRUE,  TRUE,  55.0, 55.0, 45.0, 45.0, 55.0, 17, 26, TRUE,  TRUE,  'Thome own aptitude test. Pending medical OK. Gas tanker training available.'),
(15, 75.0, 1.5, TRUE,  'USCG Medical',  FALSE, TRUE,  TRUE,  TRUE,  75.0, 75.0, 65.0, 65.0, 75.0, 18, 24, FALSE, TRUE,  'Chevron — highest standards in industry. USCG medical. Top IMU-CET rank needed.'),
(16, 62.0, 2.0, TRUE,  'STCW Medical',  FALSE, TRUE,  TRUE,  TRUE,  62.0, 62.0, 55.0, 55.0, 62.0, 17, 25, FALSE, TRUE,  'NYK own CBT + group discussion + HR. LNG fleet specialization.'),
(17, 55.0, 3.5, FALSE, 'STCW Medical',  TRUE,  FALSE, TRUE,  FALSE, 55.0, 55.0, 45.0, 45.0, 55.0, 17, 27, TRUE,  TRUE,  'COSCO own test. Pending medical accepted. Most flexible eye power norm.'),
(18, 58.0, 3.0, FALSE, 'STCW Medical',  FALSE, FALSE, TRUE,  TRUE,  58.0, 58.0, 48.0, 48.0, 58.0, 17, 26, TRUE,  TRUE,  'Evergreen aptitude + interview. Container ship specialists.'),
(19, 58.0, 2.5, TRUE,  'ENG1',          FALSE, FALSE, TRUE,  TRUE,  58.0, 58.0, 48.0, 48.0, 58.0, 17, 25, TRUE,  TRUE,  'ONE (K-Line/MOL/NYK JV). Own aptitude test + technical + HR interview.'),
(20, 60.0, 2.5, FALSE, 'STCW Medical',  FALSE, FALSE, TRUE,  TRUE,  60.0, 60.0, 50.0, 50.0, 60.0, 17, 25, FALSE, TRUE,  'HMM runs own sponsorship exam. BSc NS preferred. Ultra-large container ships.'),
(21, 65.0, 2.0, TRUE,  'INDOS Medical', FALSE, TRUE,  FALSE, FALSE, 65.0, 65.0, 55.0, 55.0, 65.0, 17, 25, TRUE,  FALSE, 'Great Eastern — Indian company, DNS only, IMU-CET mandatory. Strict eyesight.'),
(22, 52.0, 3.5, FALSE, 'ENG1',          TRUE,  FALSE, TRUE,  TRUE,  52.0, 52.0, 42.0, 42.0, 52.0, 17, 27, TRUE,  TRUE,  'Wallem own test. Very flexible criteria. Pending medical OK. Good entry point.'),
(23, 58.0, 2.5, TRUE,  'ENG1',          FALSE, TRUE,  TRUE,  TRUE,  58.0, 58.0, 48.0, 48.0, 58.0, 17, 25, TRUE,  TRUE,  'MSC own CBT + IMU-CET. Large container fleet. Technical + HR interview.'),
(24, 45.0, 4.0, FALSE, 'STCW Medical',  TRUE,  FALSE, FALSE, FALSE, 45.0, 45.0, 35.0, 35.0, 45.0, 17, 28, TRUE,  FALSE, 'TSM — most entry-level friendly. Very low criteria. Pending medical OK. DNS only.'),
(25, 58.0, 2.5, TRUE,  'ENG1',          FALSE, FALSE, TRUE,  TRUE,  58.0, 58.0, 48.0, 48.0, 58.0, 17, 25, TRUE,  TRUE,  'CMA CGM aptitude test + technical interview. French company culture.'),
(26, 52.0, 3.5, FALSE, 'STCW Medical',  TRUE,  FALSE, TRUE,  FALSE, 52.0, 52.0, 42.0, 42.0, 52.0, 17, 27, TRUE,  TRUE,  'Hang Wing own test. Bulk/tanker. Pending medical OK. Flexible criteria.'),
(27, 50.0, 3.5, FALSE, 'STCW Medical',  TRUE,  FALSE, TRUE,  FALSE, 50.0, 50.0, 40.0, 40.0, 50.0, 17, 27, TRUE,  TRUE,  'HYP Maritime — entry-level. Low PCM cutoff. Tanker focus. Pending medical OK.'),
(28, 55.0, 3.0, FALSE, 'MCA Medical',   FALSE, FALSE, TRUE,  FALSE, 55.0, 55.0, 45.0, 45.0, 55.0, 17, 26, TRUE,  TRUE,  'Como — Italian company. Bulk/general cargo. Own aptitude test.'),
(29, 55.0, 3.0, TRUE,  'ENG1',          FALSE, FALSE, TRUE,  TRUE,  55.0, 55.0, 45.0, 45.0, 55.0, 17, 26, TRUE,  TRUE,  'Lloyd aptitude + interview. Tanker and bulk. Swimming required.'),
(30, 42.0, 4.5, FALSE, 'STCW Medical',  TRUE,  FALSE, FALSE, FALSE, 42.0, 42.0, 35.0, 35.0, 42.0, 17, 28, TRUE,  FALSE, 'CMG Maritime — lowest entry barrier. DNS only. Great for lower academic profiles.');

-- ================================================================
-- COMPANY FLEET
-- ================================================================
INSERT INTO COMPANY_FLEET (company_id, ship_type_id, number_of_ships) VALUES
-- Maersk
(1,3,650),(1,1,40),(1,10,40),
-- Anglo-Eastern
(2,2,120),(2,1,180),(2,3,150),(2,6,80),(2,4,50),(2,10,40),
-- Synergy
(3,2,100),(3,1,120),(3,3,80),(3,6,50),(3,5,30),
-- BW Group
(4,4,80),(4,5,60),(4,2,150),(4,7,50),(4,6,100),
-- OSM Thome
(5,2,120),(5,1,140),(5,3,100),(5,6,60),(5,4,30),(5,10,20),
-- Grieg
(6,1,110),(6,10,20),
-- MOL
(7,1,250),(7,3,200),(7,4,80),(7,2,150),(7,8,70),(7,5,50),
-- Columbia
(8,2,100),(8,1,120),(8,3,90),(8,6,60),(8,4,20),(8,10,30),
-- BSM
(9,2,180),(9,1,200),(9,3,120),(9,6,80),(9,4,40),(9,5,30),
-- V.Ships
(10,2,250),(10,1,280),(10,3,200),(10,6,100),(10,4,60),(10,8,30),(10,10,40),
-- Fleet Management
(11,2,180),(11,1,200),(11,3,150),(11,6,60),(11,4,30),(11,10,20),
-- Scorpio
(12,2,120),(12,1,80),(12,6,10),
-- Stena
(13,7,40),(13,2,80),(13,9,50),
-- Thome
(14,4,80),(14,5,60),(14,2,100),(14,6,40),
-- Chevron
(15,7,20),(15,4,20),
-- NYK
(16,1,250),(16,3,150),(16,4,100),(16,2,150),(16,8,60),(16,5,40),
-- COSCO
(17,3,400),(17,1,350),(17,2,250),(17,7,100),(17,8,60),(17,10,140),
-- Evergreen
(18,3,200),
-- ONE
(19,3,240),
-- HMM
(20,3,130),
-- Great Eastern
(21,2,30),(21,1,20),
-- Wallem
(22,2,50),(22,1,30),(22,4,20),(22,6,15),(22,3,15),
-- MSC
(23,3,700),(23,2,30),
-- TSM
(24,2,40),(24,1,30),(24,10,10),
-- CMA CGM
(25,3,500),(25,6,30),(25,10,30),
-- Hang Wing
(26,1,60),(26,2,30),
-- HYP
(27,2,50),(27,6,20),
-- Como
(28,1,40),(28,10,20),
-- Lloyd
(29,2,60),(29,1,40),
-- CMG
(30,1,30),(30,10,15);

-- ================================================================
-- COMPANY ↔ COLLEGE
-- ================================================================
INSERT INTO COMPANY_COLLEGE (company_id, college_id, is_preferred) VALUES
(1,1,TRUE),(1,2,FALSE),(1,5,TRUE),(1,7,FALSE),
(2,7,TRUE),(2,1,TRUE),(2,4,FALSE),(2,5,FALSE),
(3,2,TRUE),(3,5,TRUE),(3,4,FALSE),
(4,1,TRUE),(4,5,TRUE),(4,2,FALSE),
(5,2,TRUE),(5,1,FALSE),(5,5,FALSE),(5,4,FALSE),
(6,1,TRUE),(6,5,FALSE),
(7,5,TRUE),(7,1,TRUE),(7,2,FALSE),
(8,1,TRUE),(8,4,TRUE),(8,7,FALSE),(8,5,FALSE),
(9,1,TRUE),(9,2,TRUE),(9,5,FALSE),(9,4,FALSE),(9,7,FALSE),
(10,3,TRUE),(10,6,TRUE),(10,4,FALSE),(10,7,FALSE),(10,10,FALSE),
(11,4,TRUE),(11,7,TRUE),(11,1,FALSE),(11,5,FALSE),
(12,3,TRUE),(12,6,FALSE),
(13,1,TRUE),(13,5,FALSE),
(14,4,TRUE),(14,7,FALSE),(14,5,FALSE),
(15,5,TRUE),(15,1,TRUE),
(16,5,TRUE),(16,1,TRUE),(16,2,FALSE),
(17,5,FALSE),(17,10,TRUE),(17,6,FALSE),
(18,5,FALSE),(18,8,TRUE),(18,9,FALSE),
(19,5,TRUE),(19,1,FALSE),(19,2,FALSE),
(20,5,FALSE),(20,8,TRUE),
(21,3,TRUE),(21,4,FALSE),
(22,1,FALSE),(22,7,TRUE),(22,4,FALSE),
(23,1,TRUE),(23,5,FALSE),(23,7,FALSE),
(24,6,TRUE),(24,10,TRUE),(24,11,FALSE),(24,12,FALSE),
(25,1,TRUE),(25,5,FALSE),(25,2,FALSE),
(26,10,TRUE),(26,7,FALSE),
(27,10,FALSE),(27,6,TRUE),
(28,10,FALSE),(28,11,TRUE),
(29,4,TRUE),(29,7,FALSE),
(30,6,TRUE),(30,11,TRUE),(30,12,TRUE);

-- ================================================================
-- SELECTION PROCESS (key companies)
-- ================================================================
INSERT INTO COMPANY_SELECTION_PROCESS (company_id, step_order, step_name, step_desc, is_eliminatory) VALUES
-- Maersk (1)
(1,1,'Application Form','Online application with documents upload',FALSE),
(1,2,'IMU-CET Score','Must qualify with rank within 1000',TRUE),
(1,3,'Maersk Online CBT','Aptitude + English + Maritime GK online test (90 min)',TRUE),
(1,4,'Psychometric Assessment','Online personality + cognitive assessment',FALSE),
(1,5,'Technical Interview','Panel interview — physics, maths, awareness',TRUE),
(1,6,'HR Interview','Culture fit, motivation, communication',TRUE),
(1,7,'Medical Examination','ENG1 medical at approved doctor',TRUE),
(1,8,'Document Verification','All original documents checked',TRUE),
(1,9,'Final Offer + College Allotment','Allotted to MERI/TMI/IMU Chennai',FALSE),
-- Anglo-Eastern (2)
(2,1,'Application Form','Online portal application',FALSE),
(2,2,'Anglo-Eastern CBT','Online aptitude test: maths, English, reasoning (60 min)',TRUE),
(2,3,'Group Discussion','GD on maritime/current affairs topics',FALSE),
(2,4,'Technical + HR Interview','Panel interview + personality assessment',TRUE),
(2,5,'Medical Examination','ENG1 or pending clearance accepted',TRUE),
(2,6,'Document Verification','Originals verified at Mumbai office',TRUE),
(2,7,'College Allotment','Sent to Anglo-Eastern Academy Mumbai or partner college',FALSE),
-- Synergy (3)
(3,1,'IMU-CET Application','Register via IMU-CET',FALSE),
(3,2,'Synergy Aptitude Test','Online: maths + reasoning + English',TRUE),
(3,3,'Psychometric Test','Online personality profiling',FALSE),
(3,4,'HR Interview','Video/in-person HR round',TRUE),
(3,5,'Medical','ENG1 — pending OK if cleared in 60 days',TRUE),
(3,6,'College Joining','Allotted to Samundra/Tolani/IMU Chennai',FALSE),
-- Chevron (15)
(15,1,'Online Application','Competitive online application',FALSE),
(15,2,'IMU-CET Score','Top 200 rank needed',TRUE),
(15,3,'Chevron Written Test','Advanced maths, physics, marine awareness',TRUE),
(15,4,'Psychometric','Advanced personality + IQ profiling',TRUE),
(15,5,'Technical Interview','Senior officers panel — very detailed',TRUE),
(15,6,'HR + Management Interview','Director-level HR panel',TRUE),
(15,7,'USCG Medical','Strict US Coast Guard medical standard',TRUE),
(15,8,'Background Check','Full background and reference check',FALSE),
(15,9,'Offer + MERI/IMU Allotment','Top tier college allotment',FALSE),
-- TSM/CMG (entry level)
(24,1,'Application Form','Paper/email application',FALSE),
(24,2,'Basic Aptitude Test','Simple maths + English (optional for some batches)',FALSE),
(24,3,'Interview','Informal HR interview',FALSE),
(24,4,'Medical','STCW medical — pending OK',TRUE),
(24,5,'College Joining','Allotted to HIMT/Coimbatore/MSTC',FALSE),
(30,1,'Application Form','Direct application to company',FALSE),
(30,2,'Basic Interview','Simple motivation + communication check',FALSE),
(30,3,'Medical','STCW medical — pending accepted',TRUE),
(30,4,'College Joining','Allotted to Coimbatore/HIMT/Maharashtra MTI',FALSE);

-- ================================================================
-- APPROVED DOCTORS (medical centres for pending candidates)
-- ================================================================
INSERT INTO COMPANY_APPROVED_DOCTORS (company_id, doctor_name, clinic_name, city, state, contact, medical_std) VALUES
-- Maersk
(1,'Dr. P. Raghunath','Maritime Medical Centre','Mumbai','Maharashtra','022-22001234','ENG1'),
(1,'Dr. Suresh Nair','Nair Maritime Health','Kochi','Kerala','0484-2345678','ENG1'),
(1,'Dr. Amit Sharma','Delhi Maritime Clinic','New Delhi','Delhi','011-23456789','ENG1'),
-- Anglo-Eastern
(2,'Dr. Ramesh Iyer','Anglo-Eastern Approved Clinic','Mumbai','Maharashtra','022-22223333','ENG1'),
(2,'Dr. S. Krishnamurthy','Chennai Maritime Health','Chennai','Tamil Nadu','044-27654321','ENG1'),
(2,'Dr. Priya Singh','Kolkata Seafarers Clinic','Kolkata','West Bengal','033-22345678','ENG1'),
-- Synergy
(3,'Dr. M. Verma','Synergy Medical Pvt Ltd','Mumbai','Maharashtra','022-44455566','ENG1'),
(3,'Dr. K. Reddy','Hyderabad Maritime Clinic','Hyderabad','Telangana','040-23456789','ENG1'),
-- BSM
(9,'Dr. N. Pillai','BSM Approved Health Centre','Mumbai','Maharashtra','022-55566677','ENG1'),
(9,'Dr. R. Sharma','North India Maritime Medical','Delhi','Delhi','011-34567890','ENG1'),
-- V.Ships (most flexible)
(10,'Dr. A. Kumar','STCW Medical Hub Mumbai','Mumbai','Maharashtra','022-66677788','STCW'),
(10,'Dr. S. Patel','Gujarat Maritime Clinic','Ahmedabad','Gujarat','079-23456789','STCW'),
(10,'Dr. T. Rao','AP Maritime Health','Visakhapatnam','Andhra Pradesh','0891-2345678','STCW'),
-- TSM
(24,'Dr. Local GP','Any STCW Approved Doctor','All Cities','PAN India','Refer DGS List','STCW'),
-- CMG
(30,'Dr. Local GP','Any STCW Approved Doctor','All Cities','PAN India','Refer DGS List','STCW');

-- ================================================================
-- DEADLINES (2025-2026 batch)
-- ================================================================
INSERT INTO COMPANY_DEADLINES (company_id, batch_year, forms_open_date, forms_close_date, exam_date, interview_month, dns_joining_month, status, notes) VALUES
(1,  2025, '2025-06-01', '2025-07-31', '2025-08-20', 'September 2025',  'January 2026',  'Open Now',  'Maersk accepts 2025-26 DNS batch applications'),
(2,  2025, '2025-05-15', '2025-07-15', '2025-07-30', 'August 2025',    'January 2026',  'Open Now',  'Anglo-Eastern CBT online at any centre'),
(3,  2025, '2025-07-01', '2025-08-31', '2025-09-15', 'October 2025',   'February 2026', 'Open Now',  'Synergy accepts IMU-CET results directly'),
(4,  2025, '2025-07-01', '2025-08-15', '2025-09-01', 'September 2025', 'January 2026',  'Open Now',  'BW Group — BSc NS preferred batch'),
(5,  2025, '2025-06-15', '2025-08-15', '2025-09-01', 'September 2025', 'January 2026',  'Open Now',  'OSM Thome online application only'),
(6,  2025, '2025-08-01', '2025-09-30', '2025-10-15', 'November 2025',  'March 2026',    'Upcoming',  'Grieg Eastern — limited seats, apply early'),
(7,  2025, '2025-09-01', '2025-10-15', '2025-11-01', 'November 2025',  'April 2026',    'Upcoming',  'MOL accepts applications Sept-Oct'),
(8,  2025, '2025-06-01', '2025-09-30', '2025-10-15', 'October 2025',   'February 2026', 'Open Now',  'Columbia rolling admissions'),
(9,  2025, '2025-07-01', '2025-08-31', '2025-09-20', 'October 2025',   'January 2026',  'Open Now',  'BSM own exam conducted at multiple centres'),
(10, 2025, '2025-05-01', '2025-10-31', NULL,          'Rolling',        'Rolling',       'Open Now',  'V.Ships rolling recruitment — apply anytime'),
(11, 2025, '2025-06-01', '2025-09-30', '2025-10-01', 'October 2025',   'February 2026', 'Open Now',  'Fleet Management rolling basis'),
(12, 2025, '2025-08-01', '2025-09-15', '2025-10-01', 'October 2025',   'January 2026',  'Upcoming',  'Scorpio limited batch'),
(13, 2025, '2025-07-01', '2025-08-31', '2025-09-15', 'October 2025',   'January 2026',  'Open Now',  'Stena — tanker division applications'),
(15, 2025, '2025-04-01', '2025-05-31', '2025-06-15', 'July 2025',      'January 2026',  'Closed',    'Chevron 2025 batch closed. Next: 2026.'),
(16, 2025, '2025-08-01', '2025-09-30', '2025-10-15', 'November 2025',  'April 2026',    'Upcoming',  'NYK Line — BSc NS batch April 2026'),
(21, 2025, '2025-07-01', '2025-08-15', '2025-09-01', 'September 2025', 'January 2026',  'Open Now',  'Great Eastern — Indian students only'),
(23, 2025, '2025-06-01', '2025-08-31', '2025-09-15', 'October 2025',   'February 2026', 'Open Now',  'MSC online CBT + in-person interview'),
(24, 2025, '2025-01-01', '2025-12-31', NULL,          'Rolling',        'Rolling',       'Open Now',  'TSM — open year round, easy entry'),
(30, 2025, '2025-01-01', '2025-12-31', NULL,          'Rolling',        'Rolling',       'Open Now',  'CMG — always open, most beginner friendly');

-- ================================================================
-- FINANCIAL DATA (per company)
-- ================================================================
INSERT INTO COMPANY_FINANCIAL (company_id, dns_college_fees, hostel_cost_total, food_cost_monthly, uniform_kit_cost, books_cost, imu_cet_exam_cost, company_exam_cost, medical_exam_cost, document_cost, travel_cost, miscellaneous, total_investment_approx, dns_stipend_monthly, onboard_trainee_usd, ship_living_cost_usd, savings_per_contract_inr, third_officer_exam_cost, roi_months) VALUES
(1,  875000, 96000, 5000, 28000, 18000, 2000, 1500, 10000, 8000, 15000, 25000, 1083500, 45000, 1200, 0, 4800000, 90000, 18),
(2,  680000, 90000, 5000, 25000, 15000, 0,    2000, 10000, 8000, 12000, 22000, 869000,  40000, 900,  0, 3600000, 85000, 19),
(3,  720000, 90000, 5000, 25000, 15000, 2000, 0,    10000, 8000, 12000, 20000, 907000,  38000, 950,  0, 3800000, 85000, 20),
(4,  875000, 96000, 5000, 28000, 18000, 2000, 1500, 10000, 8000, 15000, 25000, 1083500, 42000, 1100, 0, 4400000, 85000, 20),
(5,  720000, 90000, 5000, 25000, 15000, 0,    1500, 10000, 8000, 12000, 20000, 906500,  38000, 1000, 0, 4000000, 85000, 19),
(6,  875000, 96000, 5000, 28000, 18000, 2000, 0,    10000, 8000, 15000, 22000, 1079000, 36000, 900,  0, 3600000, 85000, 23),
(7,  875000, 96000, 5000, 28000, 18000, 2000, 1500, 10000, 8000, 15000, 25000, 1083500, 40000, 1050, 0, 4200000, 85000, 21),
(8,  680000, 90000, 5000, 25000, 15000, 0,    1500, 10000, 8000, 12000, 20000, 861500,  37000, 950,  0, 3800000, 85000, 19),
(9,  720000, 90000, 5000, 25000, 15000, 0,    2000, 10000, 8000, 12000, 20000, 907000,  39000, 1000, 0, 4000000, 85000, 19),
(10, 560000, 72000, 4500, 22000, 12000, 0,    0,    8000,  7000, 10000, 18000, 709500,  36000, 900,  0, 3600000, 80000, 16),
(11, 680000, 90000, 5000, 25000, 15000, 0,    1500, 10000, 8000, 12000, 20000, 861500,  38000, 950,  0, 3800000, 85000, 18),
(12, 650000, 84000, 5000, 25000, 15000, 0,    1500, 10000, 8000, 12000, 20000, 825500,  35000, 900,  0, 3600000, 85000, 19),
(13, 875000, 96000, 5000, 28000, 18000, 0,    1500, 10000, 8000, 15000, 22000, 1078500, 40000, 1000, 0, 4000000, 85000, 21),
(14, 680000, 90000, 5000, 25000, 15000, 0,    1500, 10000, 8000, 12000, 20000, 861500,  37000, 950,  0, 3800000, 85000, 18),
(15, 875000, 96000, 5000, 30000, 20000, 2000, 2000, 15000, 10000, 20000, 30000, 1105000, 50000, 1500, 0, 6000000, 90000, 15),
(16, 875000, 96000, 5000, 28000, 18000, 2000, 1500, 10000, 8000, 15000, 25000, 1083500, 41000, 1100, 0, 4400000, 85000, 20),
(17, 590000, 78000, 4500, 22000, 12000, 0,    1500, 8000,  7000, 10000, 18000, 751000,  35000, 850,  0, 3400000, 80000, 18),
(18, 720000, 90000, 5000, 25000, 15000, 0,    1500, 10000, 8000, 12000, 20000, 906500,  36000, 900,  0, 3600000, 85000, 21),
(19, 875000, 96000, 5000, 28000, 18000, 0,    1500, 10000, 8000, 15000, 22000, 1078500, 38000, 950,  0, 3800000, 85000, 22),
(20, 760000, 96000, 5000, 28000, 18000, 0,    1500, 10000, 8000, 15000, 22000, 963500,  36000, 900,  0, 3600000, 85000, 22),
(21, 650000, 84000, 5000, 25000, 15000, 2000, 0,    10000, 8000, 12000, 20000, 831000,  32000, 800,  0, 3200000, 80000, 22),
(22, 680000, 90000, 4500, 22000, 12000, 0,    1500, 8000,  7000, 10000, 18000, 853000,  38000, 950,  0, 3800000, 80000, 18),
(23, 875000, 96000, 5000, 28000, 18000, 2000, 1500, 10000, 8000, 15000, 25000, 1083500, 42000, 1100, 0, 4400000, 85000, 20),
(24, 560000, 72000, 4000, 20000, 10000, 0,    0,    7000,  6000, 8000,  15000, 702000,  30000, 750,  0, 3000000, 75000, 19),
(25, 875000, 96000, 5000, 28000, 18000, 0,    1500, 10000, 8000, 15000, 22000, 1078500, 40000, 1050, 0, 4200000, 85000, 21),
(26, 590000, 78000, 4500, 22000, 12000, 0,    1500, 8000,  7000, 10000, 18000, 751000,  34000, 850,  0, 3400000, 80000, 18),
(27, 560000, 72000, 4000, 20000, 10000, 0,    1000, 7000,  6000, 8000,  15000, 703000,  33000, 820,  0, 3280000, 78000, 18),
(28, 590000, 78000, 4500, 22000, 12000, 0,    1000, 8000,  7000, 10000, 18000, 750500,  35000, 880,  0, 3520000, 80000, 18),
(29, 680000, 90000, 5000, 25000, 15000, 0,    1500, 10000, 8000, 12000, 20000, 861500,  37000, 920,  0, 3680000, 82000, 19),
(30, 520000, 66000, 3500, 18000,  8000, 0,    0,    6000,  5000, 6000,  12000, 641500,  28000, 700,  0, 2800000, 72000, 19);

-- ================================================================
-- SALARY PROGRESSION (all companies use same general ladder)
-- ================================================================
INSERT INTO COMPANY_SALARY_PROGRESSION (company_id, rank_name, salary_usd_month, salary_inr_approx, years_experience_min, years_experience_max) VALUES
-- Maersk (1) — premium
(1,'DNS Trainee (Shore)',       0,    45000,  0, 1),
(1,'Deck Cadet / OIT',         1200, 100000, 1, 2),
(1,'4th Officer / Jr 3rd Off', 2000, 166000, 2, 4),
(1,'3rd Officer',              2500, 207000, 3, 5),
(1,'2nd Officer',              4000, 332000, 5, 8),
(1,'Chief Officer',            6000, 498000, 8, 12),
(1,'Captain / Master',         9000, 747000, 12, 30),
-- Anglo-Eastern (2)
(2,'DNS Trainee (Shore)',       0,    40000,  0, 1),
(2,'Deck Cadet / OIT',         900,  75000,  1, 2),
(2,'3rd Officer',              2200, 182000, 3, 5),
(2,'2nd Officer',              3500, 290000, 5, 8),
(2,'Chief Officer',            5500, 456000, 8, 12),
(2,'Captain / Master',         8000, 664000, 12, 30),
-- Chevron (15) — highest
(15,'DNS Trainee (Shore)',      0,    50000,  0, 1),
(15,'Deck Cadet / OIT',        1500, 124000, 1, 2),
(15,'3rd Officer',             3500, 290000, 3, 5),
(15,'2nd Officer',             5500, 456000, 5, 8),
(15,'Chief Officer',           8500, 705000, 8, 12),
(15,'Captain / Master',        12000,995000, 12, 30),
-- TSM (24) — entry level
(24,'DNS Trainee (Shore)',      0,    30000,  0, 1),
(24,'Deck Cadet / OIT',        750,  62000,  1, 2),
(24,'3rd Officer',             1800, 149000, 3, 5),
(24,'2nd Officer',             2800, 232000, 5, 8),
(24,'Chief Officer',           4200, 348000, 8, 12),
(24,'Captain / Master',        6500, 539000, 12, 30),
-- CMG (30) — lowest
(30,'DNS Trainee (Shore)',      0,    28000,  0, 1),
(30,'Deck Cadet / OIT',        700,  58000,  1, 2),
(30,'3rd Officer',             1600, 133000, 3, 5),
(30,'2nd Officer',             2500, 207000, 5, 8),
(30,'Chief Officer',           3800, 315000, 8, 12),
(30,'Captain / Master',        5800, 481000, 12, 30);

-- ================================================================
-- DOCUMENTS MASTER LIST
-- ================================================================
INSERT INTO DOCUMENTS (document_name, is_mandatory, description) VALUES
('Passport (Valid 5 years)',                TRUE,  '36-page passport valid for min 5 years from DNS joining date'),
('10th Mark Sheet (Original)',              TRUE,  'SSC/Matric mark sheet — original and 3 attested copies'),
('12th Mark Sheet (Original)',              TRUE,  'HSC/Intermediate mark sheet — original and 3 attested copies'),
('10th Passing Certificate',               TRUE,  'Board issued passing certificate'),
('12th Passing Certificate',               TRUE,  'Board issued passing certificate'),
('IMU-CET Scorecard',                      FALSE, 'Required if IMU-CET is mandatory for the company'),
('Medical Fitness Certificate (ENG1/STCW)',TRUE,  'Approved doctor certificate — ENG1 or STCW as required'),
('Swimming Certificate',                   FALSE, 'From recognized swimming pool/authority'),
('Birth Certificate / Aadhaar',            TRUE,  'Government issued DOB proof'),
('Passport Size Photographs (10 copies)',  TRUE,  'White background, recent, as per company specs'),
('School Character Certificate',           FALSE, 'From school principal'),
('Gap Certificate (if applicable)',        FALSE, 'Notarized gap certificate if any academic gap'),
('Caste Certificate (if applicable)',      FALSE, 'For scholarship / reservation purposes'),
('Income Certificate (if applicable)',     FALSE, 'For fee waiver or scholarship applications'),
('Company Application Form',               TRUE,  'Duly filled and signed company-specific form'),
('COVID Vaccination Certificate',          TRUE,  'Full vaccination proof required for boarding'),
('SID (Seafarer Identity Document)',        FALSE, 'Required before joining ship — obtained from shipping master'),
('INDOS Number Registration',              TRUE,  'Indian National Database of Seafarers — mandatory'),
('Basic Safety Training (BST) Certificate',FALSE, 'Post-DNS joining certificate — before boarding ship'),
('Bank Account Details',                   TRUE,  'Nationalized bank account for stipend transfer');

-- ================================================================
-- EXAMS
-- ================================================================
INSERT INTO EXAMS (exam_name) VALUES
('IMU-CET'),('Company CBT Test'),('Psychometric Assessment'),('Technical Interview'),('HR Interview'),('Group Discussion');

-- ================================================================
-- STUDENTS (sample data — demo accounts)
-- ================================================================
INSERT INTO STUDENTS (name, email, password_hash, phone, age, gender, city, state, institute, academic_pathway, pcm_percentage, tenth_percentage, twelfth_percentage, tenth_english, twelfth_english, aggregate_percentage, imu_cet_rank, eyesight, medical_status, swimming_certified) VALUES
('Arjun Sharma',    'arjun@maritime.com',  '$demo$', '9876543210', 18, 'Male',   'Mumbai',    'Maharashtra', 'IMU Chennai',               'BSc Nautical Science', 78.5, 82.0, 80.0, 75.0, 72.0, 81.0,  120, 1.5, 'Fit',    TRUE),
('Priya Mehta',     'priya@maritime.com',  '$demo$', '9887766554', 19, 'Female', 'Delhi',     'Delhi',       'MERI Mumbai',               'BSc Nautical Science', 82.0, 88.0, 85.0, 80.0, 78.0, 86.5,  85,  0.0, 'Fit',    TRUE),
('Rohit Das',       'rohit@maritime.com',  '$demo$', '9765432109', 18, 'Male',   'Kolkata',   'West Bengal', 'Tolani Maritime Institute', 'DNS',                  65.0, 70.0, 68.0, 60.0, 58.0, 69.0,  450, 2.0, 'Fit',    FALSE),
('Sneha Pillai',    'sneha@maritime.com',  '$demo$', '9654321098', 20, 'Female', 'Chennai',   'Tamil Nadu',  'SCI Training Centre',       'DNS',                  70.0, 75.0, 72.0, 68.0, 65.0, 73.5,  300, 1.0, 'Fit',    TRUE),
('Karan Verma',     'karan@maritime.com',  '$demo$', '9543210987', 18, 'Male',   'Jaipur',    'Rajasthan',   'HIMT College',              'DNS',                  55.0, 58.0, 56.0, 50.0, 48.0, 57.0,  900, 3.5, 'Pending',FALSE),
('Ananya Nair',     'ananya@maritime.com', '$demo$', '9432109876', 19, 'Female', 'Kochi',     'Kerala',      'Samundra Institute',        'BSc Nautical Science', 88.0, 92.0, 90.0, 85.0, 82.0, 91.0,  42,  0.5, 'Fit',    TRUE),
('Vivek Pandey',    'vivek@maritime.com',  '$demo$', '9321098765', 18, 'Male',   'Lucknow',   'UP',          'HIMT College',              'DNS',                  50.0, 52.0, 51.0, 45.0, 43.0, 51.5,  NULL,4.0, 'Pending',FALSE),
('Meera Iyer',      'meera@maritime.com',  '$demo$', '9210987654', 19, 'Female', 'Hyderabad', 'Telangana',   'AMET University',           'BSc Nautical Science', 73.0, 78.0, 75.0, 70.0, 68.0, 76.5,  180, 1.5, 'Fit',    TRUE);

-- ================================================================
-- SAMPLE APPLICATIONS & SCORES
-- ================================================================
INSERT INTO EXAM_SCORES (student_id, exam_id, score, rank_obtained, exam_date) VALUES
(1,1,82,120,'2024-05-15'),(1,2,75,NULL,'2024-07-20'),
(2,1,90,85,'2024-05-15'),(2,2,88,NULL,'2024-07-25'),
(3,1,68,450,'2024-05-15'),
(4,1,76,300,'2024-05-15'),(4,2,72,NULL,'2024-07-22'),
(6,1,95,42,'2024-05-15'),(6,2,91,NULL,'2024-07-18'),
(8,1,79,180,'2024-05-15'),(8,2,74,NULL,'2024-07-24');

INSERT INTO APPLICATIONS (student_id, company_id, application_status, interview_date) VALUES
(1,1,'Under Review','2025-07-15'),(1,4,'Applied','2025-08-01'),
(2,1,'Selected','2025-06-20'),(2,2,'Applied','2025-08-10'),
(4,22,'Applied','2025-07-25'),(6,1,'Applied','2025-07-30'),
(3,10,'Applied','2025-08-05'),(5,30,'Applied',NULL),
(7,24,'Applied',NULL),(7,30,'Applied',NULL),
(8,3,'Applied','2025-08-20'),(8,9,'Applied','2025-09-01');

INSERT INTO STUDENT_DOCUMENTS (student_id, document_id, verification_status) VALUES
(1,1,'Verified'),(1,2,'Verified'),(1,3,'Verified'),(1,7,'Pending'),(1,8,'Verified'),
(2,1,'Verified'),(2,2,'Verified'),(2,3,'Verified'),(2,7,'Verified'),(2,8,'Verified'),(2,6,'Verified'),
(6,1,'Verified'),(6,2,'Verified'),(6,3,'Verified'),(6,7,'Verified'),(6,8,'Verified'),(6,6,'Verified');

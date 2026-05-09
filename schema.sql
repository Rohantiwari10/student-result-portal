-- 1. Branches Table (Lookup Table)
-- 1. Programs Table (Handles BBA, BSc, BCom, BTech, etc.)
CREATE TABLE programs (
    program_id INT AUTO_INCREMENT PRIMARY KEY,
    program_code VARCHAR(20) UNIQUE NOT NULL, -- e.g., 'BBA', 'BCOM', 'BTECH-CSE'
    program_name VARCHAR(100) NOT NULL,
    duration_years INT NOT NULL, -- e.g., 3 for BBA, 4 for BTech
    total_semesters INT NOT NULL
);

-- 1b. Admins Table (For Faculty/Staff who upload marks)
CREATE TABLE admins (
    admin_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('SUPER_ADMIN', 'DATA_ENTRY') DEFAULT 'DATA_ENTRY'
);

-- 1c. Grading Scales (Dynamic Grading System based on percentage)
CREATE TABLE grading_scales (
    grade_id INT AUTO_INCREMENT PRIMARY KEY,
    grade_letter VARCHAR(5) UNIQUE NOT NULL, -- e.g., 'O', 'A+'
    min_percent INT NOT NULL,
    max_percent INT NOT NULL,
    grade_point INT NOT NULL -- Standard 10-point scale mapping
);

-- Pre-filling the table with your exact grading criteria
INSERT INTO grading_scales (grade_letter, min_percent, max_percent, grade_point) VALUES
('O', 90, 100, 10), ('A+', 75, 89, 9), ('A', 65, 74, 8), 
('B+', 55, 64, 7), ('B', 50, 54, 6), ('C', 45, 49, 5), 
('P', 40, 44, 4), ('F', 0, 39, 0);

-- 2. Students Table
CREATE TABLE students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    enrollment_no VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    dob DATE NOT NULL, -- Used as default password initially
    password_hash VARCHAR(255) NOT NULL, -- Hashed DOB or user-changed password
    program_id INT NOT NULL,
    batch_year INT NOT NULL, -- e.g., 2024
    current_semester INT DEFAULT 1,
    
    -- Administrative Edge Cases
    is_withheld BOOLEAN DEFAULT FALSE,
    withheld_reason VARCHAR(255),
    
    FOREIGN KEY (program_id) REFERENCES programs(program_id)
);

-- 3. Subjects Master Pool (Subjects can now be shared across different programs)
CREATE TABLE subjects (
    subject_id INT AUTO_INCREMENT PRIMARY KEY,
    subject_code VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    credits INT NOT NULL,
    type ENUM('CORE', 'ELECTIVE', 'LAB') NOT NULL,
    
    -- NEW: Required for automatic pass/fail calculation
    max_internal_marks INT NOT NULL,
    max_external_marks INT NOT NULL,
    min_pass_marks INT NOT NULL
);

-- 3a. Program Subjects Mapping (Solves the "Same subject in different courses" problem)
CREATE TABLE program_subjects (
    program_id INT NOT NULL,
    subject_id INT NOT NULL,
    semester INT NOT NULL, -- e.g., Math might be Sem 1 for BTech, but Sem 3 for BSc
    PRIMARY KEY (program_id, subject_id),
    FOREIGN KEY (program_id) REFERENCES programs(program_id) ON DELETE CASCADE,
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id) ON DELETE CASCADE
);

-- 3b. Student Subject Enrollments (Tracks which electives/courses a student actually chose)
CREATE TABLE student_enrollments (
    enrollment_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    subject_id INT NOT NULL,
    semester INT NOT NULL,
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id),
    UNIQUE(student_id, subject_id) -- A student can only register for a subject once per term
);

-- 4. Exam Sessions (Tracks when the exam occurred)
CREATE TABLE exam_sessions (
    session_id INT AUTO_INCREMENT PRIMARY KEY,
    session_name VARCHAR(50) NOT NULL, -- e.g., 'Winter 2023', 'Summer 2024'
    is_published BOOLEAN DEFAULT FALSE,
    is_enrollment_open BOOLEAN DEFAULT FALSE -- NEW: Admin toggles this to allow students to pick electives
);

-- 5. Semester Results (Header Table - 1 per student per semester)
CREATE TABLE semester_results (
    result_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    semester INT NOT NULL,
    session_id INT NOT NULL,
    uploaded_by INT NOT NULL, -- NEW: Accountability trail (Which Admin did this?)
    
    sgpa DECIMAL(4,2) NOT NULL,
    cgpa DECIMAL(4,2) NOT NULL,
    status ENUM('PASS', 'FAIL', 'PROMOTED_WITH_BACKLOG') NOT NULL,
    
    UNIQUE(student_id, semester, session_id), -- Prevents duplicate result entries
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (session_id) REFERENCES exam_sessions(session_id),
    FOREIGN KEY (uploaded_by) REFERENCES admins(admin_id)
);

-- 6. Subject Results (Line Items - Many per Semester Result)
CREATE TABLE subject_results (
    subject_result_id INT AUTO_INCREMENT PRIMARY KEY,
    result_id INT NOT NULL,
    subject_id INT NOT NULL,
    
    -- CRITICAL FOR INTERVIEWS: Store credits here historically. 
    -- If the university changes the subject credits next year, past students' CGPAs won't break.
    historical_credits INT NOT NULL, 
    
    internal_marks DECIMAL(5,2) NOT NULL,
    external_marks DECIMAL(5,2) NOT NULL,
    total_marks DECIMAL(5,2) NOT NULL,
    grade VARCHAR(2) NOT NULL, -- e.g., 'A+', 'B'
    grade_point INT NOT NULL,
    is_backlog BOOLEAN DEFAULT FALSE,
    attempt_number INT DEFAULT 1, -- Tracks how many times the student took this specific exam
    
    FOREIGN KEY (result_id) REFERENCES semester_results(result_id) ON DELETE CASCADE,
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id)
);

/* 
===========================================================================
  SYSTEM DATA FLOW & CONNECTIONS (How everything ties together)
===========================================================================

PHASE 1: ONE-TIME SETUP (The Catalog)
- Admin creates Programs (BTech, BBA) in `programs`.
- Admin adds all Subjects (Math, Physics) to `subjects`.
- Admin maps Subjects to Programs for specific semesters in `program_subjects`.
- `grading_scales` defines how percentages map to grades ('O', 'A+', etc.).

PHASE 2: ADMISSIONS (The People)
- Students are added to `students` and linked strictly to a `program_id`.

PHASE 3: PRE-EXAM (Enrollments)
- Admin creates an Exam Session in `exam_sessions` and opens enrollment.
- Students pick their subjects/electives; saved in `student_enrollments`.

PHASE 4: RESULTS (The Transactions & Math)
- Exams finish. Admin uploads marks (via Excel or Manual UI Entry).
- Backend checks `grading_scales` to calculate the Grade and Grade Point dynamically.
- Backend calculates SGPA and CGPA based on credits and grade points.

PHASE 5: STORAGE (Historical Integrity)
- Backend creates ONE row per student per semester in `semester_results` (The Header/Total).
- Backend creates MULTIPLE rows in `subject_results` (The Line Items).
- CRITICAL: `historical_credits`, `grade`, and `grade_point` are permanently copied 
  into `subject_results` so future syllabus/grading changes never break past alumni records.
===========================================================================
*/

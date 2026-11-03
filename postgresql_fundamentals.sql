-- PostgreSQL Fundamentals
-- This script resets its demo tables before creating them. Run it only in a
-- development or learning database where dropping these tables is acceptable.

BEGIN;

-- ============================================================================
-- 1. Reset demo tables
-- ============================================================================

DROP TABLE IF EXISTS enrollments;
DROP TABLE IF EXISTS courses;
DROP TABLE IF EXISTS students;

-- ============================================================================
-- 2. Create the student table
-- ============================================================================

CREATE TABLE students (
    student_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name TEXT NOT NULL,
    age INTEGER NOT NULL CHECK (age BETWEEN 0 AND 120),
    email TEXT UNIQUE
);

-- ============================================================================
-- 3. Insert sample students
-- ============================================================================

INSERT INTO students (name, age, email)
VALUES
    ('Rahul', 21, NULL),
    ('Sneha', 22, 'sneha@example.com'),
    ('Amit', 20, 'amit@example.com'),
    ('Priya', 23, 'priya@example.com'),
    ('Vikram', 21, 'vikram@example.com'),
    ('Ravi', 24, NULL);

-- ============================================================================
-- 4. Update and delete data
-- ============================================================================

UPDATE students
SET age = 22
WHERE name = 'Rahul';

UPDATE students
SET email = 'vikram_new@example.com'
WHERE name = 'Vikram'
  AND age = 21;

-- Example delete; uncomment to remove Amit from the sample data.
-- DELETE FROM students
-- WHERE name = 'Amit';

-- ============================================================================
-- 5. Filter, sort, and limit rows
-- ============================================================================

SELECT student_id, name, age, email
FROM students
WHERE name = 'Rahul'
   OR age = 20;

SELECT student_id, name, age, email
FROM students
WHERE name <> 'Priya';

SELECT student_id, name, age, email
FROM students
WHERE age BETWEEN 20 AND 22;

SELECT student_id, name, age, email
FROM students
WHERE name IN ('Priya', 'Sneha');

SELECT student_id, name, age, email
FROM students
WHERE name LIKE 'P%';

SELECT student_id, name, age, email
FROM students
ORDER BY age DESC, student_id
LIMIT 3;

-- PostgreSQL uses LIMIT rather than SQL Server's TOP syntax.
SELECT student_id, name, age, email
FROM students
ORDER BY student_id
LIMIT 2;

-- ============================================================================
-- 6. Aggregate and group data
-- ============================================================================

SELECT COUNT(*) AS total_students
FROM students;

SELECT AVG(age) AS average_age
FROM students;

SELECT SUM(age) AS total_age
FROM students;

SELECT MIN(age) AS youngest_age,
       MAX(age) AS oldest_age
FROM students;

SELECT age, COUNT(*) AS student_count
FROM students
GROUP BY age
HAVING COUNT(*) >= 2
ORDER BY age;

-- ============================================================================
-- 7. Create course and enrollment tables
-- ============================================================================

CREATE TABLE courses (
    course_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    course_name TEXT NOT NULL UNIQUE
);

CREATE TABLE enrollments (
    enrollment_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    student_id INTEGER NOT NULL REFERENCES students (student_id),
    course_id INTEGER NOT NULL REFERENCES courses (course_id),
    CONSTRAINT enrollments_student_course_unique UNIQUE (student_id, course_id)
);

-- Index foreign-key columns to support joins and lookups from either side.
CREATE INDEX enrollments_course_id_idx
    ON enrollments (course_id);

-- The unique constraint on (student_id, course_id) already indexes student_id
-- as its leading column.

-- ============================================================================
-- 8. Insert sample courses and enrollments
-- ============================================================================

INSERT INTO courses (course_name)
VALUES
    ('Python'),
    ('SQL'),
    ('Data Science'),
    ('Machine Learning');

WITH enrollment_seed (student_name, course_name) AS (
    VALUES
        ('Rahul', 'Python'),
        ('Rahul', 'SQL'),
        ('Sneha', 'Python'),
        ('Amit', 'Data Science'),
        ('Priya', 'SQL'),
        ('Vikram', 'Python')
)
INSERT INTO enrollments (student_id, course_id)
SELECT s.student_id, c.course_id
FROM enrollment_seed AS seed
JOIN students AS s
    ON s.name = seed.student_name
JOIN courses AS c
    ON c.course_name = seed.course_name;

-- ============================================================================
-- 9. Join examples
-- ============================================================================

-- INNER JOIN: only students with an enrollment.
SELECT s.student_id, s.name, c.course_id, c.course_name
FROM students AS s
INNER JOIN enrollments AS e
    ON e.student_id = s.student_id
INNER JOIN courses AS c
    ON c.course_id = e.course_id
ORDER BY s.student_id, c.course_id;

-- LEFT JOIN: all students, including those without an enrollment.
SELECT s.student_id, s.name, c.course_id, c.course_name
FROM students AS s
LEFT JOIN enrollments AS e
    ON e.student_id = s.student_id
LEFT JOIN courses AS c
    ON c.course_id = e.course_id
ORDER BY s.student_id, c.course_id;

-- RIGHT JOIN: all courses, including courses without an enrollment.
SELECT s.student_id, s.name, c.course_id, c.course_name
FROM students AS s
RIGHT JOIN enrollments AS e
    ON e.student_id = s.student_id
RIGHT JOIN courses AS c
    ON c.course_id = e.course_id
ORDER BY c.course_id, s.student_id;

-- FULL OUTER JOIN: preserve unmatched students and unmatched courses.
SELECT s.student_id, s.name, c.course_id, c.course_name
FROM students AS s
FULL OUTER JOIN enrollments AS e
    ON e.student_id = s.student_id
FULL OUTER JOIN courses AS c
    ON c.course_id = e.course_id
ORDER BY COALESCE(s.student_id, 0), COALESCE(c.course_id, 0);

-- CROSS JOIN: every possible student-course pair.
SELECT s.student_id, s.name, c.course_id, c.course_name
FROM students AS s
CROSS JOIN courses AS c
ORDER BY s.student_id, c.course_id;

COMMIT;

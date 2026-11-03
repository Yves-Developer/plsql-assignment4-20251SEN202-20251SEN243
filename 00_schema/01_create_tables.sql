SET SERVEROUTPUT ON;

-- Drop old tables (ignore only "table does not exist")
DECLARE
    TYPE t_table_names IS TABLE OF VARCHAR2(30);
    v_tables t_table_names := t_table_names('ENROLLMENTS', 'COURSES', 'STUDENTS');
BEGIN
    FOR i IN 1 .. v_tables.COUNT LOOP
        BEGIN
            EXECUTE IMMEDIATE 'DROP TABLE ' || v_tables(i) || ' CASCADE CONSTRAINTS PURGE';
        EXCEPTION
            WHEN OTHERS THEN
                IF SQLCODE != -942 THEN
                    RAISE;
                END IF;
        END;
    END LOOP;
END;
/

CREATE TABLE students (
    student_id        NUMBER GENERATED ALWAYS AS IDENTITY (START WITH 1001),
    first_name        VARCHAR2(50)  NOT NULL,
    last_name         VARCHAR2(50)  NOT NULL,
    email             VARCHAR2(100) NOT NULL,
    registration_date DATE DEFAULT SYSDATE NOT NULL,
    CONSTRAINT pk_students       PRIMARY KEY (student_id),
    CONSTRAINT uq_students_email UNIQUE (email)
);

CREATE TABLE courses (
    course_id   NUMBER GENERATED ALWAYS AS IDENTITY (START WITH 101),
    course_code VARCHAR2(10)  NOT NULL,
    course_name VARCHAR2(100) NOT NULL,
    credits     NUMBER(2)     NOT NULL,
    CONSTRAINT pk_courses          PRIMARY KEY (course_id),
    CONSTRAINT uq_courses_code     UNIQUE (course_code),
    CONSTRAINT chk_courses_credits CHECK (credits > 0)
);

CREATE TABLE enrollments (
    enrollment_id   NUMBER GENERATED ALWAYS AS IDENTITY,
    student_id      NUMBER NOT NULL,
    course_id       NUMBER NOT NULL,
    score           NUMBER(5,2),
    enrollment_date DATE DEFAULT SYSDATE NOT NULL,
    CONSTRAINT pk_enrollments        PRIMARY KEY (enrollment_id),
    CONSTRAINT fk_enr_student        FOREIGN KEY (student_id) REFERENCES students (student_id),
    CONSTRAINT fk_enr_course         FOREIGN KEY (course_id)  REFERENCES courses (course_id),
    CONSTRAINT uq_enr_student_course UNIQUE (student_id, course_id),
    CONSTRAINT chk_enr_score         CHECK (score BETWEEN 0 AND 100)
);

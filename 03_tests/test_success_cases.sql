-- Run both 00_schema scripts first so the data is fresh
SET SERVEROUTPUT ON;

PROMPT --- Test 1: Register a new student ---
DECLARE
    v_new_id students.student_id%TYPE;
BEGIN
    register_student('Alice', 'Keza', 'alice.keza@student.example.com', v_new_id);
    DBMS_OUTPUT.PUT_LINE('Returned ID: ' || v_new_id);
END;
/

PROMPT --- Test 2: Update a score ---
BEGIN
    update_score(1001, 102, 89);
END;
/

PROMPT --- Test 3: Drop an enrollment ---
BEGIN
    drop_enrollment(1009, 104);
END;
/

PROMPT --- Test 4: Print a transcript ---
BEGIN
    print_student_transcript(1003);
END;
/

PROMPT --- Test 5: Apply a grade curve ---
BEGIN
    bulk_apply_curve(102, 5);
END;
/

PROMPT --- Test 6: GPA and letter grade ---
-- Called from SQL
SELECT get_student_gpa(1001) AS gpa,
       get_letter_grade(85)  AS letter_grade
FROM   dual;

-- Called from PL/SQL
BEGIN
    DBMS_OUTPUT.PUT_LINE('GPA of student 1003: ' || get_student_gpa(1003));
    DBMS_OUTPUT.PUT_LINE('Letter grade for 72: ' || get_letter_grade(72));
END;
/

PROMPT --- Test 7: Find a student by last name ---
DECLARE
    v_student students%ROWTYPE;
BEGIN
    v_student := find_student_by_last_name('Mugabo');
    DBMS_OUTPUT.PUT_LINE('Found: ' || v_student.student_id || ' - '
                         || v_student.first_name || ' ' || v_student.last_name
                         || ' (' || v_student.email || ')');
END;
/

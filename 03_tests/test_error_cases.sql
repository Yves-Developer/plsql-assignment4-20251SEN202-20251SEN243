-- Run both 00_schema scripts first so the data is fresh
-- Each test expects a specific error and prints PASS if it gets it
SET SERVEROUTPUT ON;

PROMPT --- Error 1: Register a student with a duplicate email ---
DECLARE
    v_new_id students.student_id%TYPE;
BEGIN
    register_student('Jean', 'Mugabo', 'jean.mugabo@student.example.com', v_new_id);
    DBMS_OUTPUT.PUT_LINE('FAIL: no error raised');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -20001 THEN
            DBMS_OUTPUT.PUT_LINE('PASS: ' || SQLERRM);
        ELSE
            DBMS_OUTPUT.PUT_LINE('FAIL: unexpected error ' || SQLERRM);
        END IF;
END;
/

PROMPT --- Error 2: Update the score of a non-existent enrollment ---
BEGIN
    update_score(1010, 101, 80);
    DBMS_OUTPUT.PUT_LINE('FAIL: no error raised');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -20002 THEN
            DBMS_OUTPUT.PUT_LINE('PASS: ' || SQLERRM);
        ELSE
            DBMS_OUTPUT.PUT_LINE('FAIL: unexpected error ' || SQLERRM);
        END IF;
END;
/

PROMPT --- Error 3: Drop a non-existent enrollment ---
BEGIN
    drop_enrollment(1010, 101);
    DBMS_OUTPUT.PUT_LINE('FAIL: no error raised');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -20004 THEN
            DBMS_OUTPUT.PUT_LINE('PASS: ' || SQLERRM);
        ELSE
            DBMS_OUTPUT.PUT_LINE('FAIL: unexpected error ' || SQLERRM);
        END IF;
END;
/

PROMPT --- Error 4: Transcript for an unknown student (NO_DATA_FOUND) ---
BEGIN
    print_student_transcript(9999);
    DBMS_OUTPUT.PUT_LINE('FAIL: no error raised');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -20005 THEN
            DBMS_OUTPUT.PUT_LINE('PASS: ' || SQLERRM);
        ELSE
            DBMS_OUTPUT.PUT_LINE('FAIL: unexpected error ' || SQLERRM);
        END IF;
END;
/

PROMPT --- Error 5: Last name shared by two students (TOO_MANY_ROWS) ---
DECLARE
    v_student students%ROWTYPE;
BEGIN
    v_student := find_student_by_last_name('Uwase');
    DBMS_OUTPUT.PUT_LINE('FAIL: no error raised');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -20104 THEN
            DBMS_OUTPUT.PUT_LINE('PASS: ' || SQLERRM);
        ELSE
            DBMS_OUTPUT.PUT_LINE('FAIL: unexpected error ' || SQLERRM);
        END IF;
END;
/

PROMPT --- Error 6: Curve that pushes some scores above 100 (SAVE EXCEPTIONS) ---
-- Expected: 3 of 6 scores curved, enrollments 1, 2 and 3 reported as failed
BEGIN
    bulk_apply_curve(101, 5);
END;
/

PROMPT --- Error 7: Letter grade for a score above 100 ---
BEGIN
    DBMS_OUTPUT.PUT_LINE(get_letter_grade(150));
    DBMS_OUTPUT.PUT_LINE('FAIL: no error raised');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -20101 THEN
            DBMS_OUTPUT.PUT_LINE('PASS: ' || SQLERRM);
        ELSE
            DBMS_OUTPUT.PUT_LINE('FAIL: unexpected error ' || SQLERRM);
        END IF;
END;
/

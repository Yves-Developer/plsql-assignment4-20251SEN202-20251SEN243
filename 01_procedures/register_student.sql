CREATE OR REPLACE PROCEDURE register_student (
    p_first_name IN  students.first_name%TYPE,
    p_last_name  IN  students.last_name%TYPE,
    p_email      IN  students.email%TYPE,
    p_new_id     OUT students.student_id%TYPE
)
IS
BEGIN
    INSERT INTO students (first_name, last_name, email)
    VALUES (p_first_name, p_last_name, p_email)
    RETURNING student_id INTO p_new_id;

    DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT || ' student registered with ID ' || p_new_id);
    COMMIT;
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        RAISE_APPLICATION_ERROR(-20001, 'Email ' || p_email || ' is already registered.');
END;
/

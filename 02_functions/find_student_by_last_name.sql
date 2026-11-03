
CREATE OR REPLACE FUNCTION find_student_by_last_name (p_last_name IN VARCHAR2)
RETURN students%ROWTYPE
IS
    v_student students%ROWTYPE;
BEGIN
    SELECT * INTO v_student
    FROM   students
    WHERE  UPPER(last_name) = UPPER(TRIM(p_last_name));

    RETURN v_student;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20103, 'No student found with last name ' || p_last_name || '.');
    WHEN TOO_MANY_ROWS THEN
        RAISE_APPLICATION_ERROR(-20104,
            'More than one student has last name ' || p_last_name || '. Search by student ID instead.');
END;
/
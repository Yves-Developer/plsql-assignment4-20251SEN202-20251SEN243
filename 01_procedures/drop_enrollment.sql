CREATE OR REPLACE PROCEDURE drop_enrollment (
    p_student_id IN enrollments.student_id%TYPE,
    p_course_id  IN enrollments.course_id%TYPE
)
IS
BEGIN
    DELETE FROM enrollments
    WHERE  student_id = p_student_id
    AND    course_id  = p_course_id;

    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20004, 'No enrollment found for student ' || p_student_id
                                || ' in course ' || p_course_id || '.');
    END IF;

    DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT || ' row deleted: student ' || p_student_id
                         || ' dropped from course ' || p_course_id);
    COMMIT;
END;
/

CREATE OR REPLACE PROCEDURE update_score (
    p_student_id IN enrollments.student_id%TYPE,
    p_course_id  IN enrollments.course_id%TYPE,
    p_score      IN enrollments.score%TYPE
)
IS
    e_enrollment_not_found EXCEPTION;
    e_invalid_score        EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_invalid_score, -2290); -- check constraint violated
BEGIN
    UPDATE enrollments
    SET    score = p_score
    WHERE  student_id = p_student_id
    AND    course_id  = p_course_id;

    IF SQL%NOTFOUND THEN
        RAISE e_enrollment_not_found;
    END IF;

    IF SQL%FOUND THEN
        DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT || ' row updated: student ' || p_student_id
                             || ', course ' || p_course_id || ', new score ' || p_score);
    END IF;

    COMMIT;
EXCEPTION
    WHEN e_enrollment_not_found THEN
        RAISE_APPLICATION_ERROR(-20002, 'Student ' || p_student_id
                                || ' is not enrolled in course ' || p_course_id || '.');
    WHEN e_invalid_score THEN
        RAISE_APPLICATION_ERROR(-20003, 'Score ' || p_score || ' is invalid. It must be between 0 and 100.');
END;
/

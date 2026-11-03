CREATE OR REPLACE PROCEDURE bulk_apply_curve (
    p_course_id IN courses.course_id%TYPE,
    p_points    IN NUMBER
)
IS
    TYPE t_enrollment_ids IS TABLE OF enrollments.enrollment_id%TYPE;
    TYPE t_scores         IS TABLE OF enrollments.score%TYPE;

    v_ids       t_enrollment_ids;
    v_scores    t_scores;
    v_course_id courses.course_id%TYPE;

    e_invalid_points EXCEPTION;
    e_bulk_errors    EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_bulk_errors, -24381); -- errors saved by FORALL
BEGIN
    IF p_points IS NULL OR p_points <= 0 THEN
        RAISE e_invalid_points;
    END IF;

    SELECT course_id INTO v_course_id
    FROM   courses
    WHERE  course_id = p_course_id;

    -- Load all graded enrollments of the course in one fetch
    SELECT enrollment_id, score
    BULK COLLECT INTO v_ids, v_scores
    FROM   enrollments
    WHERE  course_id = p_course_id
    AND    score IS NOT NULL;

    IF v_ids.COUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('No graded enrollments in course ' || p_course_id || '.');
        RETURN;
    END IF;

    -- Update all rows in one statement; keep going if some rows fail
    FORALL i IN 1 .. v_ids.COUNT SAVE EXCEPTIONS
        UPDATE enrollments
        SET    score = score + p_points
        WHERE  enrollment_id = v_ids(i);

    DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT || ' scores curved by ' || p_points || ' points in course ' || p_course_id);
    COMMIT;
EXCEPTION
    WHEN e_invalid_points THEN
        RAISE_APPLICATION_ERROR(-20006, 'Curve points must be greater than 0.');
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20007, 'Course ' || p_course_id || ' does not exist.');
    WHEN e_bulk_errors THEN
        DBMS_OUTPUT.PUT_LINE((v_ids.COUNT - SQL%BULK_EXCEPTIONS.COUNT) || ' of ' || v_ids.COUNT
                             || ' scores curved. Failed rows:');
        FOR j IN 1 .. SQL%BULK_EXCEPTIONS.COUNT LOOP
            DBMS_OUTPUT.PUT_LINE('  Enrollment ' || v_ids(SQL%BULK_EXCEPTIONS(j).ERROR_INDEX)
                                 || ' (score ' || v_scores(SQL%BULK_EXCEPTIONS(j).ERROR_INDEX) || '): '
                                 || SQLERRM(-SQL%BULK_EXCEPTIONS(j).ERROR_CODE));
        END LOOP;
        COMMIT;
END;
/

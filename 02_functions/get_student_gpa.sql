
CREATE OR REPLACE FUNCTION get_student_gpa (p_student_id IN NUMBER)
RETURN NUMBER
IS
    v_student_id    students.student_id%TYPE;
    v_total_points  NUMBER;
    v_total_credits NUMBER;
BEGIN
    -- Raises NO_DATA_FOUND if the student does not exist
    SELECT student_id INTO v_student_id
    FROM   students
    WHERE  student_id = p_student_id;

    -- GPA on a 4.0 scale, weighted by course credits
    SELECT SUM(c.credits * CASE
                              WHEN e.score >= 80 THEN 4
                              WHEN e.score >= 70 THEN 3
                              WHEN e.score >= 60 THEN 2
                              WHEN e.score >= 50 THEN 1
                              ELSE 0
                           END),
           SUM(c.credits)
    INTO   v_total_points, v_total_credits
    FROM   enrollments e
    JOIN   courses c ON c.course_id = e.course_id
    WHERE  e.student_id = p_student_id
    AND    e.score IS NOT NULL;

    -- No graded courses yet
    IF v_total_credits IS NULL THEN
        RETURN NULL;
    END IF;

    RETURN ROUND(v_total_points / v_total_credits, 2);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20102, 'Student ' || p_student_id || ' does not exist.');
END;
/
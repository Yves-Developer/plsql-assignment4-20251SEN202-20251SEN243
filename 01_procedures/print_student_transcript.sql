CREATE OR REPLACE PROCEDURE print_student_transcript (
    p_student_id IN students.student_id%TYPE
)
IS
    TYPE t_transcript_line IS RECORD (
        course_code courses.course_code%TYPE,
        course_name courses.course_name%TYPE,
        credits     courses.credits%TYPE,
        score       enrollments.score%TYPE
    );

    v_student students%ROWTYPE;
    v_line    t_transcript_line;

    CURSOR c_courses IS
        SELECT c.course_code, c.course_name, c.credits, e.score
        FROM   enrollments e
        JOIN   courses c ON c.course_id = e.course_id
        WHERE  e.student_id = p_student_id
        ORDER  BY c.course_code;
BEGIN
    SELECT * INTO v_student
    FROM   students
    WHERE  student_id = p_student_id;

    DBMS_OUTPUT.PUT_LINE('Transcript: ' || v_student.first_name || ' ' || v_student.last_name
                         || ' (ID ' || v_student.student_id || ')');
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 60, '-'));

    OPEN c_courses;
    LOOP
        FETCH c_courses INTO v_line;
        EXIT WHEN c_courses%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE(RPAD(v_line.course_code, 10)
                             || RPAD(v_line.course_name, 35)
                             || RPAD(v_line.credits || ' cr', 7)
                             || NVL(TO_CHAR(v_line.score), 'Not graded'));
    END LOOP;

    IF c_courses%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('No courses found for this student.');
    END IF;

    CLOSE c_courses;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20005, 'Student ' || p_student_id || ' does not exist.');
    WHEN OTHERS THEN
        IF c_courses%ISOPEN THEN
            CLOSE c_courses;
        END IF;
        RAISE;
END;
/

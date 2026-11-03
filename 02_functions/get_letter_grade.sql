
CREATE OR REPLACE FUNCTION get_letter_grade (p_score IN NUMBER)
RETURN VARCHAR2
IS
    -- Grade bands: minimum score for each letter
    TYPE t_min_scores IS VARRAY(5) OF NUMBER;
    TYPE t_letters    IS VARRAY(5) OF VARCHAR2(1);
    v_min_scores t_min_scores := t_min_scores(80, 70, 60, 50, 0);
    v_letters    t_letters    := t_letters('A', 'B', 'C', 'D', 'F');
BEGIN
    IF p_score IS NULL OR p_score < 0 OR p_score > 100 THEN
        RAISE_APPLICATION_ERROR(-20101,
            'Invalid score: ' || NVL(TO_CHAR(p_score), 'NULL') || '. Score must be between 0 and 100.');
    END IF;

    FOR i IN 1 .. v_min_scores.COUNT LOOP
        IF p_score >= v_min_scores(i) THEN
            RETURN v_letters(i);
        END IF;
    END LOOP;
END;
/
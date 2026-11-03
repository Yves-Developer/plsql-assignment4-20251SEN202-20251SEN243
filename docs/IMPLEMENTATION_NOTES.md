# Implementation Notes

## 1. Overview

The Student Registration & Grading System registers students, enrolls them in courses, records scores, and reports transcripts and GPAs. All logic is in Oracle PL/SQL stored procedures and functions.

---

## 2. Database Design

| Table | Key Constraints | Why |
|---|---|---|
| `students` | PK, `UNIQUE (email)` | No two students can share an email. This triggers `DUP_VAL_ON_INDEX` in `register_student`. |
| `courses` | PK, `UNIQUE (course_code)`, `CHECK (credits > 0)` | Credits are used as weights in the GPA. |
| `enrollments` | PK, two FKs, `UNIQUE (student_id, course_id)`, `CHECK (score BETWEEN 0 AND 100)` | A student cannot enroll twice in one course. The score check is what makes the bulk curve fail for some rows. |

IDs are generated with identity columns, so `register_student` gets the new ID with `RETURNING ... INTO`.

---

## 3. How Each Concept Is Used

**Records**
- `print_student_transcript` uses a `students%ROWTYPE` record for the student and a user-defined `RECORD` type (`t_transcript_line`) for each course line.
- `find_student_by_last_name` returns a whole row as `students%ROWTYPE`.

**Collections**
- `bulk_apply_curve` uses two nested tables to hold the enrollment IDs and scores of a course.
- `get_letter_grade` uses two VARRAYs to hold the grade bands (`80, 70, 60, 50, 0`) and their letters (`A`–`F`).

**Implicit cursors**
- `register_student`: INSERT, then prints `SQL%ROWCOUNT`.
- `update_score`: UPDATE, then checks `SQL%NOTFOUND` (raise an error) and `SQL%FOUND` (print a confirmation).
- `drop_enrollment`: DELETE, then checks `SQL%ROWCOUNT = 0`.

**Explicit cursors**
- `print_student_transcript` declares a cursor and uses `OPEN`, `FETCH` in a loop, `EXIT WHEN %NOTFOUND`, and `CLOSE`. If an error occurs, the handler closes the cursor if it is still open.

**Stored procedures and functions**
- 5 procedures change or print data; 3 functions return values.
- `get_student_gpa` and `get_letter_grade` can be called from SQL (`SELECT ... FROM dual`) and from PL/SQL. `find_student_by_last_name` returns a record, so it is called from PL/SQL.

---

## 4. Bulk Processing and Performance

PL/SQL code runs in the PL/SQL engine and SQL statements run in the SQL engine. Every time control passes between them there is a **context switch**, which has a cost.

**Row by row (slow):** one switch per row.

```sql
FOR r IN (SELECT enrollment_id FROM enrollments WHERE course_id = 101) LOOP
    UPDATE enrollments SET score = score + 5 WHERE enrollment_id = r.enrollment_id;
END LOOP;
```

**Bulk (fast):** one switch to fetch all rows, one switch to update all rows.

```sql
SELECT enrollment_id BULK COLLECT INTO v_ids
FROM   enrollments WHERE course_id = 101;

FORALL i IN 1 .. v_ids.COUNT
    UPDATE enrollments SET score = score + 5 WHERE enrollment_id = v_ids(i);
```

With 21 rows the difference is tiny. With thousands or millions of rows, bulk processing is much faster because the number of switches stays almost constant instead of growing with every row.

**Handling bulk errors with `SAVE EXCEPTIONS`**

Without it, the first failing row stops the whole `FORALL`. With it, Oracle keeps going, updates every valid row, and raises `ORA-24381` at the end. `bulk_apply_curve` catches that error and loops through `SQL%BULK_EXCEPTIONS` to report each failed row (`ERROR_INDEX` tells which row, `ERROR_CODE` tells why).

Example: a +5 curve on course 101 updates 3 rows and reports 3 failed rows, because scores 96, 97.5 and 98 would go above 100 and break `chk_enr_score`.

**Memory**

`BULK COLLECT` loads all rows into memory at once. For very large tables, use `BULK COLLECT ... LIMIT n` inside a loop to process rows in batches. Our tables are small, so we load them in one go.

---

## 5. Error Handling

- **Predefined exceptions:** `DUP_VAL_ON_INDEX`, `NO_DATA_FOUND`, `TOO_MANY_ROWS`.
- **User-defined exceptions:** `e_enrollment_not_found` (`update_score`), `e_invalid_points` (`bulk_apply_curve`).
- **Named Oracle errors with `PRAGMA EXCEPTION_INIT`:** `-2290` check constraint (`update_score`), `-24381` bulk errors (`bulk_apply_curve`).
- **`RAISE_APPLICATION_ERROR`** turns every error into a clear message with its own code:

| Range | Used by |
|---|---|
| `-20001` to `-20007` | Procedures |
| `-20101` to `-20104` | Functions |

Errors are never silently ignored. Every handler either raises a clear application error, or (in `print_student_transcript`) closes the cursor and re-raises the original error.

**Why `get_student_gpa` converts `NO_DATA_FOUND`:** when a function is called from a `SELECT`, an unhandled `NO_DATA_FOUND` does not show an error, the query just returns NULL. Converting it to `RAISE_APPLICATION_ERROR` makes an unknown student a real error. A student with no graded courses returns NULL instead of a misleading 0.

---

## 6. Testing

1. Run `00_schema/01_create_tables.sql` and `00_schema/02_insert_sample_data.sql`.
2. Compile `01_procedures/` and `02_functions/`.
3. Run `03_tests/test_success_cases.sql`.
4. Run the two schema scripts again, because the tests change the data.
5. Run `03_tests/test_error_cases.sql`. Each error test prints `PASS` when it receives the expected error code.

Screenshots of every test are in [`../screenshots/`](../screenshots/).

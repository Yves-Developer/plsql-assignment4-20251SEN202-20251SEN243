-- Students get IDs 1001-1010, courses get IDs 101-104

-- Students (two share the last name Uwase)
INSERT INTO students (first_name, last_name, email) VALUES ('Jean',     'Mugabo',       'jean.mugabo@student.example.com');
INSERT INTO students (first_name, last_name, email) VALUES ('Aline',    'Uwase',        'aline.uwase@student.example.com');
INSERT INTO students (first_name, last_name, email) VALUES ('Eric',     'Habimana',     'eric.habimana@student.example.com');
INSERT INTO students (first_name, last_name, email) VALUES ('Grace',    'Uwase',        'grace.uwase@student.example.com');
INSERT INTO students (first_name, last_name, email) VALUES ('Patrick',  'Niyonzima',    'patrick.niyonzima@student.example.com');
INSERT INTO students (first_name, last_name, email) VALUES ('Diane',    'Ingabire',     'diane.ingabire@student.example.com');
INSERT INTO students (first_name, last_name, email) VALUES ('Kevin',    'Nshimiyimana', 'kevin.nshimiyimana@student.example.com');
INSERT INTO students (first_name, last_name, email) VALUES ('Sandrine', 'Mukamana',     'sandrine.mukamana@student.example.com');
INSERT INTO students (first_name, last_name, email) VALUES ('Olivier',  'Hakizimana',   'olivier.hakizimana@student.example.com');
INSERT INTO students (first_name, last_name, email) VALUES ('Claudine', 'Uwimana',      'claudine.uwimana@student.example.com');

-- Courses
INSERT INTO courses (course_code, course_name, credits) VALUES ('INSY8311', 'Database Development with PL/SQL', 4);
INSERT INTO courses (course_code, course_name, credits) VALUES ('SENG8240', 'Data Structures and Algorithms',   4);
INSERT INTO courses (course_code, course_name, credits) VALUES ('NETW8120', 'Computer Networks',                3);
INSERT INTO courses (course_code, course_name, credits) VALUES ('SENG8350', 'Software Engineering',             3);

-- Enrollments (student 1010 has none)
-- Course 101 has scores 96, 97.5 and 98, so a +5 curve pushes them over 100
INSERT INTO enrollments (student_id, course_id, score) VALUES (1001, 101, 96);
INSERT INTO enrollments (student_id, course_id, score) VALUES (1002, 101, 97.5);
INSERT INTO enrollments (student_id, course_id, score) VALUES (1003, 101, 98);
INSERT INTO enrollments (student_id, course_id, score) VALUES (1004, 101, 72);
INSERT INTO enrollments (student_id, course_id, score) VALUES (1005, 101, 81);
INSERT INTO enrollments (student_id, course_id, score) VALUES (1006, 101, 64);

INSERT INTO enrollments (student_id, course_id, score) VALUES (1001, 102, 85);
INSERT INTO enrollments (student_id, course_id, score) VALUES (1003, 102, 78);
INSERT INTO enrollments (student_id, course_id, score) VALUES (1007, 102, 90);
INSERT INTO enrollments (student_id, course_id, score) VALUES (1008, 102, 55);
INSERT INTO enrollments (student_id, course_id, score) VALUES (1009, 102, 68);

INSERT INTO enrollments (student_id, course_id, score) VALUES (1002, 103, 88);
INSERT INTO enrollments (student_id, course_id, score) VALUES (1004, 103, 79);
INSERT INTO enrollments (student_id, course_id, score) VALUES (1005, 103, 92);
INSERT INTO enrollments (student_id, course_id, score) VALUES (1007, 103, 61);
INSERT INTO enrollments (student_id, course_id, score) VALUES (1006, 103, 74);

INSERT INTO enrollments (student_id, course_id, score) VALUES (1003, 104, 83);
INSERT INTO enrollments (student_id, course_id, score) VALUES (1008, 104, 70);
INSERT INTO enrollments (student_id, course_id, score) VALUES (1009, 104, 87);
INSERT INTO enrollments (student_id, course_id, score) VALUES (1007, 104, 76);
INSERT INTO enrollments (student_id, course_id, score) VALUES (1005, 104, 58);

COMMIT;

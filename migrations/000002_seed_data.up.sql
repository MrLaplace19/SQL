SET search_path TO headhunter;

INSERT INTO company (title, address, phone_number, hr_full_name, hr_phone)
VALUES
    ('Northwind Systems', 'Moscow, Tverskaya 12', '+74951234501', 'Anna Petrova', '+74951234511'),
    ('Vector Logistics', 'Moscow, Lenina 45', '+74951234502', 'Boris Sokolov', '+74951234512'),
    ('Bright Studio', 'Moscow, Arbat 18', '+74951234503', 'Daria Volkova', '+74951234513'),
    ('Data Forge', 'Moscow, Mira 73', '+74951234504', 'Elena Orlova', '+74951234514'),
    ('Green Market', 'Moscow, Parkovaya 9', '+74951234505', 'Ilya Morozov', '+74951234515');

INSERT INTO position (title)
VALUES
    ('Backend Developer'),
    ('Logistics Manager'),
    ('Graphic Designer'),
    ('Data Analyst'),
    ('Sales Manager');

INSERT INTO unemployed (position_id, full_name, birth_date, address, phone, sex, education)
VALUES
    ((SELECT id FROM position WHERE title = 'Backend Developer'), 'Alexey Smirnov', DATE '1995-04-12', 'Moscow, Lesnaya 10', '+79261234501', 'Мужской', 'Высшее'),
    ((SELECT id FROM position WHERE title = 'Logistics Manager'), 'Marina Belova', DATE '1992-08-21', 'Moscow, Rechnaya 25', '+79261234502', 'Женский', 'Высшее'),
    ((SELECT id FROM position WHERE title = 'Graphic Designer'), 'Svetlana Ivanova', DATE '1998-01-30', 'Moscow, Sadovaya 14', '+79261234503', 'Женский', 'Высшее'),
    ((SELECT id FROM position WHERE title = 'Data Analyst'), 'Pavel Kuznetsov', DATE '1994-11-05', 'Moscow, Solnechnaya 8', '+79261234504', 'Мужской', 'Высшее'),
    ((SELECT id FROM position WHERE title = 'Sales Manager'), 'Olga Fedorova', DATE '1996-06-17', 'Moscow, Polevaya 31', '+79261234505', 'Женский', 'Среднее специальное');

INSERT INTO vacancy (
    company_id,
    position_id,
    sex,
    education_min,
    age_from,
    age_to,
    conditions,
    salary_from,
    salary_to,
    status,
    created_at
)
VALUES
    ((SELECT id FROM company WHERE title = 'Northwind Systems'), (SELECT id FROM position WHERE title = 'Backend Developer'), 'Не важен', 'Высшее', 22, 45, 'Remote work and annual bonus', 180000, 250000, 'Активна', TIMESTAMPTZ '2026-09-01 09:00:00+03'),
    ((SELECT id FROM company WHERE title = 'Vector Logistics'), (SELECT id FROM position WHERE title = 'Logistics Manager'), 'Не важен', 'Высшее', 25, 50, 'Office work and health insurance', 120000, 170000, 'Активна', TIMESTAMPTZ '2026-09-02 09:00:00+03'),
    ((SELECT id FROM company WHERE title = 'Bright Studio'), (SELECT id FROM position WHERE title = 'Graphic Designer'), 'Не важен', 'Высшее', 21, 40, 'Flexible schedule and equipment', 100000, 150000, 'Активна', TIMESTAMPTZ '2026-09-03 09:00:00+03'),
    ((SELECT id FROM company WHERE title = 'Data Forge'), (SELECT id FROM position WHERE title = 'Data Analyst'), 'Не важен', 'Высшее', 23, 45, 'Hybrid work and training budget', 160000, 220000, 'Активна', TIMESTAMPTZ '2026-09-04 09:00:00+03'),
    ((SELECT id FROM company WHERE title = 'Green Market'), (SELECT id FROM position WHERE title = 'Sales Manager'), 'Не важен', 'Среднее специальное', 20, 45, 'Shift schedule and sales bonus', 90000, 140000, 'Завершена', TIMESTAMPTZ '2026-09-05 09:00:00+03');

INSERT INTO employment (unemployed_id, vacancy_id, created_at, dismissal_at, dismissal_reason)
VALUES
    ((SELECT id FROM unemployed WHERE full_name = 'Alexey Smirnov'), (SELECT id FROM vacancy WHERE company_id = (SELECT id FROM company WHERE title = 'Northwind Systems')), TIMESTAMPTZ '2026-09-10 09:00:00+03', NULL, NULL),
    ((SELECT id FROM unemployed WHERE full_name = 'Marina Belova'), (SELECT id FROM vacancy WHERE company_id = (SELECT id FROM company WHERE title = 'Vector Logistics')), TIMESTAMPTZ '2026-09-11 09:00:00+03', NULL, NULL),
    ((SELECT id FROM unemployed WHERE full_name = 'Svetlana Ivanova'), (SELECT id FROM vacancy WHERE company_id = (SELECT id FROM company WHERE title = 'Bright Studio')), TIMESTAMPTZ '2026-09-12 09:00:00+03', NULL, NULL),
    ((SELECT id FROM unemployed WHERE full_name = 'Pavel Kuznetsov'), (SELECT id FROM vacancy WHERE company_id = (SELECT id FROM company WHERE title = 'Data Forge')), TIMESTAMPTZ '2026-09-13 09:00:00+03', NULL, NULL),
    ((SELECT id FROM unemployed WHERE full_name = 'Olga Fedorova'), (SELECT id FROM vacancy WHERE company_id = (SELECT id FROM company WHERE title = 'Green Market')), TIMESTAMPTZ '2026-09-14 09:00:00+03', TIMESTAMPTZ '2026-09-20 09:00:00+03', 'Contract completed');

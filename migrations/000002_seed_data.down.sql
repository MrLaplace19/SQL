SET search_path TO headhunter;

DELETE FROM employment
WHERE unemployed_id IN (
    SELECT id
    FROM unemployed
    WHERE full_name IN ('Alexey Smirnov', 'Marina Belova', 'Svetlana Ivanova', 'Pavel Kuznetsov', 'Olga Fedorova')
)
OR vacancy_id IN (
    SELECT vacancy.id
    FROM vacancy
    JOIN company ON company.id = vacancy.company_id
    WHERE company.title IN ('Northwind Systems', 'Vector Logistics', 'Bright Studio', 'Data Forge', 'Green Market')
);

DELETE FROM vacancy
WHERE company_id IN (
    SELECT id
    FROM company
    WHERE title IN ('Northwind Systems', 'Vector Logistics', 'Bright Studio', 'Data Forge', 'Green Market')
);

DELETE FROM unemployed
WHERE full_name IN ('Alexey Smirnov', 'Marina Belova', 'Svetlana Ivanova', 'Pavel Kuznetsov', 'Olga Fedorova');

DELETE FROM position
WHERE title IN ('Backend Developer', 'Logistics Manager', 'Graphic Designer', 'Data Analyst', 'Sales Manager');

DELETE FROM company
WHERE title IN ('Northwind Systems', 'Vector Logistics', 'Bright Studio', 'Data Forge', 'Green Market');

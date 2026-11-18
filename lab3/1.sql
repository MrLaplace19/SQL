-- 1.1
SELECT full_name, birth_date, sex, education
FROM headhunter.unemployed
ORDER BY birth_date DESC, full_name ASC;

-- 1.2.1
SELECT id,salary_from, salary_to, status
FROM headhunter.vacancy
WHERE status='Активна' AND salary_from >=150000;

-- 1.2.2
SELECT full_name, birth_date, education
FROM headhunter.unemployed
WHERE education='Высшее' AND birth_date >= DATE '1995-01-01';

-- 1.2.3
SELECT id, created_at, dismissal_at, dismissal_reason
FROM headhunter.employment
WHERE dismissal_at IS NOT NULL;

-- 1.3.1
SELECT COUNT(id) AS total_count
FROM headhunter.unemployed;

-- 1.3.2
SELECT MIN(salary_from) AS min_salary, MAX(salary_from) AS max_salary, AVG(salary_from) AS avg_salary, SUM(salary_from) AS sum_salary
FROM headhunter.vacancy;

-- 1.3.3
SELECT sex, COUNT(id) AS total_count
FROM headhunter.unemployed
GROUP BY sex;

-- 1.4.1
SELECT education_min, status, COUNT(id) AS vacancy_count
FROM headhunter.vacancy
GROUP BY ROLLUP(education_min, status);

-- 1.4.2
SELECT sex, education, COUNT(*) AS applicant_count
FROM headhunter.unemployed
GROUP BY CUBE(sex, education);

-- 1.4.3
SELECT education_min,
       SUM(salary_from) FILTER (WHERE status = 'Активна') AS total_min_salary
FROM headhunter.vacancy
GROUP BY ALL education_min
ORDER BY education_min;

-- 1.5
SELECT title, address, phone_number
FROM headhunter.company
WHERE title NOT LIKE '%Market%';

-- 2.1.1
SELECT
    c.title AS company_title,
    p.title AS position_title,
    v.salary_from,
    v.salary_to,
    v.status
FROM headhunter.vacancy AS v,
     headhunter.company AS c,
     headhunter.position AS p
WHERE v.company_id = c.id
  AND v.position_id = p.id;

-- 2.1.2
SELECT
     un.full_name,
     un.sex,
     un.education,
     p.title AS position_title
FROM headhunter.unemployed AS un,
     headhunter.position AS p
WHERE un.position_id = p.id;

-- 2.2.1
SELECT
     c.title AS company_title,
     p.title AS position_title,
     v.salary_from,
     v.salary_to,
     v.status
FROM headhunter.position AS p
INNER JOIN headhunter.vacancy AS v ON p.id = v.position_id
INNER JOIN headhunter.company AS c ON v.company_id = c.id;

-- 2.2.2
SELECT
     un.full_name,
     un.sex,
     un.education,
     p.title AS position_title
FROM headhunter.unemployed AS un
INNER JOIN headhunter.position AS p ON un.position_id=p.id;

-- 2.3.1
SELECT c.title, p.title
FROM headhunter.company AS c
LEFT JOIN headhunter.vacancy AS v ON c.id=v.company_id AND v.status='Активна'
LEFT JOIN headhunter.position AS p ON v.position_id=p.id;

-- 2.3.2
SELECT un.full_name, c.title
FROM headhunter.unemployed AS un
LEFT JOIN headhunter.employment AS em
    ON un.id = em.unemployed_id
   AND em.created_at <= (DATE '2026-09-01'::timestamp AT TIME ZONE 'Europe/Moscow')
   AND (em.dismissal_at IS NULL
        OR em.dismissal_at > (DATE '2026-09-01'::timestamp AT TIME ZONE 'Europe/Moscow'))
LEFT JOIN headhunter.vacancy AS v ON em.vacancy_id=v.id
LEFT JOIN headhunter.company AS c ON v.company_id=c.id;

-- 2.4.1
SELECT p.title AS position_title, c.title AS company_title
FROM headhunter.vacancy AS v
INNER JOIN headhunter.company AS c ON v.company_id = c.id
RIGHT JOIN headhunter.position AS p ON v.position_id = p.id AND v.status='Активна';

-- 2.4.2
SELECT c.title, v.salary_from
FROM headhunter.vacancy AS v
RIGHT JOIN headhunter.company AS c ON v.company_id=c.id AND v.salary_from>=150000;

-- 2.5.1
SELECT c.title, AVG(v.salary_from) AS avg_min_salary
FROM headhunter.company AS c
LEFT JOIN headhunter.vacancy AS v ON v.company_id = c.id
GROUP BY c.id, c.title
ORDER BY c.id;

-- 2.5.2
SELECT u.sex, COUNT(DISTINCT u.id) AS hired_count
FROM headhunter.employment AS em
JOIN headhunter.unemployed AS u ON u.id = em.unemployed_id
GROUP BY u.sex
ORDER BY u.sex;

-- 2.6.1
SELECT c.title, AVG(v.salary_from)
FROM headhunter.vacancy AS v
LEFT JOIN headhunter.company AS c ON c.id=v.company_id
GROUP BY c.id, c.title
HAVING AVG(v.salary_from) > 130000;

-- 2.6.2
SELECT p.title, COUNT(v.id)
FROM headhunter.position AS p
LEFT JOIN headhunter.vacancy AS v ON p.id=v.position_id AND v.status='Активна'
GROUP BY p.id,p.title
HAVING COUNT(v.id) >= 1;

-- 2.7.1
SELECT un.full_name, p.title
FROM headhunter.unemployed AS un
INNER JOIN headhunter.position AS p ON un.position_id=p.id
WHERE un.position_id IN (
     SELECT v.position_id
     FROM headhunter.vacancy AS v
     WHERE v.status='Активна'
);

-- 2.7.2
SELECT c.title
FROM headhunter.company AS c
WHERE EXISTS (
     SELECT 1
     FROM headhunter.vacancy AS v
     WHERE v.status='Активна' AND c.id=v.company_id
);

-- 2.7.3
SELECT un.full_name
FROM headhunter.unemployed AS un
WHERE NOT EXISTS(
     SELECT 1
     FROM headhunter.employment AS em
     WHERE em.unemployed_id = un.id
     AND em.created_at <= (DATE '2026-09-01'::timestamp AT TIME ZONE 'Europe/Moscow')
     AND (
          em.dismissal_at IS NULL
          OR em.dismissal_at > (DATE '2026-09-01'::timestamp AT TIME ZONE 'Europe/Moscow')
     )
);

-- 2.7.4
SELECT
    c.title AS company_title,
    p.title AS position_title,
    v.salary_from
FROM headhunter.vacancy AS v
INNER JOIN headhunter.company AS c ON v.company_id = c.id
INNER JOIN headhunter.position AS p ON v.position_id = p.id
WHERE v.salary_from > (
    SELECT AVG(v_all.salary_from)
    FROM headhunter.vacancy AS v_all
);

-- 3.1.1
CREATE VIEW headhunter.vw_vacancy_details AS
SELECT
    c.title AS company_title,
    p.title AS position_title,
    v.salary_from,
    v.salary_to,
    v.status
FROM headhunter.vacancy AS v
INNER JOIN headhunter.company AS c ON v.company_id = c.id
INNER JOIN headhunter.position AS p ON v.position_id = p.id;

-- 3.1.2
CREATE VIEW headhunter.vw_company_employment_stats AS
SELECT c.title AS company_title, COUNT(DISTINCT em.unemployed_id) AS count_em
FROM headhunter.company AS c
LEFT JOIN headhunter.vacancy AS v ON v.company_id = c.id
LEFT JOIN headhunter.employment AS em ON em.vacancy_id = v.id
GROUP BY c.id, c.title;

-- 3.2.1
WITH unemployed_age AS (
    SELECT un.full_name, EXTRACT(YEAR FROM AGE(DATE '2026-09-01', un.birth_date)) AS age
    FROM headhunter.unemployed AS un
)
SELECT full_name, age
FROM unemployed_age
WHERE age < 32;

-- 3.2.2
WITH vacancy_company AS (
    SELECT c.title AS company_title, COUNT(v.id) AS count_v
    FROM headhunter.company AS c
    LEFT JOIN headhunter.vacancy AS v ON c.id = v.company_id AND v.status = 'Активна'
    GROUP BY c.id, c.title
)
SELECT company_title, count_v
FROM vacancy_company
WHERE count_v = 0;

-- 4.1.1
SELECT
     ROW_NUMBER() OVER (
          ORDER BY v.salary_from DESC, v.id ASC
     ) AS row_num,
     c.title AS company_title,
     p.title AS position_title,
     v.salary_from
FROM headhunter.vacancy AS v
JOIN headhunter.position AS p ON v.position_id=p.id
JOIN headhunter.company AS c ON v.company_id=c.id
ORDER BY row_num;

-- 4.1.2
SELECT
     v.education_min,
     ROW_NUMBER() OVER (
          PARTITION BY v.education_min
          ORDER BY v.salary_from DESC, v.id ASC
     ) AS row_num,
     p.title AS position_title,
     v.salary_from
FROM headhunter.vacancy AS v
JOIN headhunter.position AS p ON v.position_id=p.id
ORDER BY v.education_min, row_num;

-- 4.1.3
SELECT
    p.title AS position_title,
    COUNT(v.id) AS active_vacancy_count,
    RANK() OVER (
        ORDER BY COUNT(v.id) DESC
    ) AS rank_num
FROM headhunter.vacancy AS v
RIGHT JOIN headhunter.position AS p
    ON v.position_id = p.id
   AND v.status = 'Активна'
GROUP BY p.id, p.title
ORDER BY rank_num, position_title;

--4.1.4
SELECT
    p.title AS position_title,
    COUNT(v.id) AS active_vacancy_count,
    DENSE_RANK() OVER (
        ORDER BY COUNT(v.id) DESC
    ) AS dense_rank_num
FROM headhunter.position AS p
LEFT JOIN headhunter.vacancy AS v
    ON v.position_id = p.id
   AND v.status = 'Активна'
GROUP BY p.id, p.title
ORDER BY dense_rank_num, position_title;

-- 5.1.1
SELECT c.title AS company_title
FROM headhunter.vacancy AS v
JOIN headhunter.company AS c ON v.company_id=c.id
WHERE v.salary_from >=120000

UNION

SELECT c.title
FROM headhunter.company AS c
JOIN headhunter.vacancy AS v ON v.company_id = c.id
WHERE v.education_min = 'Высшее'

ORDER BY company_title;

--5.1.2
SELECT c.title AS company_title
FROM headhunter.vacancy AS v
JOIN headhunter.company AS c ON v.company_id=c.id
WHERE v.salary_from >=120000

UNION ALL

SELECT c.title
FROM headhunter.company AS c
JOIN headhunter.vacancy AS v ON v.company_id = c.id
WHERE v.education_min = 'Высшее'

ORDER BY company_title;

-- 5.1.3
WITH without_employment AS (
    SELECT id
    FROM headhunter.unemployed

    EXCEPT

    SELECT unemployed_id
    FROM headhunter.employment
    WHERE created_at <= (DATE '2026-09-01'::timestamp AT TIME ZONE 'Europe/Moscow')
      AND (dismissal_at IS NULL
           OR dismissal_at > (DATE '2026-09-01'::timestamp AT TIME ZONE 'Europe/Moscow'))
)
SELECT un.id, un.full_name
FROM without_employment AS we
JOIN headhunter.unemployed AS un ON un.id = we.id;

-- 5.1.4
WITH matching_positions AS (
    SELECT position_id
    FROM headhunter.unemployed
    WHERE education = 'Высшее'

    INTERSECT

    SELECT position_id
    FROM headhunter.vacancy
    WHERE status = 'Активна'
)
SELECT p.title AS position_title
FROM matching_positions AS mp
JOIN headhunter.position AS p ON p.id = mp.position_id;

-- 6.1.1
SELECT
     education,
     COUNT(CASE WHEN sex='Мужской' THEN 1 END) AS "М",
     COUNT(CASE WHEN sex='Женский' THEN 1 END) AS "Ж",
     COUNT(*) AS "Всего"
FROM headhunter.unemployed AS um
GROUP BY education;

-- 6.1.2
SELECT
    c.title AS company_title,
    COUNT(CASE WHEN v.status = 'Активна' THEN 1 END) AS "Активна",
    COUNT(CASE WHEN v.status = 'Завершена' THEN 1 END) AS "Завершена"
FROM headhunter.company AS c
LEFT JOIN headhunter.vacancy AS v ON v.company_id = c.id
GROUP BY c.id, c.title;

-- 6.2.1
WITH vacancy_summary AS (
    SELECT
        c.title AS company_title,
        COUNT(v.id) FILTER (WHERE v.status = 'Активна') AS active_count,
        COUNT(v.id) FILTER (WHERE v.status = 'Завершена') AS completed_count
    FROM headhunter.company AS c
    LEFT JOIN headhunter.vacancy AS v ON v.company_id = c.id
    GROUP BY c.id, c.title
)
SELECT
    company_title,
    active_count AS "Активна",
    completed_count AS "Завершена"
FROM vacancy_summary;

-- 6.2.2
WITH vacancy_summary AS (
    SELECT
        c.title AS company_title,
        COUNT(v.id) FILTER (WHERE v.status = 'Активна') AS active_count,
        COUNT(v.id) FILTER (WHERE v.status = 'Завершена') AS completed_count
    FROM headhunter.company AS c
    LEFT JOIN headhunter.vacancy AS v ON v.company_id = c.id
    GROUP BY c.id, c.title
)
SELECT
    vs.company_title,
    s.status,
    s.vacancy_count
FROM vacancy_summary AS vs
CROSS JOIN LATERAL (
    VALUES
        ('Активна', vs.active_count),
        ('Завершена', vs.completed_count)
) AS s(status, vacancy_count);

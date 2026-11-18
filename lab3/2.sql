-- a) Активные вакансии, подходящие Alexey Smirnov.
SELECT p.title AS position_title, v.salary_from
FROM headhunter.vacancy AS v
JOIN headhunter.position AS p ON p.id = v.position_id
CROSS JOIN headhunter.unemployed AS u
WHERE u.full_name = 'Alexey Smirnov'
  AND v.status = 'Активна'
  AND (v.sex = 'Не важен' OR v.sex = u.sex)
  AND EXTRACT(YEAR FROM AGE(DATE '2026-09-01', u.birth_date)) BETWEEN v.age_from AND v.age_to
  AND u.education >= v.education_min
ORDER BY p.title;

-- b) Должности по убыванию числа активных вакансий.
SELECT p.title, COUNT(v.id) AS active_count
FROM headhunter.position AS p
LEFT JOIN headhunter.vacancy AS v ON v.position_id = p.id AND v.status = 'Активна'
GROUP BY p.id, p.title
ORDER BY active_count DESC, p.title;

-- c) Вакансии с ограничением по возрасту или по полу.
WITH vacancy_limits AS (
    SELECT v.*,
           v.age_from IS NOT NULL AND v.age_to IS NOT NULL AS age_restricted,
           v.sex <> 'Не важен' AS sex_restricted
    FROM headhunter.vacancy AS v
)
SELECT c.title AS company_title,
       p.title AS position_title,
       CONCAT(v.age_from, '–', v.age_to) AS age_range,
       v.sex,
       CASE WHEN v.age_restricted THEN 'Да' ELSE 'Нет' END AS age_restricted,
       CASE WHEN v.sex_restricted THEN 'Да' ELSE 'Нет' END AS sex_restricted
FROM vacancy_limits AS v
JOIN headhunter.company AS c ON c.id = v.company_id
JOIN headhunter.position AS p ON p.id = v.position_id
WHERE v.age_restricted OR v.sex_restricted
ORDER BY c.id, v.id;

-- d) Число соискателей младше 25 лет с высшим образованием на 01.09.2026.
SELECT COUNT(*) AS applicant_count
FROM headhunter.unemployed AS u
WHERE u.education = 'Высшее'
  AND EXTRACT(YEAR FROM AGE(DATE '2026-09-01', u.birth_date)) BETWEEN 0 AND 24
  AND u.birth_date <= DATE '2026-09-01';

-- e) Число трудоустройств по предприятиям, полу, образованию и возрасту.
SELECT c.title AS "Предприятие",
       COUNT(em.id) AS "Трудоустройств",
       COUNT(*) FILTER (WHERE u.sex = 'Мужской') AS "М",
       COUNT(*) FILTER (WHERE u.sex = 'Женский') AS "Ж",
       COUNT(*) FILTER (WHERE u.education = 'Высшее') AS "Высшее обр.",
       COUNT(*) FILTER (WHERE u.education = 'Среднее специальное') AS "Среднее спец.",
       COUNT(*) FILTER (WHERE u.birth_date > DATE '2026-09-01' - INTERVAL '40 years') AS "До 40 лет",
       COUNT(*) FILTER (WHERE u.birth_date <= DATE '2026-09-01' - INTERVAL '40 years') AS "40 лет и старше"
FROM headhunter.company AS c
LEFT JOIN headhunter.vacancy AS v ON v.company_id = c.id
LEFT JOIN headhunter.employment AS em ON em.vacancy_id = v.id
LEFT JOIN headhunter.unemployed AS u ON u.id = em.unemployed_id
GROUP BY c.id, c.title
ORDER BY c.id;

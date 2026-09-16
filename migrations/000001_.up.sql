CREATE SCHEMA headhunter;

SET search_path TO headhunter;


CREATE TYPE education_level AS ENUM (
    'Среднее',
    'Среднее специальное',
    'Высшее'
);


CREATE TYPE sex_type AS ENUM (
    'Не важен',
    'Мужской',
    'Женский'
);


CREATE TYPE vacancy_status AS ENUM (
    'Завершена',
    'Активна'
);


CREATE DOMAIN phone_type AS VARCHAR(16)
CHECK (
    VALUE ~ '^\+?[0-9]+$'
    AND char_length(VALUE) BETWEEN 10 AND 15
);


CREATE TABLE company (
    id              SERIAL          PRIMARY KEY,
    title           VARCHAR(100)    NOT NULL CHECK (char_length(title) BETWEEN 5 AND 100),
    address         VARCHAR(100)    NOT NULL CHECK (char_length(address) BETWEEN 5 AND 100),
    phone_number    phone_type      NOT NULL,
    hr_full_name    VARCHAR(100)    CHECK (char_length(hr_full_name) BETWEEN 5 AND 100),
    hr_phone        phone_type      NOT NULL
);


CREATE TABLE position (
    id              SERIAL          PRIMARY KEY,
    title           VARCHAR(100)    NOT NULL CHECK (char_length(title) BETWEEN 5 AND 100)
);


CREATE TABLE unemployed (
    id              SERIAL          PRIMARY KEY,
    position_id     INTEGER         REFERENCES position(id),
    full_name       VARCHAR(100)    NOT NULL CHECK (char_length(full_name) BETWEEN 5 AND 100),
    birth_date      DATE            NOT NULL,
    address         VARCHAR(100)    CHECK (char_length(address) BETWEEN 5 AND 100),
    phone           phone_type,
    sex             sex_type,
    education       education_level
);


CREATE TABLE vacancy (
    id              SERIAL          PRIMARY KEY,
    company_id      INTEGER         NOT NULL REFERENCES company(id) ON DELETE CASCADE,
    position_id     INTEGER         NOT NULL REFERENCES position(id) ON DELETE CASCADE,
    sex             sex_type        NOT NULL DEFAULT 'Не важен',
    education_min   education_level NOT NULL,
    age_from        INTEGER         NOT NULL,
    age_to          INTEGER         NOT NULL,
    conditions      VARCHAR(1000),
    salary_from     INTEGER         NOT NULL,
    salary_to       INTEGER         NOT NULL,
    status          vacancy_status  NOT NULL,
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),

    CHECK (age_from >= 0),
    CHECK (age_to >= age_from),
    CHECK (salary_from >= 0),
    CHECK (salary_to >= salary_from)
);


CREATE TABLE employment (
    id              SERIAL          PRIMARY KEY,
    unemployed_id   INTEGER         NOT NULL REFERENCES unemployed(id),
    vacancy_id      INTEGER         NOT NULL REFERENCES vacancy(id),
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    dismissal_at    TIMESTAMPTZ,
    dismissal_reason TEXT,
    CHECK (dismissal_at IS NULL OR dismissal_at >= created_at)
);
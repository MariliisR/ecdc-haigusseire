CREATE SCHEMA IF NOT EXISTS quality;

CREATE TABLE IF NOT EXISTS quality.test_results (
    test_name text,
    status text,
    failed_rows integer,
    message text,
    checked_at timestamptz DEFAULT current_timestamp
);

TRUNCATE TABLE quality.test_results;

WITH test_cases AS (

    SELECT
        'bronze_has_rows' AS test_name,
        CASE WHEN EXISTS (
            SELECT 1 FROM bronze.raw_ecdc_tests
        ) THEN 0 ELSE 1 END AS failed_rows,
        'Bronze tabelis peab olema vähemalt üks rida.' AS message

    UNION ALL

    SELECT
        'yearweek_not_null',
        COUNT(*)::integer,
        'yearweek ei tohi puududa.'
    FROM bronze.raw_ecdc_tests
    WHERE yearweek IS NULL

    UNION ALL

    SELECT
        'countryname_not_null',
        COUNT(*)::integer,
        'Riigi nimi ei tohi puududa.'
    FROM bronze.raw_ecdc_tests
    WHERE countryname IS NULL

    UNION ALL

    SELECT
        'value_not_negative',
        COUNT(*)::integer,
        'Testide või positiivsete leidude arv ei tohi olla negatiivne.'
    FROM bronze.raw_ecdc_tests
    WHERE value < 0

    UNION ALL

    SELECT
        'pathogen_not_null',
        COUNT(*)::integer,
        'Pathogen ei tohi puududa.'
    FROM bronze.raw_ecdc_tests
    WHERE pathogen IS NULL

    UNION ALL

    SELECT
        'valid_indicator_values',
        COUNT(*)::integer,
        'Indicator peab olema detections või tests.'
    FROM bronze.raw_ecdc_tests
    WHERE indicator NOT IN ('detections', 'tests')
)

INSERT INTO quality.test_results (
    test_name,
    status,
    failed_rows,
    message
)
SELECT
    test_name,
    CASE WHEN failed_rows = 0 THEN 'passed' ELSE 'failed' END,
    failed_rows,
    message
FROM test_cases;
CREATE SCHEMA IF NOT EXISTS quality;

CREATE TABLE IF NOT EXISTS quality.test_results (
    layer text,
    test_name text,
    status text,
    failed_rows integer,
    message text,
    checked_at timestamptz DEFAULT current_timestamp
);

DELETE FROM quality.test_results
WHERE layer = 'silver';

WITH test_cases AS (

    SELECT
        'silver' AS layer,
        'silver_has_rows' AS test_name,
        CASE WHEN EXISTS (
            SELECT 1
            FROM silver.fact_respiratory_surveillance
        ) THEN 0 ELSE 1 END AS failed_rows,
        'Silver fact tabelis peab olema vähemalt üks rida.' AS message

    UNION ALL

    SELECT
        'silver',
        'silver_primary_key_unique',
        COUNT(*)::integer,
        'Silver fact tabelis ei tohi olla duplikaate primaarvõtme lõikes.'
    FROM (
        SELECT
            yearweek,
            countryname,
            survtype,
            pathogen,
            indicator,
            COUNT(*) AS row_count
        FROM silver.fact_respiratory_surveillance
        GROUP BY
            yearweek,
            countryname,
            survtype,
            pathogen,
            indicator
        HAVING COUNT(*) > 1
    ) duplicates

    UNION ALL

    SELECT
        'silver',
        'silver_required_columns_not_null',
        COUNT(*)::integer,
        'Võtmeväljad ei tohi olla NULL.'
    FROM silver.fact_respiratory_surveillance
    WHERE yearweek IS NULL
       OR countryname IS NULL
       OR survtype IS NULL
       OR pathogen IS NULL
       OR indicator IS NULL

    UNION ALL

    SELECT
        'silver',
        'silver_only_relevant_pathogens',
        COUNT(*)::integer,
        'Silver kihis peavad olema ainult Influenza, RSV ja SARS-CoV-2.'
    FROM silver.fact_respiratory_surveillance
    WHERE pathogen NOT IN (
        'Influenza',
        'RSV',
        'SARS-CoV-2'
    )

    UNION ALL

    SELECT
        'silver',
        'silver_only_tests_and_detections',
        COUNT(*)::integer,
        'Silver kihis peavad indicator väärtused olema tests või detections.'
    FROM silver.fact_respiratory_surveillance
    WHERE indicator NOT IN (
        'tests',
        'detections'
    )

    UNION ALL

    SELECT
        'silver',
        'silver_value_not_negative',
        COUNT(*)::integer,
        'Value ei tohi olla negatiivne.'
    FROM silver.fact_respiratory_surveillance
    WHERE value < 0

)

INSERT INTO quality.test_results (
    layer,
    test_name,
    status,
    failed_rows,
    message
)

SELECT
    layer,
    test_name,
    CASE
        WHEN failed_rows = 0 THEN 'passed'
        ELSE 'failed'
    END AS status,
    failed_rows,
    message

FROM test_cases;
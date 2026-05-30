DELETE FROM quality.test_results
WHERE layer = 'gold';

WITH test_cases AS (

    SELECT
        'gold' AS layer,
        'gold_has_rows' AS test_name,
        CASE WHEN EXISTS (
            SELECT 1 FROM gold.weekly_virus_stats
        ) THEN 0 ELSE 1 END AS failed_rows,
        'Gold tabelis peab olema vähemalt üks rida.' AS message

    UNION ALL

    SELECT
        'gold',
        'yearweek_not_null',
        COUNT(*)::integer,
        'yearweek ei tohi puududa.'
    FROM gold.weekly_virus_stats
    WHERE yearweek IS NULL

    UNION ALL

    SELECT
        'gold',
        'countryname_not_null',
        COUNT(*)::integer,
        'countryname ei tohi puududa.'
    FROM gold.weekly_virus_stats
    WHERE countryname IS NULL

    UNION ALL

    SELECT
        'gold',
        'week_start_date_not_null',
        COUNT(*)::integer,
        'week_start_date ei tohi puududa.'
    FROM gold.weekly_virus_stats
    WHERE week_start_date IS NULL

    UNION ALL

    SELECT
        'gold',
        'valid_pathogen_values',
        COUNT(*)::integer,
        'Pathogen peab olema Influenza, RSV või SARS-CoV-2.'
    FROM gold.weekly_virus_stats
    WHERE pathogen NOT IN ('Influenza','RSV','SARS-CoV-2')

    UNION ALL

    SELECT
        'gold',
        'tests_total_not_negative',
        COUNT(*)::integer,
        'tests_total ei tohi olla negatiivne.'
    FROM gold.weekly_virus_stats
    WHERE tests_total < 0

    UNION ALL

    SELECT
        'gold',
        'detections_total_not_negative',
        COUNT(*)::integer,
        'detections_total ei tohi olla negatiivne.'
    FROM gold.weekly_virus_stats
    WHERE detections_total < 0
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
    CASE WHEN failed_rows = 0 THEN 'passed' ELSE 'failed' END,
    failed_rows,
    message
FROM test_cases;
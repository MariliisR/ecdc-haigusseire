insert into silver.fact_respiratory_surveillance (
    yearweek,
    countryname,
    survtype,
    pathogen,
    indicator,
    value
)
select
    yearweek,
    countryname,
    survtype,
    pathogen,
    indicator,
    sum(value) as value
from bronze.raw_ecdc_tests
where pathogen in ('Influenza', 'RSV', 'SARS-CoV-2')
    and indicator in ('detections', 'tests')
group by
    yearweek,
    countryname,
    survtype,
    pathogen,
    indicator

on conflict (
    yearweek,
    countryname,
    survtype,
    pathogen,
    indicator
)

do update set
    value = excluded.value,
    updated_at = current_timestamp;
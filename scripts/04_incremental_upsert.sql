/*  ========================================================
    INCREMENTAL LOAD: bronze -> silver
    Teeb:
   - INSERT uued read
   - UPDATE muutunud read
   - AUDIT kustutatavad read
   - DELETE puuduvad read
    ======================================================== */

/* =========================================================
   1. UPSERT (INSERT + UPDATE)
   ========================================================= */

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
where pathogen in (
    'Influenza',
    'RSV',
    'SARS-CoV-2'
)
    
and indicator in (
    'detections',
    'tests'
)

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

/* =====================================================
AUDIT - KUSTUTAMISELE MINEVAD READ
======================================================== */
insert into audit.deleted_fact_respiratory_surveillance (

    yearweek,
    countryname,
    survtype,
    pathogen,
    indicator,
    value,
    created_at,
    updated_at
)

select

    tgt.yearweek,
    tgt.countryname,
    tgt.survtype,
    tgt.pathogen,
    tgt.indicator,
    tgt.value,
    tgt.created_at,
    tgt.updated_at

from silver.fact_respiratory_surveillance tgt
where not exists (
    select 1
    from (
        select
            yearweek,
            countryname,
            survtype,
            pathogen,
            indicator

        from bronze.raw_ecdc_tests
        where pathogen in (
            'Influenza',
            'RSV',
            'SARS-CoV-2'
        )

        and indicator in (
            'detections',
            'tests'
        )

        group by
            yearweek,
            countryname,
            survtype,
            pathogen,
            indicator

    ) src

    where src.yearweek = tgt.yearweek
      and src.countryname = tgt.countryname
      and src.survtype = tgt.survtype
      and src.pathogen = tgt.pathogen
      and src.indicator = tgt.indicator
);

/* ======================================================
DELETE FAKTITABELIST
========================================================= */
delete from silver.fact_respiratory_surveillance tgt
where not exists (
    select 1
    from (
        select
            yearweek,
            countryname,
            survtype,
            pathogen,
            indicator

        from bronze.raw_ecdc_tests
        where pathogen in (
            'Influenza',
            'RSV',
            'SARS-CoV-2'
        )

        and indicator in (
            'detections',
            'tests'
        )

        group by
            yearweek,
            countryname,
            survtype,
            pathogen,
            indicator

    ) src

    where src.yearweek = tgt.yearweek
      and src.countryname = tgt.countryname
      and src.survtype = tgt.survtype
      and src.pathogen = tgt.pathogen
      and src.indicator = tgt.indicator
);

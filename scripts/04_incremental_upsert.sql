/* UNIQUE constraint / index ON CONFLICT jaoks, sest oodatud tulemuses on nende 5 veeru kombinatsioon tabelis unikaalne */
create unique index if not exists uq_fact_respiratory
on silver.fact_respiratory_surveillance (
    yearweek,
    countryname,
    survtype,
    pathogen,
    indicator
);

/* UPSERT (INSERT + UPDATE) */

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


/* DELETE read, mida source'is enam pole, eemaldame ka tabelist */

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

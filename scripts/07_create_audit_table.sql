/* loome tabeli, kus hoiame ülevaadet kustutatud ridadest nendes olnud andmetega ja kustutamisajaga 
Kui kaua siin andmeid hoida, on otsustamise koht, aga testimisel kindlasti abiks */
create table if not exists audit.deleted_fact_respiratory_surveillance (

    deleted_at timestamp default current_timestamp,
    delete_reason text default 'missing_from_source',

    yearweek text,
    countryname text,
    survtype text,
    pathogen text,
    indicator text,
    value numeric,

    created_at timestamp,
    updated_at timestamp
);

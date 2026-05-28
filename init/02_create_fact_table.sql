/* loome faktitabeli lähtudes äriloogika vajadustest
value on integer, sest biginti pole maailma rahvaarvu vaadates meil tarvis, seda enam et jälgime vaid euroopa riike. 
Tehtud ja tuvastatud testide arv on alati täisarv
Positiivsete testide protsenti toorandmetest üle ei too, vaid vajadusel arvutame ise, sest andmed võivad uueneda ka tagantjärgi 
*/

create table silver.fact_respiratory_surveillance (

    yearweek        varchar(10),
    countryname     varchar(100),
    survtype        varchar(100),
    pathogen        varchar(50),
    indicator       varchar(20),
    value           integer,
    created_at      timestamptz default current_timestamp,
    updated_at      timestamptz default current_timestamp,

    primary key (
        yearweek,
        countryname,
        survtype,
        pathogen,
        indicator
    )
);
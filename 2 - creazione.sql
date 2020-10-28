create domain codfis as varchar(16);
create domain stars as integer check (value >= 0 AND value <= 10);

create table cinema (
    id serial primary key,
    citta varchar(255) not null,
    nome varchar(255) unique not null,
    telefono varchar(16) unique,
    totale_dipendenti int not null
);

create table sale (
    numerosala int not null,
    idcinema int not null references cinema,
    superficie int not null,
    capienza int not null,
    primary key(numerosala, idcinema)
);

create table film (
    id serial primary key,
    durata int not null,
    regia varchar(255) not null,
    genere varchar(255) not null,
    anno int not null,
    rating stars,
    titolo varchar(255) not null,
    nazione varchar(3) not null,
    sequel_di int unique references film,
    proiezioni_totali int not null
);

create table attori (
    cf codfis primary key,
    nome varchar(255) not null
);

create table proiezioni (
    id serial primary key,
    costo real not null,
    vendite int not null,
    orario timestamp not null,
    idfilm int not null references film,
    idsala int not null,
    idcinema int not null,
    capienza_sala int not null,
    fine_proiezione timestamp not null,
    foreign key (idsala, idcinema) references sale(numerosala, idcinema) on update cascade
);

create table dipendenti (
    cf codfis primary key,
    nome varchar(255) not null,
    telefono varchar(16)
);

create table impieghi_correnti (
    cfdipendente codfis not null references dipendenti on update cascade on delete no action,
    idcinema int not null references cinema,
    mansione varchar(16) not null,
    inizio timestamp not null,
    stipendio int not null,
    primary key(cfdipendente, idcinema, mansione)
);

create table storico_impieghi (
    cfdipendente codfis not null references dipendenti on update cascade on delete cascade,
    idcinema int not null references cinema,
    mansione varchar(16) not null,
    inizio timestamp not null,
    fine timestamp not null,
    primary key(cfdipendente, idcinema, mansione, inizio)
);

create table ruoli (
    cfattore codfis not null references attori on update cascade on delete no action,
    film int not null references film,
    ruolo varchar(255) not null,
    primary key (cfattore, film)
);

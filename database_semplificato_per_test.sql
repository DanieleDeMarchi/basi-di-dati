CREATE TABLE cinema
(
    id integer NOT NULL,
    citta character varying(255) COLLATE pg_catalog."default" NOT NULL,
    nome character varying(255) COLLATE pg_catalog."default" NOT NULL,
    telefono character varying(16) COLLATE pg_catalog."default",
    totale_dipendenti integer NOT NULL,
    CONSTRAINT cinema_pkey PRIMARY KEY (id),
    CONSTRAINT cinema_nome_key UNIQUE (nome),
    CONSTRAINT cinema_telefono_key UNIQUE (telefono)
);

CREATE TABLE dipendente
(
    cf character varying(16) COLLATE pg_catalog."default" NOT NULL,
    nome character varying(255) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT dipendente_pkey PRIMARY KEY (cf)
);

CREATE TABLE impieghi_correnti
(
    cfdipendente character varying(16) COLLATE pg_catalog."default" NOT NULL,
    idcinema integer NOT NULL,
    mansione character varying(16) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT impieghi_correnti_pkey PRIMARY KEY (cfdipendente, idcinema, mansione),
    CONSTRAINT impieghi_correnti_cfdipendente_fkey FOREIGN KEY (cfdipendente)
        REFERENCES public.dipendente (cf) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT impieghi_correnti_idcinema_fkey FOREIGN KEY (idcinema)
        REFERENCES public.cinema (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);


insert into cinema 
(id, citta, nome, telefono, totale_dipendenti)
VALUES (1, 'mareno', 'pippo', '0438492597', 14),
(2, 'mareno0000', 'pipp0000o', '000438492597', 15);

insert into dipendente(cf, nome)
VALUES ('pippo123', 'pippo'),
('inzaghi123', 'inzaghi'),
('pluto123', 'pluto');

insert into impieghi_correnti
(cfdipendente, idcinema, mansione)
VALUES('pippo123', 1, 'manager'),
('inzaghi123', 1,'sasasa'),
('pluto123', 1, 'dsdsds'),
('pluto123', 2, 'dsdsds');


CREATE TABLE public.film
(
    id integer NOT NULL,
    prequel integer,
    CONSTRAINT film_pkey PRIMARY KEY (id),
    CONSTRAINT film_prequel_key UNIQUE (prequel),
    CONSTRAINT film_prequel_fkey FOREIGN KEY (prequel)
        REFERENCES public.film (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);

insert into film
(id, prequel)
VALUES(1, NULL),
(2, NULL),
(3, NULL),
(4, NULL),
(5, NULL),
(6, 3),
(7, NULL),
(8, 6),
(9, NULL);

CREATE TABLE public.attore
(
    cf character varying(16) COLLATE pg_catalog."default" NOT NULL,
    nome character varying(255) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT attore_pkey PRIMARY KEY (cf)
);


insert into attore
(cf, nome)
VALUES ('pippo123', 'Pippo'),
('inzaghi123', 'inzaghi'),
('pluto123', 'Pippo');

CREATE TABLE public.ruoli
(
    cfattore character varying(16) COLLATE pg_catalog."default" NOT NULL,
    film integer NOT NULL,
    CONSTRAINT ruoli_pkey PRIMARY KEY (cfattore, film),
    CONSTRAINT ruoli_cfattore_fkey FOREIGN KEY (cfattore)
        REFERENCES public.attore (cf) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT ruoli_film_fkey FOREIGN KEY (film)
        REFERENCES public.film (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);

insert into ruoli
VALUES ('pippo123', 3),
('pippo123', 5),
('inzaghi123', 3),
('inzaghi123', 4),
('pluto123', 5),
('pluto123', 3);

CREATE TABLE public.proiezione
(
    id integer NOT NULL,
    costo real NOT NULL,
    vendite integer NOT NULL,
    idfilm integer NOT NULL,
    CONSTRAINT proiezione_pkey PRIMARY KEY (id),
    CONSTRAINT proiezione_idfilm_fkey FOREIGN KEY (idfilm)
        REFERENCES public.film (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);


insert into proiezione values
(1, 5, 10, 1),
(2, 10, 20, 1),
(3, 5, 10, 3),
(4, 10, 10, 3),
(5, 5, 20, 1),
(6, 10, 20, 1),
(7, 5, 10, 1),
(8, 10, 120, 5),
(9, 5, 100, 7),
(10, 10, 10, 1);



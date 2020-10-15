-------------------------------------------------------------------------
--- Trigger per inserimento automatico in storico impieghi  WORKING

CREATE FUNCTION public.addto_storico_impieghi()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
BEGIN
    INSERT INTO storico_impieghi
        (cfdipendente, idcinema, mansione, inizio, fine)
    VALUES
        (old.cfdipendente, old.idcinema, old.mansione, old.inizio, current_date);

    return null;
END;
$BODY$;


CREATE TRIGGER addto_storico_impieghi
    AFTER
DELETE
    ON public.impieghi_correnti
    FOR EACH ROW
EXECUTE
PROCEDURE public.addto_storico_impieghi
();


-------------------------------------------------------------------------
--- Trigger per inserimento in storico_impieghi alla modifica della mansione o idcinema in impieghi correnti
--- Per mantenere traccia degli impieghi passati anche in caso di modifica
CREATE FUNCTION public.addto_storico_impieghi_update()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
BEGIN
    IF new.mansione<>old.mansione OR new.idcinema<>old.idcinema THEN
        INSERT INTO storico_impieghi
            (cfdipendente, idcinema, mansione, inizio, fine)
        VALUES
            (old.cfdipendente, old.idcinema, old.mansione, old.inizio, current_date);
     END IF;

    return null;
END;
$BODY$;


CREATE TRIGGER addto_storico_impieghi_update_trigger
    AFTER
UPDATE
    ON public.impieghi_correnti
    FOR EACH ROW
EXECUTE
PROCEDURE public.addto_storico_impieghi_update
();


-------------------------------------------------------------------------
--- Trigger per cambiare manager di un cinema         WORKING



CREATE FUNCTION change_manager()
    RETURNS trigger
    LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    IF new.mansione='manager' THEN
        PERFORM * FROM impieghi_correnti WHERE idcinema=new.idcinema AND mansione='manager' ;
            IF FOUND THEN
                DELETE FROM impieghi_correnti WHERE mansione='manager' AND idcinema=new.idcinema;
                return new;
            ELSE
                return new;
            END IF;
    ELSE
        return new;
    END IF;
END;
$BODY$;

CREATE TRIGGER change_manager_trigger
    BEFORE
INSERT OR UPDATE
    ON public.impieghi_correnti
    FOR EACH ROW
EXECUTE
PROCEDURE change_manager
();

-------------------------------------------------------------------------
--- Trigger per controllare che non si elimini un manager    WORKING


CREATE FUNCTION manager_delete()
    RETURNS trigger
    LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    
    IF old.mansione='manager' THEN
        raise notice 'Un manager non può essere eliminato, può solo essere sostituito';
        return null;
    ELSE
        return old;
    END IF;
END;
$BODY$;


CREATE TRIGGER manager_delete_trigger
    BEFORE
DELETE
    ON public.impieghi_correnti
    FOR EACH ROW
    WHEN (pg_trigger_depth() < 1)
EXECUTE
PROCEDURE manager_delete
();



-------------------------------------------------------------------------
--- Trigger per evitare la sovrapposizione degli orari di una proiezione                     WORKING
--- Inoltre tra una proiezione e l'altra in una stessa sala devono passare 30 minuti


CREATE FUNCTION check_sovrapposizione_orari()
    RETURNS trigger
    LANGUAGE 'plpgsql'
AS $BODY$
DECLARE durata_film integer;
DECLARE fine_nuova_proiezione timestamp without time zone;
BEGIN
    SELECT durata into durata_film 
    FROM film
    WHERE id=new.idfilm;

    fine_nuova_proiezione := new.datetime + (durata_film * interval '1 minute') ;

    if  (TG_OP = 'INSERT') then
            PERFORM * FROM proiezioni WHERE new.idsala=idsala 
                                        AND new.idcinema=idcinema 
                                        AND (new.datetime, fine_nuova_proiezione + (30 * interval '1 minute')) OVERLAPS (datetime, fine_proiezione + (30 * interval '1 minute'));
            IF FOUND THEN
                raise notice 'Esiste già un film in proiezione nella stesso cinema,sala alla stessa ora';
                return null;
            END IF;
    end if;

    if  (TG_OP = 'UPDATE') then
            PERFORM * FROM proiezioni WHERE new.id<>old.id 
                                        AND new.idsala=idsala 
                                        AND new.idcinema=idcinema 
                                        AND (new.datetime, fine_nuova_proiezione + (30 * interval '1 minute')) OVERLAPS (datetime, fine_proiezione + (30 * interval '1 minute'));
            IF FOUND THEN
                raise notice 'Esiste già un film in proiezione nella stesso cinema,sala alla stessa ora';
                return null;
            END IF;
    end if;
    
    return new;
END;
$BODY$;



CREATE TRIGGER check_orari_proiezione
    BEFORE
INSERT OR UPDATE
    ON public.proiezioni
    FOR EACH ROW
EXECUTE
PROCEDURE check_sovrapposizione_orari
();


-------------------------------------------------------------------------
--- Trigger per inserire il dato ridondante fine_proiezione nella tabella proiezione  WORKING


CREATE FUNCTION public.add_fineProiezione()
    RETURNS trigger
    LANGUAGE 'plpgsql'
AS $BODY$
declare durata_film integer;
BEGIN
    SELECT durata into durata_film 
    FROM film
    WHERE id=new.idfilm;

    new.fine_proiezione := new.datetime + (durata_film * interval '1 minute') ;

    return new;
END;
$BODY$;


CREATE TRIGGER add_fineProiezione_trigger
    BEFORE
INSERT OR UPDATE
    ON public.proiezioni
    FOR EACH ROW
EXECUTE
PROCEDURE public.add_fineProiezione
();

-------------------------------------------------------------------------
--- Trigger per inserire il dato ridondante capienza sala nella tabella proiezione  WORKING

CREATE FUNCTION public.add_capienza()
    RETURNS trigger
    LANGUAGE 'plpgsql'
AS $BODY$
declare capienza_new integer;
BEGIN
    SELECT capienza into capienza_new
    FROM sale
    WHERE idcinema=new.idcinema AND numerosala=new.idsala;

    new.capienza_sala := capienza_new;

    return new;
END;
$BODY$;


CREATE TRIGGER add_capienza_sala
    BEFORE
INSERT
    ON public.proiezioni
    FOR EACH ROW
EXECUTE
PROCEDURE public.add_capienza
();

-------------------------------------------------------------------------
--- Trigger per controllare che la capienza della sala non venga superata   WORKING

CREATE FUNCTION public.controlla_capienza_trigger()
    RETURNS trigger
    LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    if new.vendite > new.capienza_sala THEN
        raise notice 'Il numero di biglietti venduti non può superare la capienza della sala';
        return null;
    else
        return new;
    end if;
END;
$BODY$;


CREATE TRIGGER controlla_capienza_trigger
    BEFORE
UPDATE
    ON public.proiezioni
    FOR EACH ROW
EXECUTE
PROCEDURE public.controlla_capienza_trigger
();
-----------------------------------------------------------
-----        Trigger per ridondanze      ------------------
-----------------------------------------------------------

---Ridondanza conteggio totale proiezione di un film  WORKING
CREATE FUNCTION public.add_proiezione()
    RETURNS trigger
    LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    UPDATE film SET proiezioni_totali = proiezioni_totali + 1 WHERE id=new.idfilm;
    return null;
END;
$BODY$;

CREATE TRIGGER add_proiezione_trigger
    AFTER
INSERT
    ON public.proiezioni
    FOR EACH ROW
EXECUTE
PROCEDURE public.add_proiezione
();


CREATE FUNCTION public.delete_proiezione()
    RETURNS trigger
    LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    UPDATE film SET proiezioni_totali = proiezioni_totali - 1 WHERE id=old.idfilm;
    return null;
END;
$BODY$;

CREATE TRIGGER delete_proiezione_trigger
    AFTER
DELETE
    ON public.proiezioni
    FOR EACH ROW
EXECUTE
PROCEDURE public.delete_proiezione
();


CREATE FUNCTION public.update_proiezione()
    RETURNS trigger
    LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    UPDATE film SET proiezioni_totali = proiezioni_totali - 1 WHERE id=old.idfilm;
    UPDATE film SET proiezioni_totali = proiezioni_totali + 1 WHERE id=new.idfilm;
    return null;

END;
$BODY$;


CREATE TRIGGER update_proiezione_trigger
    AFTER
UPDATE
    ON public.proiezioni
    FOR EACH ROW
EXECUTE
PROCEDURE public.update_proiezione
();


---Ridondanza conteggio totale dipendenti cinema  OK
CREATE FUNCTION public.add_dipendente()
    RETURNS trigger
    LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    UPDATE cinema SET totale_dipendenti = totale_dipendenti + 1 WHERE id=new.idcinema;
    return null;
END;
$BODY$;

CREATE TRIGGER insert_conteggio
    AFTER
INSERT
    ON public.impieghi_correnti
    FOR EACH ROW
EXECUTE
PROCEDURE public.add_dipendente
();

CREATE FUNCTION public.subtract_dipendente()
    RETURNS trigger
    LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    UPDATE cinema SET totale_dipendenti = totale_dipendenti - 1 WHERE id=old.idcinema;
    return null;
END;
$BODY$;

CREATE TRIGGER delete_conteggio
    AFTER
DELETE
    ON public.impieghi_correnti
    FOR EACH ROW
EXECUTE
PROCEDURE public.subtract_dipendente
();


CREATE FUNCTION public.change_dipendente()
    RETURNS trigger
    LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    UPDATE cinema SET totale_dipendenti = totale_dipendenti - 1 WHERE id=old.idcinema;
    UPDATE cinema SET totale_dipendenti = totale_dipendenti + 1 WHERE id=new.idcinema;
    return null;

END;
$BODY$;


CREATE TRIGGER update_conteggio
    AFTER
UPDATE
    ON public.impieghi_correnti
    FOR EACH ROW
EXECUTE
PROCEDURE public.change_dipendente
();


-----------------------------------------------------------
-----    Trigger per vincoli integrità   ------------------
-----------------------------------------------------------

---Trigger per impedire la modifica di id in cinema
CREATE FUNCTION prevent_update_idcinema()
    RETURNS trigger
    LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    if new.id <> old.id THEN
        raise notice 'Il campo id di cinema non può essere modificato';
        return null;
    else
        return new;
    end if;

END;
$BODY$;

CREATE TRIGGER prevent_update_idcinema_trigger
    BEFORE
UPDATE
    ON public.cinema
    FOR EACH ROW
EXECUTE
PROCEDURE prevent_update_idcinema
();


---Trigger per impedire la modifica di id in cinema

CREATE FUNCTION prevent_update_idproiezione()
    RETURNS trigger
    LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    if new.id <> old.id THEN
        raise notice 'Il campo id di proiezione non può essere modificato';
        return null;
    else
        return new;
    end if;

END;
$BODY$;

CREATE TRIGGER prevent_update_idproiezione_trigger
    BEFORE
UPDATE
    ON public.proiezioni
    FOR EACH ROW
EXECUTE
PROCEDURE prevent_update_idproiezione
();

----------------------------------------------------------------------
---Trigger per impedire la modifica di un record in storico_impieghi

CREATE FUNCTION prevent_update_storico_impieghi()
    RETURNS trigger
    LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    raise notice 'La tabella storico_impieghi viene popolata automaticamente. Non è possibile modificare un record in storico_impieghi';
    return null;
END;
$BODY$;


CREATE TRIGGER prevent_update_storico_impieghi_trigger
    BEFORE
UPDATE
    ON public.storico_impieghi
    FOR EACH ROW
EXECUTE
PROCEDURE prevent_update_storico_impieghi
();

----------------------------------------------------------------------
---Trigger per impedire l'inserimento di un record in storico_impieghi
CREATE FUNCTION prevent_insert_storico_impieghi()
    RETURNS trigger
    LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    raise notice 'La tabella storico_impieghi viene popolata automaticamente. Non è possibile inserire un record in storico_impieghi';
    return null;
END;
$BODY$;


CREATE TRIGGER prevent_insert_storico_impieghi_trigger
    BEFORE
INSERT
    ON public.storico_impieghi
    FOR EACH ROW
    WHEN (pg_trigger_depth() < 1)
EXECUTE
PROCEDURE prevent_insert_storico_impieghi
();

----------------------------------------------------------------------
---Trigger per impostare a 0 il campo totale_dipendenti in un nuovo cinema

CREATE FUNCTION totale_dipendenti_setzero()
    RETURNS trigger
    LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    if new.totale_dipendenti <> 0 THEN
        raise notice 'Il campo totale dipendenti deve essere inserito a 0. Viene poi automaticamente incrementato o decrementato.';
        new.totale_dipendenti := 0
        raise notice 'Il campo totale dipendenti è stato impostato a zero';
        return new;
    else
        return new;
    end if;
END;
$BODY$;


CREATE TRIGGER totale_dipendenti_notzero_trigger
    BEFORE
INSERT
    ON public.cinema
    FOR EACH ROW
EXECUTE
PROCEDURE totale_dipendenti_setzero
();

----------------------------------------------------------------------
---Trigger per impostare a 0 il campo proiezioni_totali in una nuovo film

CREATE FUNCTION proiezioni_totali_setzero()
    RETURNS trigger
    LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    if new.proiezioni_totali <> 0 THEN
        raise notice 'Il campo proiezioni_totali deve essere inserito a 0. Viene poi automaticamente incrementato o decrementato.';
        new.proiezioni_totali := 0
        raise notice 'Il campo proiezioni_totali è stato impostato a zero';
        return new;
    else
        return new;
    end if;
END;
$BODY$;


CREATE TRIGGER proiezioni_totali_notzero_trigger
    BEFORE
INSERT
    ON public.film
    FOR EACH ROW
EXECUTE
PROCEDURE proiezioni_totali_setzero
();

----------------------------------------------------------------------
---Trigger per impedire la modifica di proiezioni_totali in film

CREATE FUNCTION prevent_update_proiezioni_totali()
    RETURNS trigger
    LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    if new.proiezioni_totali <> old.proiezioni_totali THEN
        raise notice 'Il campo proiezioni_totali di film non può essere modificato. Viene automaticamente incrementato o decrementato.';
        return null;
    else
        return new;
    end if;
END;
$BODY$;


CREATE TRIGGER prevent_update_proiezioni_totali_trigger
    BEFORE
UPDATE
    ON public.film
    FOR EACH ROW
    WHEN (pg_trigger_depth() < 1)
EXECUTE
PROCEDURE prevent_update_proiezioni_totali
();

----------------------------------------------------------------------
---Trigger per impedire la modifica di torale_dipendenti in cinema

CREATE FUNCTION prevent_update_totale_dipendenti
    RETURNS trigger
    LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    if new.totale_dipendenti <> old.totale_dipendenti THEN
        raise notice 'Il campo totale_dipendenti di cinema non può essere modificato. Viene automaticamente incrementato o decrementato.';
        return null;
    else
        return new;
    end if;
END;
$BODY$;


CREATE TRIGGER prevent_update_totale_dipendenti_trigger
    BEFORE
UPDATE
    ON public.cinema
    FOR EACH ROW
    WHEN (pg_trigger_depth() < 1)
EXECUTE
PROCEDURE prevent_update_totale_dipendenti
();

/*
INSERT INTO dipendenti VALUES ('1', 'pippo', '0438'), ('2', 'pluto', '0439');

INSERT INTO cinema VALUES ('1', 'pippo', 'pluto', '0466', 0);

INSERT INTO impieghi_correnti VALUES ('1', '1', 'manager', current_date, 1500), ('2', '1', 'aaaa', current_date, 1500);

insert into film (id, durata, regia, anno, titolo, nazione, proiezioni_totali)values (1, 90, 'aaa', '2000', 'titolo1', 'ita', 0);

insert into proiezioni values (0, 5, 0, current_timestamp, 1, 1, 1, 0, current_timestamp);
*/

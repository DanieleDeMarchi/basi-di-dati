/*****************************************
**********      Query    *****************
*****************************************/

--- Tutti gli impiegati che lavorano in un solo cinema  OK
SELECT * FROM dipendenti as D1
WHERE EXISTS (SELECT * FROM impieghi_correnti as I1
              WHERE I1.cfdipendente=D1.cf 
                    AND NOT EXISTS (SELECT * FROM impieghi_correnti as I2
                                    WHERE I2.cfdipendente=D1.cf AND I2.idcinema<>I1.idcinema))

--- Film a cui ha partecipato l'attore "Pippo"   OK
--- Attenzione: ci possono essere più attori che si chiamano pippo
--- quindi torna tutti i film a cui hanno partecipato attori che si chiamano pippo
--- Se si volesse trovare i film a cui ha partecipato uno specifico attore usare la query successiva
SELECT film.titolo 
FROM film JOIN ruoli ON film.id=ruoli.film JOIN attori ON ruoli.cfattore=attore.cf
WHERE attori.nome='Pippo'

--- Film a cui ha partecipato l'attore dal codice fiscale "pippo123"   OK
SELECT film.titolo 
FROM film JOIN ruoli ON film.id=ruoli.film
WHERE ruoli.cfattore='pippo123'


--- Trilogie (Non comprende serie da 4 o più film) OK
SELECT F1.titolo as Primo_film, F2.titolo as Secondo_film, F3.titolo as Terzo_film
FROM film as F1, film as F2, film as F3
WHERE EXISTS
            (SELECT * FROM film WHERE id=F2.id AND sequel_di=F1.id)
      AND EXISTS
            (SELECT * FROM film WHERE id=F3.id AND sequel_di=F2.id)
      AND NOT EXISTS
            (SELECT * FROM film WHERE sequel_di=F3.id)



--- Dati di tutti i cinema compreso il nome del manager   OK
SELECT c1.citta, c1.nome, c1.telefono, c1.totale_dipendenti, m.nome
FROM cinema as c1, dipendenti as m
WHERE EXISTS (SELECT * FROM impieghi_correnti
                WHERE mansione='manager' AND cfdipendente=m.cf AND idcinema=c1.id)

--- attori che hanno partecipato esattamente agli stessi film OK
SELECT A1.cf as codfis_attore1, A1.nome as nome_attore1, A2.cf as codfis_attore2, A2.nome as nome_attore2
FROM attori as A1, attori as A2
WHERE A1.cf<A2.cf AND
    NOT EXISTS (SELECT * FROM ruoli as R1
                WHERE R1.cfattore=A1.cf AND
                    NOT EXISTS (SELECT * FROM ruoli as R2
                                WHERE R2.cfattore=A2.cf AND R2.film=R1.film))
    AND NOT EXISTS (SELECT * FROM ruoli as R1
                    WHERE R1.cfattore=A2.cf AND
                        NOT EXISTS (SELECT * FROM ruoli as R2
                                    WHERE R2.cfattore=A1.cf AND R2.film=R1.film))


--- Attore/i che hanno partecipato al maggior numero di film OK
SELECT p0.cfattore, COUNT(p0.cfattore) AS totale_comparse
FROM ruoli p0
WHERE (SELECT COUNT(*)
    FROM ruoli p1
    WHERE p0.cfattore = p1.cfattore)
    >= ALL 
    (SELECT COUNT(*)
    FROM ruoli p2
      WHERE p0.cfattore <> p2.cfattore
    GROUP BY p2.cfattore
   )
GROUP BY p0.cfattore


/*****************************************
**********      VISTE    *****************
*****************************************/

--- Vista tabella manager
CREATE VIEW manager AS
      SELECT D.cf, D.nome, I.stipendio, C.id AS ID_cinema, C.citta AS Citta_cinema, C.nome AS nome_cinema
      FROM dipendenti AS D JOIN impieghi_correnti AS I ON D.cf=I.cfdipendente JOIN cinema AS C ON I.idcinema=C.id
      WHERE mansione='manager';


--- Vista 10 Film più proiettati OK
CREATE VIEW piu_proiettati AS
      SELECT titolo, proiezioni_totali
      FROM film
      ORDER BY proiezioni_totali DESC
      FETCH first 10 rows only;

--- Vista 10 Film con maggior incasso OK
CREATE VIEW best_box_office AS
      SELECT F1.titolo, SUM(P1.costo*P1.vendite)as incasso_totale
      FROM film as F1 JOIN proiezioni as P1 ON F1.id=P1.idfilm
      GROUP BY F1.id
      ORDER BY incasso_totale DESC
      FETCH first 10 rows only;
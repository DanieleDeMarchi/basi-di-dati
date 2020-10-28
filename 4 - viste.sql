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


CREATE OR REPLACE VIEW public.proiezioni_future AS
      SELECT p1.id AS id_proiezione,
      f.titolo,
      p1.capienza_sala - p1.vendite AS posti_dipsonibili,
      p1.costo,
      p1.idsala,
      p1.idcinema,
      p1.orario,
      f.durata
      FROM proiezioni p1 JOIN film f ON f.id = p1.idfilm
      WHERE p1.orario::date > CURRENT_DATE;

CREATE VIEW proiezioni_odierne AS
      SELECT p1.id AS id_proiezione,
      f.titolo,
      p1.capienza_sala - p1.vendite AS posti_dipsonibili,
      p1.costo,
      p1.idsala,
      p1.idcinema,
      p1.orario,
      f.durata
      FROM proiezioni p1 JOIN film f ON f.id = p1.idfilm
      WHERE p1.orario::date = CURRENT_DATE;

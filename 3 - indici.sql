--- Sarà frequente l'accesso alle proiezioni recenti 
CREATE INDEX per_data ON proiezioni(datetime);
 
--- È plausibile che si ricerchi spesso un dipendente per il cinema in cui lavora
CREATE INDEX per_cinema ON impieghi_correnti(idcinema);

--- Tutto ciò che viene utilizzato frequentemente nei JOIN è possibile indicizzare
CREATE INDEX mansioni_per_cf ON impieghi_correnti(cfdipendente);
CREATE INDEX ruoli_per_cf ON ruoli(cfattore);
CREATE INDEX sale_per_cinema ON sale(idcinema); --- Forse è già definito essendo parte della chiave primaria, o forse l'indice primario è fatto su una "firma" di tutte le sue componenti. A seconda del caso, questa è da rimuovere

--- Sarà frequente l'accesso alle proiezioni recenti 
CREATE INDEX per_data ON proiezioni(orario);
 
--- È plausibile che si ricerchi spesso un dipendente per il cinema in cui lavora
CREATE INDEX per_cinema ON impieghi_correnti(idcinema);

--- Allo stesso modo è facile che si cerchi un dipendente per nome, piuttosto che per codice fiscale
CREATE INDEX per_cinema ON dipendenti(nome);

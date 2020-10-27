#installare le librerie se non installate
#install.packages("getPass")
#install.packages("RPostgreSQL")



library("RPostgreSQL")
library(getPass)

drv <- dbDriver("PostgreSQL")

con <- dbConnect(
  drv,
  dbname="laboratorio",
  host="",
  port=,
  user="",
  password = getPass("Enter Password:")
)



incassofilm <- dbGetQuery(con, "SELECT F1.titolo, F1.genere, SUM(P1.costo*P1.vendite)as incasso_totale
                                FROM film as F1 JOIN proiezioni as P1 ON F1.id=P1.idfilm
                                GROUP BY F1.id
                                ORDER BY incasso_totale DESC")

#Film per anno
barplot(table(incassofilm$anno),
        main="Film per anno",
        xlab="Anno",ylab="Numero film",
        ylim = c(0,8),
        cex.names = 0.7
)

#Boxplot incasso per genere, da modificare con incasso film per genere
boxplot(incassofilm1$incasso_totale ~ incassofilm1$genere,
        main="Boxplot incasso film per genere",
        xlab="Genere",ylab="Incasso film") 

mansioni <- dbGetQuery(con, "SELECT * FROM impieghi_correnti")

#Dipendenti per mansione
barplot(table(mansioni$mansione),
        main="Dipendenti per mansione",
        xlab="Mansione",ylab="Numero dipendenti",
        cex.names = 0.7
)

#Boxplot stipendio per mansione
boxplot(mansioni$stipendio ~ mansioni$mansione,
        main="Boxplot stipendio per mansione",
        xlab="Mansione",ylab="Stipendio",
        cex.axis = 0.7
        ) 

#Proiezioni per mese
proiezioniPerMese <- dbGetQuery(con, "SELECT count (*) as tot, date_trunc('month', datetime) as mese_proiezione
                                FROM proiezioni
                                WHERE datetime > '2018-1-1'
                                Group by mese_proiezione
								                Order by mese_proiezione")

proiezioniPerMese$mese_proiezione <- gsub(" CET", "", proiezioniPerMese$mese_proiezione)
proiezioniPerMese$mese_proiezione <- as.Date(proiezioniPerMese$mese_proiezione)

plot(proiezioniPerMese$mese_proiezione, proiezioniPerMese$tot, xaxt="n", type="l",
     main="Proiezioni per mese",
     xlab="Data",ylab="Numero proiezioni")
axis.Date(1, at=seq(min(proiezioniPerMese$mese_proiezione), max(proiezioniPerMese$mese_proiezione), by="months"), format="%m-%Y")

#proiezione per giorno della settimana
proiezioniPerGiorno<- dbGetQuery(con, "SELECT count (*) as tot, extract(isodow from proiezioni.datetime::date) - 1 as giorno
                                FROM proiezioni
                                Group by giorno
								                Order by giorno")

proiezioniPerGiorno$giorno <- c("Lun", "Mar", "Mer", "Gio", "Ven", "Sab", "Dom")
barplot(proiezioniPerGiorno$tot, names.arg=proiezioniPerGiorno$giorno,
        main="Proiezioni per giorno settimanale",
        xlab="Giorno", ylab="Proiezione",
        ylim = range(0,max(proiezioniPerGiorno$tot))
        )


#incasso per mese
incassiPerMese <- dbGetQuery(con, "SELECT sum (vendite*costo) as tot, date_trunc('month', datetime) as mese_proiezione
                                FROM proiezioni
                                WHERE datetime > '2018-1-1'
                                Group by mese_proiezione
								                Order by mese_proiezione")


incassiPerMese$mese_proiezione <- gsub(" CET", "", incassiPerMese$mese_proiezione)
incassiPerMese$mese_proiezione <- as.Date(incassiPerMese$mese_proiezione)

plot(incassiPerMese$mese_proiezione, incassiPerMese$tot, xaxt="n", type="l",
     main="Incassi per mese",
     xlab="Data",ylab="Incasso")
axis.Date(1, at=seq(min(incassiPerMese$mese_proiezione), max(incassiPerMese$mese_proiezione), by="months"), format="%m-%Y")

#incasso per giorno della settimana
incassoPerGiorno<- dbGetQuery(con, "SELECT sum (vendite*costo) as tot, extract(isodow from proiezioni.datetime::date) - 1 as giorno
                                FROM proiezioni
                                Group by giorno
								                Order by giorno")

incassoPerGiorno$giorno <- c("Lun", "Mar", "Mer", "Gio", "Ven", "Sab", "Dom")
barplot(incassoPerGiorno$tot, names.arg=incassoPerGiorno$giorno,
        main="Incassi per giorno settimanale",
        xlab="Giorno", ylab="Incasso",
        ylim = range(0,max(incassoPerGiorno$tot))
)

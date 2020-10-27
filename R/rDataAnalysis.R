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



incassoFilm <- dbGetQuery(con, "SELECT * FROM best_box_office_all")

#Film per anno
barplot(table(incassoFilm$anno),
        main="Film per anno",
        xlab="Anno",ylab="Numero film",
        ylim = c(0,8),
        cex.names = 0.7
)

#Boxplot incasso per anno, da modificare con incasso film per genere
boxplot(incassoFilm$incasso_totale ~ incassoFilm$anno,
        main="Boxplot incasso per anno",
        xlab="Anno",ylab="Incasso film") 

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


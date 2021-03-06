### Analisi delle ridondanze e campi derivati

È stata innanzitutto redatta la tabella dei volumi, secondo dei numeri ipotizzati secondo quello che al momento poteva sembrare verosimile.

<style>
table, th, td {
  border: 1px solid black;
  text-align: center;
  border-collapse: collapse;
}

th, td {
  padding: 6px;
}
</style>

| Tabella volumi    |      |        |
| ----------------- | ---- | ------ |
| Concetto          | Tipo | Volume |
| Cinema            | E    | 5      |
| Appartiene        | R    | 25     |
| Sala              | E    | 25     |
| Dipendente        | E    | 250    |
| Manager           | E    | 5      |
| Gestisce          | R    | 5      |
| Impieghi correnti | R    | 100    |
| Storico impieghi  | R    | 400    |
| Proiezione        | E    | 35,000 |
| Proiettato in     | R    | 35,000 |
| Film              | E    | 500    |
| Proiezione di     | R    | 35,000 |
| Attore            | E    | 2,000  |
| Partecipa         | R    | 6,000  |
| Sequel di         | R    | 20     |

Si procede col calcolare, per ogni dato ridondante, se sia o no opportuno inserirlo.

<P style="page-break-before: always">

<---------------------------------------------------------------------- x ---------------------------------------------------------------------->

#### Dipendenti totali nella tabella cinema:<br>

Le operazioni riguardanti questa ridondanza sono le seguenti.

1. Creazione della relazione "impieghi correnti"
2. Stampare tutti i dati di un cinema, compreso il numero totale di dipendenti di quel cinema

In presenza di ridondanza per l'operazione 1 dobbiamo accedere una volta ini lettura all'entità dipentente per ottenere il dipendete, una volta in scrittura alla relazione "impieghi correnti" e due volte all'entità Cinema, prima in lettura per individuare il cinema e una seconda volta in scrittura, per aumentare il numero di dipendenti totali.
Contando doppi gli accessi in scrittura e in base alla frequenza dlle operazioni stimata, avremo 95 accessi alla settimana.

In assenza di ridondanza per l'operazione 1 avremo un accesso in lettura a dipendente e un accesso in scrittura ad "impieghi correnti".
Per l'operazione 2 invece dovremmo accedere una volta a Cinema in lettura e 20 a "impieghi correnti" in lettura: in base, infatti, alla tabella dei volumi stimati ogni cinema avrà in media 20 impieghi correnti.
In totale avremmo 730 accessi a settimana.

Un campo integer occupa 4byte, quindi il dato ridondante ci costerà 100byte in termini di spazio, ma ci farà risparmiare quasi 700 accessi al database a settimana

| Ridondanza tot dipendenti in cinema |                              |           |             |
| ----------------------------------- | ---------------------------- | --------- | ----------- |
|                                     | Operazione                   | Frequenza |             |
| 1                                   | Aggiunta relazione lavora in | 10        | a settimana |
| 2                                   | Stampare tutti dati cinema   | 35        | a settimana |

| Con ridondanza |              |         |             |     | Senza ridondanza |               |         |             |
| -------------- | ------------ | ------- | ----------- | --- | ---------------- | ------------- | ------- | ----------- |
| Operazione     | Concetto     | Accessi | Tipo        |     | Operazione       | Concetto      | Accessi | Tipo        |
| Op 1           | Dipendente   | 1       | L           |     | Op 1             | Dipendente    | 1       | L           |
|                | Impieghi cor | 1       | S           |     |                  | Impieghi corr | 1       | S           |
|                | Cinema       | 1       | L           |     |                  |               |         |             |
|                | Cinema       | 1       | S           |     |                  |               |         |             |
|                |              |         |             |     |                  |               |         |             |
| Operazione     | Concetto     | Accessi | Tipo        |     | Operazione       | Concetto      | Accessi | Tipo        |
| Op 2           | Cinema       | 1       | L           |     | Op 2             | Cinema        | 1       | L           |
|                |              |         |             |     |                  | Impieghi corr | 20      | L           |
|                |              |         |             |     |                  |               |         |             |
| Totale         | 95           | Accessi | a settimana |     | Totale           | 730           | Accessi | a settimana |

<---------------------------------------------------------------------- x ---------------------------------------------------------------------->

<P style="page-break-before: always">

#### Proiezioni dei film:

<br>

Le operazioni coinvolte in questo dato derivato sono le seguenti:

1. Aggiunta di una proiezione con relativo film
2. Stampare tutti i dati di un film compreso il numero totale di proiezioni

In assenza di ridondanza per l'op. 1 si dovrà accedere una volta in scrittura a "Proiezione" e una alla relazione "Proiezione di". Per l'op.2 si accederà una volta in lettura all'entità "film" e 70 volte alla relazione "Proiezione di" in quanto avendo 500 film e 35000 poiezioni, in media ogni film ha 70 proiezioni

In presenza di ridondanza per l'op. 1, oltre a un accesso in scrittura a "Proiezione" e una alla relazione "Proiezione di", si dovrà accedere una volta a "film" in lettura per ottenere il film e un'altra volta in scrittura per incrementare il numero di proiezioni totali. Per l'op.2 è sufficiente accedere una volta in lettura a "film".

In base alla frequenza delle operazioni stimata avremo 575 accessi al giorno in presenza di ridondanza contro i 2175 accessi in assenza di ridondanza. Il costo in termini di spazio è di circa 2KByte.

| Ridondanza tot proiezioni film |                                |           |           |
| ------------------------------ | ------------------------------ | --------- | --------- |
|                                | Operazione                     | Frequenza |           |
| 1                              | Aggiunta proiezione di un film | 100       | al giorno |
| 2                              | Stampa tutti i dati di un film | 25        | al giorno |

| Operazione | Concetto      | Accessi | Tipo      |     | Operazione | Concetto      | Accessi | Tipo        |
| ---------- | ------------- | ------- | --------- | --- | ---------- | ------------- | ------- | ----------- |
| Op 1       | Proiezione    | 1       | S         |     | Op 1       | Proiezione    | 1       | S           |
|            | Proiezione di | 1       | S         |     |            | Proiezione di | 1       | S           |
|            | Film          | 1       | L         |     |            |               |         |             |
|            | Film          | 1       | S         |     |            |               |         |             |
|            |               |         |           |     |            |               |         |             |
|            |               |         |           |     |            |               |         |             |
| Operazione | Concetto      | Accessi | Tipo      |     | Operazione | Concetto      | Accessi | Tipo        |
| Op 2       | Film          | 1       | L         |     | Op 2       | Film          | 1       | L           |
|            |               |         |           |     |            | Proiezione di | 70      | L           |
|            |               |         |           |     |            |               |         |             |
| Totale     | 575           | Accessi | al giorno |     | Totale     | 2175          | Accessi | a settimana |

<---------------------------------------------------------------------- x ---------------------------------------------------------------------->

<P style="page-break-before: always">

#### Partecipazione degli attori:

Il dato derivato sul numero di film a cui ha partecipato un attore è molto simile alla ridondanza sul numero totale di dipendenti per cinema. In questo caso, però, la differente frequenza delle operazioni rende inefficacie la presenza del dato derivato

| Ridondanza tot partecipazione attore |                              |           |             |
| ------------------------------------ | ---------------------------- | --------- | ----------- |
|                                      | Operazione                   | Frequenza |             |
| 1                                    | Aggiunta relazione partecipa | 120       | a settimana |
| 2                                    | Stampa tutti dati attore     | 70        | a settimana |

| Operazione | Concetto | Accessi | Tipo        |     | Operazione | Concetto | Accessi | Tipo        |
| ---------- | -------- | ------- | ----------- | --- | ---------- | -------- | ------- | ----------- |
| Op 1       | Attore   | 1       | L           |     | Op 1       | Attore   | 1       | L           |
|            | Ruolo in | 1       | S           |     |            | Ruolo in | 1       | S           |
|            | Attore   | 1       | S           |     |            |          |         |             |
|            |          |         |             |     |            |          |         |             |
|            |          |         |             |     |            |          |         |             |
| Operazione | Concetto | Accessi | Tipo        |     | Operazione | Concetto | Accessi | Tipo        |
| Op 2       | Attore   | 1       | L           |     | Op 2       | Attore   | 1       | L           |
|            |          |         |             |     |            | Ruolo in | 3       | L           |
|            |          |         |             |     |            |          |         |             |
|            |          |         |             |     |            |          |         |             |
| Totale     | 670      | Accessi | a settimana |     | Totale     | 640      | Accessi | a settimana |

<---------------------------------------------------------------------- x ---------------------------------------------------------------------->

<P style="page-break-before: always">

#### Incasso totale per film:

Per questa ridondanza consideriamo 2 casi di utilizzo del database separato: uno nel quale il numero di biglietti venduti per proiezioni è inserito nel database in maniera semidefinitiva, mentre il secondo riguarda il caso in cui la proiezione viene inserita con 0 biglietti venduti, e il numero di biglietti viene aumentato man mano che i biglietti vengono effettivamente venduti

Il caso implementato nella nostra base di dati è il secondo

##### Caso 1: dato biglietti venduti raramente modificato

Operazioni coinvolte:

1. Aggiunta di una proiezione con relativo film
2. Stampare tutti i dati di un film, compreso incasso totale del film

Per l'op. 1 in assenza di ridondanza è sufficiente accedere a "Proiezione" e "Proiezione di" una volta in scrittura.
Per l'op. 2 si accederà una volta in lettura a "film", 70 in lettura a "Proiezione di" e altrettante a "Proiezione".
In totale, con le frequenza stimate come in tabella, avremo 3965 accessi al giorno.

In presenza di ridondanza, per l'op. 1, si accederà a "Proiezione" e "Proiezione di" una volta in scrittura, più una volta in lettura a "film" per ottenere il relativo film e una in scrittura per aumentare l'incasso totale.
Per l'op. 2 invece basterà un accesso in lettura a "film". Per un totale di 725 accessi al giorno

La ridondanza in questo caso quindi sarà utile.

| Dato biglietti venduti raramente modificato |                                                         |           |           |
| ------------------------------------------- | ------------------------------------------------------- | --------- | --------- |
|                                             | Operazione                                              | Frequenza |           |
| Op 1                                        | Aggiunta proiezione con relativo film e aumento incasso | 100       | al giorno |
| Op 2                                        | Stampare dati film, compreso incasso                    | 25        | al giorno |

| Operazione | Concetto      | Accessi | Tipo      |     | Operazione | Concetto      | Accessi | Tipo      |
| ---------- | ------------- | ------- | --------- | --- | ---------- | ------------- | ------- | --------- |
| Op 1       | Proiezione    | 1       | S         |     | Op 1       | Proiezione    | 1       | S         |
|            | Proiezione di | 1       | S         |     |            | Proiezione di | 1       | S         |
|            | Film          | 1       | L         |     |            |               |         |           |
|            | Film          | 1       | S         |     |            |               |         |           |
|            |               |         |           |     |            |               |         |           |
| Operazione | Concetto      | Accessi | Tipo      |     | Operazione | Concetto      | Accessi | Tipo      |
| Op 2       | Film          | 1       | L         |     | Op 2       | Film          | 1       | L         |
|            |               |         |           |     |            | Proiezione di | 70      | L         |
|            |               |         |           |     |            | Proiezione    | 70      | L         |
|            |               |         |           |     |            |               |         |           |
| Totale     | 725           | Accessi | al giorno |     | Totale     | 3925          | Accessi | al giorno |

##### Caso 2: proiezione viene inserita con 0 biglietti venduti, e numero di biglietti viene aumentato man mano che i biglietti vengono effettivamente venduti

Operazioni coinvolte:

1. Aggiunta proiezione con relativo film
2. Update biglietti venduti con aumento incasso film
3. Stampare dati film, compreso incasso

L'op. 1 sarà uguale sia in presenza di ridondanza che in assenza. Si accederà una volta in scrittura a "Proiezione" e "Proiezione di".

Per l'op. 2 in assenza di ridondanza si accede semplicementa a "Proiezione" e si aumenta il numero di biglietti venduti. In presenza di ridondanza bisognerà accedere una volta a "Proiezione di" e "Film" in lettura per ottenere il film proiettato, più un accesso in scrittura per a "film" per aumentare l'incasso totale.

L'op. 3 in presenza di ridondanza richiederà un solo accesso a "film" in lettura. In assenza di ridondanza si accederà una volta in lettura a "film", 70 in lettura a "Proiezione di" e altrettante a "Proiezione".

La ridondanza in questo caso è deleteria in quanto si avranno 24425 accessi, contro i 11925 accessi in assenza di ridondanza.

| Ridondanza su incasso totale film |                                                   |           |           |
| --------------------------------- | ------------------------------------------------- | --------- | --------- |
| Update a ogni vendita biglietto   |                                                   |           |           |
|                                   | Operazione                                        | Frequenza |           |
| Op 1                              | Aggiunta proiezione con relativo film             | 100       | al giorno |
| Op 2                              | Update biglietti venduti con aumento incasso film | 4,000     | al giorno |
| Op 3                              | Stampare dati film, compreso incasso              | 25        | al giorno |

| Operazione | Concetto      | Accessi | Tipo      |     | Operazione | Concetto      | Accessi | Tipo      |
| ---------- | ------------- | ------- | --------- | --- | ---------- | ------------- | ------- | --------- |
| Op 1       | Proiezione    | 1       | S         |     | Op 1       | Proiezione    | 1       | S         |
|            | Proiezione di | 1       | S         |     |            | Proiezione di | 1       | S         |
|            |               |         |           |     |            |               |         |           |
| Operazione | Concetto      | Accessi | Tipo      |     | Operazione | Concetto      | Accessi | Tipo      |
| Op 2       | Proiezione    | 1       | S         |     | Op 2       | Proiezione    | 1       | S         |
|            | Proiezione di | 1       | L         |     |            |               |         |           |
|            | Film          | 1       | L         |     |            |               |         |           |
|            | Film          | 1       | S         |     |            |               |         |           |
|            |               |         |           |     |            |               |         |           |
| Concetto   | Accessi       | Tipo    | Colonna1  |     | Operazione | Concetto      | Accessi | Tipo      |
| Op 3       | Film          | 1       | L         |     | Op 3       | Film          | 1       | L         |
|            |               |         |           |     |            | Proiezione di | 70      | L         |
|            |               |         |           |     |            | Proiezione    | 70      | L         |
|            |               |         |           |     |            |               |         |           |
| Totale     | 24425         | Accessi | al giorno |     | Totale     | 11925         | Accessi | al giorno |

<---------------------------------------------------------------------- x ---------------------------------------------------------------------->

<P style="page-break-before: always">

#### Capienza della sala:

Dato ridondante "capienza sala" nell'entità "Proiezione".
Operazioni coinvolte:

1. Aggiunta proiezione con relativa sala
2. Update biglietti venduti con controllo che i biglietti venduti non superi la capienza della sala

In presenza di ridondanza, l'op. 1 richiede un accesso a "Sala" per ottenere la capienza della sala da ottenere come dato ridondante, più uno in scrittura a "Proiezione" e "Avvenuta in".
Quando verrà effettuato l'update (op. 2) sarà sufficiente leggere l'entità "Proiezione" per ottenere la capienza della sala e, nel caso in cui i biglietti venduti sono minori alla capienza sarà possibile aggiornare "Proiezione" con un ulteriore accesso in scrittura.

In assenza di ridondanza l'op. 1 richiede un accesso in scrittura a "Proiezione" e "Avvenuta in".
Per l'op. 2 per ottenere la capienza della sala e gli attuali biglietti venduti bisognerà accedere in lettura alle entità "Proiezione", "Avvenuta in" e "Sala". Nel caso in cui i biglietti venduti sono minori alla capienza sarà possibile aggiornare "Proiezione" con un ulteriore accesso in scrittura.

È stato stimato che una sala ha in media 200 posti disponibili e che vengono venduti una media del 40% dei biglietti, qundi 80 posti occupati di media per proiezione. Inoltre, è stata fatta l'ipotesi che a ogni transazione vengono venduti 2 biglietti quindi ogni proiezione verrà modificata 40 volte. Avendo 100 proiezioni al giorno ci saranno 4000 modifiche a "Proiezione" al giorno.

In base a questi ipotetici valori, con il dato ridondante conviene con 12500 accessi contro i 20400 in assenza di dato ridondante. Il costo in termini di spazio sara di 4Byte\*35000, circa 140 KByte

| Ridondanza su controllo capienza sala |                                       |           |           |
| ------------------------------------- | ------------------------------------- | --------- | --------- |
| Update a ogni vendita biglietto       |                                       |           |           |
|                                       | Operazione                            | Frequenza |           |
| Op 1                                  | Aggiunta proiezione con relativa sala | 100       | al giorno |
| Op 2                                  | Update biglietti venduti              | 4,000     | al giorno |

In media 80 biglietti venduti per proiezione, venduti 2 per volta.
Quindi totale 40 update per proiezione.

| Operazione | Concetto    | Accessi | Tipo      |     | Operazione | Concetto    | Accessi | Tipo      |
| ---------- | ----------- | ------- | --------- | --- | ---------- | ----------- | ------- | --------- |
| Op 1       | Sala        | 1       | L         |     | Op 1       | Proiezione  | 1       | S         |
|            | Proiezione  | 1       | S         |     |            | Avvenuta in | 1       | S         |
|            | Avvenuta in | 1       | S         |     |            |             |         |           |
|            |             |         |           |     |            |             |         |           |
| Operazione | Concetto    | Accessi | Tipo      |     | Operazione | Concetto    | Accessi | Tipo      |
| Op 2       | Proiezione  | 1       | L         |     | Op 2       | Proiezione  | 1       | L         |
|            | Proiezione  | 1       | S         |     |            | Proiezione  | 1       | S         |
|            |             |         |           |     |            | Avvenuta in | 1       | L         |
|            |             |         |           |     |            | Sala        | 1       | L         |
|            |             |         |           |     |            |             |         |           |
| Totale     | 12500       | Accessi | al giorno |     | Totale     | 20400       | Accessi | al giorno |

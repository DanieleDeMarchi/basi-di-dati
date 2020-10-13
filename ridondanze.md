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

| Ridondanza tot dipendenti in cinema |                              |           |             |
| ----------------------------------- | ---------------------------- | --------- | ----------- |
|                                     | Operazione                   | Frequenza |             |
| 1                                   | Aggiunta relazione lavora in | 10        | a settimana |
| 2                                   | Stampare tutti dati cinema   | 35        | a settimana |

| Con ridondanza |           |         |             |     | Senza ridondanza |           |         |             |
| -------------- | --------- | ------- | ----------- | --- | ---------------- | --------- | ------- | ----------- |
| Operazione     | Concetto  | Accessi | Tipo        |     | Operazione       | Concetto  | Accessi | Tipo        |
| Op 1           | Lavora in | 1       | S           |     | Op 1             | Lavora in | 1       | S           |
|                | Cinema    | 1       | S           |     |                  |           |         |             |
|                |           |         |             |     |                  |           |         |             |
| Operazione     | Concetto  | Accessi | Tipo        |     | Operazione       | Concetto  | Accessi | Tipo        |
| Op 2           | Cinema    | 1       | L           |     | Op 2             | Cinema    | 1       | L           |
|                |           |         |             |     |                  | Lavora in | 20      | L           |
|                |           |         |             |     |                  |           |         |             |
| Totale         | 75        | Accessi | a settimana |     | Totale           | 720       | Accessi | a settimana |

| Ridondanza tot proiezioni film |                                |           |           |
| ------------------------------ | ------------------------------ | --------- | --------- |
|                                | Operazione                     | Frequenza |           |
| 1                              | Aggiunta proiezione di un film | 100       | al giorno |
| 2                              | Stampa tutti i dati di un film | 25        | al giorno |

| Con ridondanza |            |         |           |     | Senza ridondanza |            |         |             |
| -------------- | ---------- | ------- | --------- | --- | ---------------- | ---------- | ------- | ----------- |
| Operazione     | Concetto   | Accessi | Tipo      |     | Operazione       | Concetto   | Accessi | Tipo        |
| Op 1           | Proiezione | 1       | S         |     | Op 1             | Proiezione | 1       | S           |
|                | Proiettato | 1       | S         |     |                  | Proiettato | 1       | S           |
|                | Film       | 1       | S         |     |                  |            |         |             |
|                |            |         |           |     |                  |            |         |             |
| Operazione     | Concetto   | Accessi | Tipo      |     | Operazione       | Concetto   | Accessi | Tipo        |
| Op 2           | Film       | 1       | L         |     | Op 2             | Film       | 1       | L           |
|                |            |         |           |     |                  | Proiettato | 70      | L           |
|                |            |         |           |     |                  |            |         |             |
| Totale         | 625        | Accessi | al giorno |     | Totale           | 2,175      | Accessi | a settimana |

| Ridondanza tot partecipazione attore |                              |           |             |
| ------------------------------------ | ---------------------------- | --------- | ----------- |
|                                      | Operazione                   | Frequenza |             |
| 1                                    | Aggiunta relazione partecipa | 120       | a settimana |
| 2                                    | Stampa tutti dati attore     | 70        | a settimana |

| Con ridondanza |           |         |             |     | Senza ridondanza |           |         |             |
| -------------- | --------- | ------- | ----------- | --- | ---------------- | --------- | ------- | ----------- |
| Operazione     | Concetto  | Accessi | Tipo        |     | Operazione       | Concetto  | Accessi | Tipo        |
| Op 1           | Partecipa | 1       | S           |     | Op 1             | Partecipa | 1       | S           |
|                | Film      | 1       | S           |     |                  |           |         |             |
|                |           |         |             |     |                  |           |         |             |
| Operazione     | Concetto  | Accessi | Tipo        |     | Operazione       | Concetto  | Accessi | Tipo        |
| Op 2           | Attore    | 1       | L           |     | Op 2             | Attore    | 1       | L           |
|                |           |         |             |     |                  | Partecipa | 3       | L           |
|                |           |         |             |     |                  |           |         |             |
|                |           |         |             |     |                  |           |         |             |
| Totale         | 550       | Accessi | a settimana |     | Totale           | 520       | Accessi | a settimana |

| Ridondanza su controllo capienza sala |                                       |           |           |
| ------------------------------------- | ------------------------------------- | --------- | --------- |
| Update a ogni vendita biglietto       |                                       |           |           |
|                                       | Operazione                            | Frequenza |           |
| Op 1                                  | Aggiunta proiezione con relativa sala | 100       | al giorno |
| Op 2                                  | Update biglietti venduti              | 4,000     | al giorno |

In media 80 biglietti venduti per proiezione, venduti 2 per volta.
Quindi totale 40 update per proiezione.

| Con ridondanza |               |         |           |     | Senza ridondanza |               |         |           |
| -------------- | ------------- | ------- | --------- | --- | ---------------- | ------------- | ------- | --------- |
| Operazione     | Concetto      | Accessi | Tipo      |     | Operazione       | Concetto      | Accessi | Tipo      |
| Op 1           | Sala          | 1       | L         |     | Op 1             | Proiezione    | 1       | S         |
|                | Proiezione    | 1       | S         |     |                  | Proiettato in | 1       | S         |
|                | Proiettato in | 1       | S         |     |                  |               |         |           |
|                |               |         |           |     |                  |               |         |           |
| Operazione     | Concetto      | Accessi | Tipo      |     | Operazione       | Concetto      | Accessi | Tipo      |
| Op 2           | Proiezione    | 1       | S         |     | Op 2             | Proiezione    | 1       | S         |
|                |               |         |           |     |                  | Proiettato in | 1       | L         |
|                |               |         |           |     |                  | Sala          | 1       | L         |
|                |               |         |           |     |                  |               |         |           |
| Totale         | 8,500         | Accessi | al giorno |     | Totale           | 16,400        | Accessi | al giorno |

Se invece il dato dei biglietti venduti non viene mai aggiornato o, raramente aggiornato, la ridondanza non ha senso

| Ridondanza su incasso totale film |                                                   |           |           |
| --------------------------------- | ------------------------------------------------- | --------- | --------- |
| Update a ogni vendita biglietto   |                                                   |           |           |
|                                   | Operazione                                        | Frequenza |           |
| Op 1                              | Aggiunta proiezione con relativo film             | 100       | al giorno |
| Op 2                              | Update biglietti venduti con aumento incasso film | 4,000     | al giorno |
| Op 3                              | Stampare dati film, compreso incasso              | 25        | al giorno |

| Con ridondanza |               |         |           |     | Senza ridondanza |               |         |           |
| -------------- | ------------- | ------- | --------- | --- | ---------------- | ------------- | ------- | --------- |
| Operazione     | Concetto      | Accessi | Tipo      |     | Operazione       | Concetto      | Accessi | Tipo      |
| Op 1           | Proiezione    | 1       | S         |     | Op 1             | Proiezione    | 1       | S         |
|                | Proiezione di | 1       | S         |     |                  | Proiezione di | 1       | S         |
|                |               |         |           |     |                  |               |         |           |
|                |               |         |           |     |                  |               |         |           |
| Operazione     | Concetto      | Accessi | Tipo      |     | Operazione       | Concetto      | Accessi | Tipo      |
| Op 2           | Proiezione    | 1       | S         |     | Op 2             | Proiezione    | 1       | S         |
|                | Proiezione di | 1       | L         |     |                  |               |         |           |
|                | Film          | 1       | S         |     |                  |               |         |           |
|                |               |         |           |     |                  |               |         |           |
| Concetto       | Accessi       | Tipo    | Colonna1  |     | Operazione       | Concetto      | Accessi | Tipo      |
| Op 3           | Film          | 1       | L         |     | Op 3             | Film          | 1       | L         |
|                |               |         |           |     |                  | Proiezione di | 70      | L         |
|                |               |         |           |     |                  | Proiezione    | 70      | L         |
|                |               |         |           |     |                  |               |         |           |
| Totale         | 20,425        | Accessi | al giorno |     | Totale           | 11,925        | Accessi | al giorno |

| Dato biglietti venduti raramente modificato |                                                         |           |           |
| ------------------------------------------- | ------------------------------------------------------- | --------- | --------- |
|                                             | Operazione                                              | Frequenza |           |
| Op 1                                        | Aggiunta proiezione con relativo film e aumento incasso | 100       | al giorno |
| Op 2                                        | Stampare dati film, compreso incasso                    | 25        | al giorno |

| Con ridondanza |               |         |           |     | Senza ridondanza |               |         |           |
| -------------- | ------------- | ------- | --------- | --- | ---------------- | ------------- | ------- | --------- |
| Operazione     | Concetto      | Accessi | Tipo      |     | Operazione       | Concetto      | Accessi | Tipo      |
| Op 1           | Proiezione    | 1       | S         |     | Op 1             | Proiezione    | 1       | S         |
|                | Proiezione di | 1       | S         |     |                  | Proiezione di | 1       | S         |
|                | Film          | 1       | S         |     |                  |               |         |           |
|                |               |         |           |     |                  |               |         |           |
| Operazione     | Concetto      | Accessi | Tipo      |     | Operazione       | Concetto      | Accessi | Tipo      |
| Op 2           | Film          | 1       | L         |     | Op 2             | Film          | 1       | L         |
|                |               |         |           |     |                  | Proiezione di | 70      | L         |
|                |               |         |           |     |                  | Proiezione    | 70      | L         |
|                |               |         |           |     |                  |               |         |           |
| Totale         | 625           | Accessi | al giorno |     | Totale           | 3,925         | Accessi | al giorno |

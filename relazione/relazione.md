#### De Marchi Daniele (Mat. 130654), Zanin Simone (Mat. 140833)
# Progetto di laboratorio di Basi di Dati
<br><br>
## Introduzione
---

### Consegna

In questo progetto è stata studiata una soluzione per il seguente esercizio:  

> Si vuole progettare una base di dati di supporto alla gestione di una rete di cinema multisala di proprietà di un’unica società.  
La società possiede più cinema, in diverse città italiane. Ogni cinema è identificato univocamente da un codice ed è caratterizzato da un nome, da un manager, da un recapito telefonico e dalla città in cui si trova. Ogni sala di un cinema è contraddistinta da un numero (sala numero 1, sala numero 2, ...) e possiede una superficie, espressa in metri quadrati, e una capienza (150 posti, 200 posti, ...).  
Oltre ai manager dei vari cinema, la società dispone di altro personale (addetti alla proiezione, addetti alla biglietteria, addetti alle pulizie, ...), che può lavorare presso più cinema (non necessariamente tutti).  
Ogni film è identificato da un codice. Di ogni film vengono registrati il titolo, il nome del regista, l’anno di produzione e la nazione in cui è stato prodotto (si assuma che non vi siano coproduzioni internazionali) e la lunghezza in minuti.  
Si vuole, inoltre, tener traccia delle proiezioni dei vari film nei vari cinema. Di ogni proiezione vogliamo memorizzare la sala, il giorno, l’orario e il prezzo (si assuma che proiezioni diverse dello stesso film o di film diversi possano avere prezzi diversi).  
Si vuole anche tener traccia di alcune informazioni relative alle principali star cinematografiche. Di ognuna vengono memorizzati il nome (che le identifica univocamente), l’anno di nascita, il sesso e la nazionalità.
Infine, si registrano informazioni sul cast di ogni film, che riportano le star che vi partecipano e il loro ruolo (attrice protagonista, attore non protagonista, comparsa, ...).

### Software Utilizzati

Nella realizzazione del progetto sono stati utilizzati diversi software.  
Per la base di dati stessa è stato costruito un server self-hosted di *PostgreSQL*, con la quale abbiamo interagito attraverso *PgAdmin4*.  
Il modello ER è stato sviluppato attraverso l'applicazione *ChronoGeoGraph*, modificata da noi per risolvere alcune problematiche in essa presenti.  
Il riempimento delle tabelle è stato effettuato tramite un programma *Java* creato appositamente.  
L'analisi statistica è stata effettuata con il linguaggio *R*.  
La produzione del documento corrente è stata fatta tramite il linguaggio *MD*, renderizzato attraverso l'applicativo *Okular*.

<P style="page-break-before: always">

## Progettazione Concettuale
---

### Analisi dei requisiti

Il database sembra destinato al mantenimento di dati a scopo storico e statistico, più che ad una vera gestione interna delle prenotazioni e dei film: infatti non vengono menzionati biglietti e posti assegnati, ma solo dati generici sulla singola proiezione.  
Tra le altre scelte fatte per arricchire la consegna, abbiamo pensato, in questo ambito, di inserire un dato sul numero totale di posti occupati, in maniera da avere un possibile confronto con la capienza della sala e poter trarre delle conclusioni sulla popolarità del film.  
Per quanto riguarda la rappresentazione del personale, abbiamo discusso sulla metodo migliore per rendere il fatto che entrambi sono esseri umani associati agli stessi tipi di dato, e a livello di relazioni, abbiamo optato per una generalizzazione delle entità Dipendente e Manager in una super-entità definita Lavoratore. Viene inoltre inserita una relazione che tenga traccia delle mansioni passate dei dipendenti.  
In totale sono state inserite 8 entità (Lavoratore, Dipendente, Manager, Cinema, Sala, Proiezione, Film e Attore) e 8 relazioni tra essi.  
Altri tipi di aggiunte alla consegna verranno discussi più tardi, nei loro specifici ambiti.  

### Modello E/R

La compilazione del modello ER è stata organica, per la maggior parte seguendo passo a passo le indicazioni dell’esercizio, e arricchendolo man mano che nuove idee su possibili utilizzi emergevano dal confronto interno al gruppo di lavoro.  

Dei punti salienti notevoli sono, per esempio:

+ La generalizzazione di manager e dipendente ad una super-entità in comune;  
+ La progettazione dell’entità Sala come un’entità debole basata sull’entità Cinema;  
+ L’inserimento di una relazione riflessiva “Sequel di” dell’entità Film;  
+ L’inserimento di molteplici attributi derivati, discussi in seguito;  

![ER.jpg](ER.jpg)

<P style="page-break-before: always">

## Progettazione Logica
---
 
### Analisi delle ridondanze e campi derivati

<-- Basterebbe incollare e commentare le tabelle già prodotte nella repo github --->
TODO 

### Eliminazione delle generalizzazioni

Nel modello ER è presente una singola generalizzazione.  
Durante la progettazione sono state considerate diverse soluzioni, tra cui

- il mantenimento delle due entità in modo separato per consentire una facile manutenzione dei vincoli di integrità per i manager;  
- l'inserimento nella tabella cinema di un campo con chiave esterna non nulla verso un dipendente, che sarebbe dunque il manager per tale cinema;

Abbiamo tuttavia optato per un approccio più vicino a quello che abbiamo considerato la realtà, ovvero che il manager altro non è che un dipendente con una mansione particolare, per la quale esistono dei vincoli extra da garantire.  
Utilizzare questo genere di astrazione del ruolo ci consente, come effetto collaterale, di tenere traccia di manager passati nello storico impieghi, cosa che non era prevista nel modello ER iniziale, mentre la perdita di efficienza dovuta alla ricerca in una tabella più popolosa rimane comunque giustificata dal fatto che una ricerca sul singolo manager è relativamente rara nell'uso previsto.

### Vincoli di integrità

Sono stati individuati molti casi critici per l'integrità del database, che sono stati risolti attraverso l'inserimento di opportuni trigger e constraint all'interno della base di dati:

- In ogni dato istante può essere presente uno ed un solo manager per ogni cinema.  
Questo è stato risolto facendo in modo che il manager non possa essere eliminato, ma solo sostituito, processo nel quale viene spostato quello vecchio nello storico impieghi.

- Non possono coesistere due proiezioni in contemporanea nella stessa stanza. Viene inoltre garantito un periodo di grazia minimo di 30 minuti per consentire al personale la pulizia dei locali.

- La capienza di una sala non può essere superata dalle persone che la utilizzano.

- Nessun ID assegnato automaticamente dovrebbe essere modificato manualmente.

- Lo storico impieghi non può essere manomesso, in quanto viene popolato automaticamente quando un impiego viene rimosso.

- Nessun campo di ridondanza calcolato automaticamente può essere modificato manualmente.

- La valutazione di un film è stata codificata come un tipo custom, detto rating, che è un intero compreso fra 0 e 10 inclusi, che può essere agilmente convertito per esempio in una valutazione a 5 stelle con precisione fino a mezza stella.

<P style="page-break-before: always">

## Progettazione fisica

---

La progettazione fisica dell'esercizio può essere trovata al seguente indirizzo:  
> https://github.com/DanieleDeMarchi/basi-di-dati  

La creazione del database è stata effettuata eseguendo, nell'ordine indicato dal nome, gli script SQL presenti nella radice del progetto. L'inserimento di dati pseudo casuali è stato invece effettuato attraverso un programma Java, sempre incluso nel progetto all'interno della directory `riempimento_auto`, che utilizza elenchi di dati estrapolati da varie fonti recuperate online e successivamente elaborate manualmente.

### Scelte implementative

TODO

### Indici

TODO

<P style="page-break-before: always">

## Analisi dei dati
---

TODO

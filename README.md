# Calcolatori Elettronici 2024/2025

Repository del progetto universitario per il corso di Calcolatori Elettronici, anno 2025, UniUD.

## Contenuto

Questa repo raccoglie i sorgenti HDL, gli script di simulazione e sintesi, ed il report generato per quattro dispositivi:

- `onescounter`: conteggio bit a 1 in sequenza di vettori.
- `search_chr`: ricerca carattere con memoria a latenza parametrica.
- `multiplier_clz`: moltiplicatore + count leading zeros (CLZ).
- `mcd`: calcolo massimo comune divisore (MCD).

Ogni progetto è strutturato in cartelle dedicate, con i relativi testbench e stimoli.
Gli script Bash, Tcl e Python costituiscono un piccolo framework che automatizza analisi, simulazioni RTL/gate-level e sintesi su nodo 40nm.

## Come usare

```bash
# Esempio: simulazione RTL con GHDL
scripts/runSim_ghdl projects/01_onescounter

# Simulazione gate-level con Xcelium (richiede environment già configurato)
scripts/gl_xcelium 32 1000 -sdf
```

Si veda il documento progettuale per tutti i dettagli.

## Come generare il documento

Nel percorso `doc/bin` c'é un dockerfile per costruire il container con tutte le dipendenze.
Lo script `generateDoc` fa il resto.

Si puó anche utilizzare `make` per generare il documento, se l'immagine del container `adocbuilder` é disponibile.

# windows-auto-input

Utility anti-idle per Windows. Ogni N secondi invia un tasto alla finestra in
focus, oppure esegue un click sinistro nella posizione corrente del mouse.

Il mouse **non viene mai spostato**: il click avviene dove si trova già il
puntatore in quel momento.

## Requisiti

- Windows con Windows PowerShell 5.1 (già presente di serie)

## Uso

```powershell
# Premi "1" ogni 30 secondi, all'infinito (default)
.\auto-input.ps1

# Click sinistro ogni 30 secondi nella posizione corrente del mouse
.\auto-input.ps1 -Mode Click

# Premi F15 ogni minuto (anti-idle non invasivo: non fa nulla in quasi nessuna app)
.\auto-input.ps1 -Key "{F15}" -IntervalSeconds 60

# 10 click, poi esce
.\auto-input.ps1 -Mode Click -Count 10
```

Dopo l'avvio hai **5 secondi** per mettere il focus sulla finestra giusta.
Interrompi con `Ctrl+C`.

C'è anche `auto.bat` come scorciatoia: `auto.bat {F15}` equivale a
`.\auto-input.ps1 -Key "{F15}"`.

## Parametri

| Parametro | Default | Descrizione |
| --- | --- | --- |
| `-Mode` | `Key` | `Key` invia un tasto, `Click` fa un click sinistro. |
| `-Key` | `1` | Tasto da inviare in modalità `Key`, sintassi SendKeys. |
| `-IntervalSeconds` | `30` | Secondi tra un'azione e l'altra (1–3600). |
| `-Count` | `0` | Numero di azioni; `0` = infinito. |

La sintassi SendKeys accetta ad esempio `1` (tasto 1), `{F15}` (F15),
`+{TAB}` (Shift+Tab). Documentazione completa:
[SendKeys.Send](https://learn.microsoft.com/dotnet/api/system.windows.forms.sendkeys#remarks).

## Note

- Il tasto viene inviato a **qualunque** finestra abbia il focus in quel
  momento: se cambi finestra durante l'esecuzione, il tasto finisce lì. Per
  questo `{F15}` è la scelta più sicura.
- Ad ogni azione lo script logga orario, contatore e titolo della finestra
  bersaglio, così puoi verificare dove sta finendo l'input.
- Se PowerShell blocca l'esecuzione degli script:
  `powershell -ExecutionPolicy Bypass -File .\auto-input.ps1`

<#
.SYNOPSIS
    Invia un click del mouse o la pressione di un tasto a intervalli regolari,
    nella finestra attualmente in focus.

.DESCRIPTION
    Utility anti-idle. Ogni N secondi esegue una delle due azioni:
      - Key   : invia un tasto alla finestra in focus (default: "1")
      - Click : click del tasto sinistro nella posizione corrente del mouse

    Il mouse NON viene mai spostato: il click avviene dove si trova gia' il
    puntatore in quel momento. Interrompi con Ctrl+C.

.PARAMETER Mode
    "Key" (default) o "Click".

.PARAMETER Key
    Tasto da inviare in modalita' Key. Sintassi SendKeys:
      "1"        -> tasto 1
      "{F15}"    -> F15 (tasto innocuo, non fa nulla in quasi nessuna app)
      "+{TAB}"   -> Shift+Tab
    Default: "1"

.PARAMETER IntervalSeconds
    Secondi tra un'azione e l'altra. Default: 30.

.PARAMETER Count
    Numero di azioni da eseguire. 0 = infinito (default).

.EXAMPLE
    .\auto-input.ps1
    Premi "1" ogni 30 secondi, all'infinito.

.EXAMPLE
    .\auto-input.ps1 -Mode Click
    Click sinistro ogni 30 secondi nella posizione corrente del mouse.

.EXAMPLE
    .\auto-input.ps1 -Key "{F15}" -IntervalSeconds 60
    Premi F15 ogni minuto (anti-idle non invasivo).

.EXAMPLE
    .\auto-input.ps1 -Mode Click -Count 10
    10 click, poi esce.
#>

[CmdletBinding()]
param(
    [ValidateSet('Key', 'Click')]
    [string]$Mode = 'Key',

    [string]$Key = '1',

    [ValidateRange(1, 3600)]
    [int]$IntervalSeconds = 30,

    [ValidateRange(0, [int]::MaxValue)]
    [int]$Count = 0
)

Add-Type -AssemblyName System.Windows.Forms

Add-Type @'
using System;
using System.Runtime.InteropServices;

public static class YmInput {
    [DllImport("user32.dll")]
    private static extern void mouse_event(uint dwFlags, uint dx, uint dy, uint dwData, IntPtr dwExtraInfo);

    [DllImport("user32.dll")]
    private static extern IntPtr GetForegroundWindow();

    [DllImport("user32.dll")]
    private static extern int GetWindowText(IntPtr hWnd, System.Text.StringBuilder text, int count);

    private const uint LEFTDOWN = 0x0002;
    private const uint LEFTUP   = 0x0004;

    // Click nella posizione corrente del cursore: nessun movimento del mouse.
    public static void LeftClick() {
        mouse_event(LEFTDOWN, 0, 0, 0, IntPtr.Zero);
        System.Threading.Thread.Sleep(40);
        mouse_event(LEFTUP, 0, 0, 0, IntPtr.Zero);
    }

    public static string ForegroundWindowTitle() {
        IntPtr h = GetForegroundWindow();
        if (h == IntPtr.Zero) return "(nessuna)";
        var sb = new System.Text.StringBuilder(512);
        GetWindowText(h, sb, sb.Capacity);
        string s = sb.ToString();
        return string.IsNullOrWhiteSpace(s) ? "(senza titolo)" : s;
    }
}
'@

$action = if ($Mode -eq 'Click') { 'click sinistro nella posizione del mouse' } else { "tasto '$Key'" }
$limit  = if ($Count -eq 0) { 'infinito' } else { "$Count ripetizioni" }

Write-Host ''
Write-Host "  Azione   : $action"      -ForegroundColor Cyan
Write-Host "  Ogni     : $IntervalSeconds secondi"
Write-Host "  Durata   : $limit"
Write-Host ''
Write-Host '  Hai 5 secondi per mettere il focus sulla finestra giusta.' -ForegroundColor Yellow
Write-Host '  Ctrl+C per fermare.' -ForegroundColor Yellow
Write-Host ''

Start-Sleep -Seconds 5

$i = 0
try {
    while ($Count -eq 0 -or $i -lt $Count) {
        $i++
        $title = [YmInput]::ForegroundWindowTitle()
        $pos   = [System.Windows.Forms.Cursor]::Position
        $stamp = Get-Date -Format 'HH:mm:ss'

        if ($Mode -eq 'Click') {
            [YmInput]::LeftClick()
            Write-Host "[$stamp] #$i click @ $($pos.X),$($pos.Y) -> $title"
        }
        else {
            [System.Windows.Forms.SendKeys]::SendWait($Key)
            Write-Host "[$stamp] #$i tasto '$Key' -> $title"
        }

        if ($Count -eq 0 -or $i -lt $Count) {
            Start-Sleep -Seconds $IntervalSeconds
        }
    }
}
finally {
    Write-Host ''
    Write-Host "  Fermato dopo $i azioni." -ForegroundColor Cyan
}

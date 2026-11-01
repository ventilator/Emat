# Erzeugt source/form/emversion.inc aus der Versionsnummer.
# Aufruf: powershell -File tools/gen-version.ps1 -Version "0.90-dev-freepascal-port"
param(
    [Parameter(Mandatory = $true)][string]$Version
)

$out = Join-Path (Split-Path -Parent $PSScriptRoot) 'source\form\emversion.inc'
$lines = @(
    '{ Automatisch erzeugt von build-release.bat aus dem Git-Tag - nicht von Hand editieren. }',
    "EMAT_VERSION = '$Version';"
)
$lines | Set-Content -Path $out -Encoding ASCII
Write-Host "   geschrieben: $out -> $Version"

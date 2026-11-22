@echo off
rem ---------------------------------------------------------------------------
rem  build-release.bat - Release-Build von Emat (win64) + Zip in %~dp0release
rem
rem  Wird lokal und in der GitHub-Action identisch benutzt. Voraussetzungen:
rem    - Lazarus/FPC mit x86_64-win64-Compiler (ppcx64.exe)
rem    - Git im PATH (fuer die Versionsnummer aus dem Tag)
rem  Ueberschreibbar per Umgebungsvariable: LAZBUILD, PPCX64, PCP, NOPAUSE
rem ---------------------------------------------------------------------------
setlocal enabledelayedexpansion
cd /d "%~dp0"

echo === 1/5 Werkzeuge suchen
if not defined LAZBUILD (
  set "LAZBUILD=lazbuild"
  where lazbuild >nul 2>&1 || set "LAZBUILD=C:\lazarus\lazbuild.exe"
)

rem ppcx64.exe: PATH, dann neben lazbuild, dann die ueblichen Installationen
if not defined PPCX64 (
  for /f "delims=" %%i in ('where ppcx64 2^>nul') do if not defined PPCX64 set "PPCX64=%%i"
)
if not defined PPCX64 call :find_ppc "%LAZBUILD%"
if not defined PPCX64 call :find_ppc "C:\lazarus"
if not defined PPCX64 call :find_ppc "C:\FPC"
if not defined PPCX64 call :find_ppc "C:\tools\lazarus"
if not defined PPCX64 call :find_ppc "%LOCALAPPDATA%\lazarus"
if not defined PPCX64 (
  echo [FEHLER] ppcx64.exe nicht gefunden. Bitte PPCX64=... setzen.
  goto :fail
)
echo    lazbuild: %LAZBUILD%
echo    ppcx64:   %PPCX64%
if defined PCP echo    pcp:      %PCP%

echo === 2/5 Versionsnummer aus dem Git-Tag
set "VER=0.0.0-dev"
for /f "delims=" %%i in ('git describe --tags --always --dirty 2^>nul') do set "VRAW=%%i"
if not defined VRAW set "VRAW=0.0.0-dev"
rem nur ein fuehrendes v entfernen (v0.90-... -> 0.90-...); bloßes
rem !VRAW:v=! wuerde jedes 'v' im Text loeschen
set "VER=%VRAW%"
if "!VER:~0,1!"=="v" set "VER=!VER:~1!"
echo    Version: %VER%

powershell -NoProfile -ExecutionPolicy Bypass -File "tools\gen-version.ps1" -Version "%VER%"
if errorlevel 1 goto :fail

echo === 3/5 TB2_TBX-Paket bauen (x86_64-win64)
set "PCPOPT="
if defined PCP set "PCPOPT=--pcp=%PCP%"
set "LAZOPT=--compiler=%PPCX64% --ws=win32 %PCPOPT%"
"%LAZBUILD%" %LAZOPT% --cpu=x86_64 --os=win64 third_party\TB2_TBX\tbx_d7.lpk
if errorlevel 1 goto :fail
rem Paket auch in der Lazarus-Konfiguration registrieren: auf einem frischen
rem Rechner (und in der CI) ist die pcp leer, dann loest Emat.lpi die
rem Anforderung "tbx_d7" sonst nicht auf. Fehler hier sind unkritisch.
"%LAZBUILD%" %LAZOPT% --add-package third_party\TB2_TBX\tbx_d7.lpk

echo === 4/5 Emat im Release-Modus bauen (x86_64-win64)
"%LAZBUILD%" %LAZOPT% --cpu=x86_64 --os=win64 --build-mode=Release Emat.lpi
if errorlevel 1 goto :fail
if not exist Emat.exe (
  echo [FEHLER] Emat.exe wurde nicht erzeugt.
  goto :fail
)

echo === 5/5 Release-Ordner packen
if exist dist rmdir /s /q dist
if not exist release mkdir release
mkdir dist
copy /y Emat.exe dist\ >nul
for %%f in (bass.dll basswma.dll projectM-4.dll glew32.dll COPYING.txt readme.md LICENSE-NOTICE.txt) do (
  if exist "%%f" copy /y "%%f" dist\ >nul
)
if exist custom (
  mkdir dist\custom
  copy /y custom\Emat.ini dist\custom\ >nul 2>&1
  copy /y custom\Aussehen.ini dist\custom\ >nul 2>&1
)
if exist Plugins\bass (
  mkdir dist\Plugins\bass
  for %%f in (bassflac.dll bass_aac.dll bass_ac3.dll bass_fx.dll) do (
    if exist "Plugins\bass\%%f" copy /y "Plugins\bass\%%f" dist\Plugins\bass\ >nul
  )
)

set "ZIP=release\Emat-%VER%-win64.zip"
if exist "%ZIP%" del /q "%ZIP%"
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "Compress-Archive -Path 'dist\*' -DestinationPath '%ZIP%' -Force"
if errorlevel 1 goto :fail
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$h=[BitConverter]::ToString([Security.Cryptography.SHA256]::Create().ComputeHash([IO.File]::ReadAllBytes('%ZIP%'))).Replace('-',''); ($h + '  %ZIP%') | Out-File -Encoding ascii '%ZIP%.sha256'"

echo.
echo === Fertig: %ZIP%
for %%f in ("%ZIP%") do echo    Groesse: %%~zf Bytes
if not defined NOPAUSE pause
exit /b 0

:fail
echo.
echo *** Build fehlgeschlagen ***
if not defined NOPAUSE pause
exit /b 1

:find_ppc
rem Sucht ppcx64.exe unterhalb des uebergebenen Verzeichnisses bzw. neben der
rem uebergebenen Exe (lazbuild.exe). Bricht ab, sobald PPCX64 gesetzt ist.
if "%~1"=="" exit /b 0
set "_ROOT=%~dp1"
if exist "%~1\." set "_ROOT=%~1"
for /f "delims=" %%i in ('dir /b /s "%_ROOT%\ppcx64.exe" 2^>nul') do (
  if not defined PPCX64 set "PPCX64=%%i"
)
exit /b 0

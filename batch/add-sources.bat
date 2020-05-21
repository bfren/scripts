for %%a in ("%cd%") do set "CurDir=%%~na"
echo For example: %CurDir%

MKLINK /D "Sources" "F:\OneDrive - bcg design\Online Services\%CurDir%"
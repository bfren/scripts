for %%a in ("%cd%") do set "CurDir=%%~na"
MKLINK /D "Sources" "D:\OneDrive - bcg design\Online Services\%CurDir%"
@ECHO OFF
cd %~dp0
cd ..
cloc --quiet .\src
@PAUSE
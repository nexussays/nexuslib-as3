@ECHO OFF
cd %~dp0
cd ..
cloc --quiet .\projects
@PAUSE
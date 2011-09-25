@ECHO OFF
REM rmdir ".\doc" /s /q
"C:\develop\sdk\flex_sdk_4.5.1.21328\bin\asdoc.exe" -source-path "src" -doc-sources "src" -main-title "nexuslib AS3 Library" -output "doc" -lenient -warnings 
PAUSE
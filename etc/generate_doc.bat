@ECHO OFF
rmdir "..\doc" /s /q
"C:\develop\sdk\flex_sdk_4.6.0.23201\bin\asdoc.exe" -doc-sources "..\projects\reflection\src" -source-path "..\projects\reflection\src" -library-path "..\lib\blooddy_crypto_0.3.5\blooddy_crypto.swc" -main-title "nexuslib AS3 Library" -output "..\doc" -lenient -warnings 
PAUSE
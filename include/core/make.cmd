@echo off
set masm=z:\programs\development\rce\assemblers\masm
set path=%path%%masm%\bin

ml /c /coff /I%masm%\include /I%masm%\macros /I%cd% dsa.asm
link /lib /subsystem:windows /libpath:%Cd% /libpath:%masm%\lib dsa.obj

echo listo :)
pause>nul

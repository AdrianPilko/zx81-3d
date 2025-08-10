REM build all the assembly code "main" files in this directory

REM Its's assumed that the assembler pasmo.exe exists in e:\zx81\
REM change to wherever you have installed or the path to it

REM clean up before calling assembler 
del 3d.p
del *.lst
del *.sym

call c:\retro\pasmo.exe -v 3d.asm 3d.p 3d.lst

REM call will auto run emulator EightyOne if installed
REM comment in or out usin rem which one to run
rem call 3d.p 
pause


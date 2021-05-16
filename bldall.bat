@echo off
set projectName=base
if not exist rsrc.rc goto over1
\masm32\bin\rc /v rsrc.rc
\masm32\bin\cvtres /machine:ix86 rsrc.res
:over1

if exist "%projectName%.obj" del "%projectName%.obj"
if exist "%projectName%.exe" del "%projectName%.exe"

\masm32\bin\ml /c /coff "%projectName%.asm"
if errorlevel 1 goto errasm

if not exist rsrc.obj goto nores

\masm32\bin\Link /SUBSYSTEM:WINDOWS /OPT:NOREF "%projectName%.obj" rsrc.obj
if errorlevel 1 goto errlink

dir "%projectName%.*"
goto TheEnd

:nores
\masm32\bin\Link /SUBSYSTEM:WINDOWS /OPT:NOREF "%projectName%.obj"
if errorlevel 1 goto errlink
dir "%projectName%.*"
goto TheEnd

:errlink
echo _
echo Link error
goto TheEnd

:errasm
echo _
echo Assembly Error
goto TheEnd

:TheEnd

pause
@echo off

    set projectName=base
    if exist "%projectName%.obj" del "%projectName%.obj"
    if exist "%projectName%.exe" del "%projectName%.exe"

    \masm32\bin\ml /c /coff "%projectName%.asm"
    if errorlevel 1 goto errasm

    \masm32\bin\bldall %projectName%

    \masm32\bin\PoLink /SUBSYSTEM:CONSOLE "%projectName%.obj"
    if errorlevel 1 goto errlink
    dir "%projectName%.*"
    goto TheEnd

  :errlink
    echo 
    echo Link error
    goto TheEnd

  :errasm
    echo 
    echo Assembly Error
    goto TheEnd

  :TheEnd

pause

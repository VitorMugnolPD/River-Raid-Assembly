includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\user32.lib
includelib \masm32\lib\gdi32.lib
includelib \masm32\lib\msimg32.lib
include \masm32\include\masm32rt.inc
include \masm32\include\msimg32.inc


bullet struct

    x dd 0
    y dd 0
    hit BYTE 0
    enemyHit BYTE 0

bullet ends

plane struct

    x dd 0
    y dd 0
    bullets bullet 5 dup (<>)

plane ends
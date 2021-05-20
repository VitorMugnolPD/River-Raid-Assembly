includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\user32.lib
includelib \masm32\lib\gdi32.lib
includelib \masm32\lib\msimg32.lib
include \masm32\include\masm32rt.inc
include \masm32\include\msimg32.inc

.data
    szDisplayName db "River raid",0 ; Nome da janela
    CommandLine   dd 0
    hWnd          dd 0
    hInstance     dd 0
    buffer        db 128 dup(0)
    X             dd 0
    Y             dd 0
    msg1          db "Mandou uma mensagem Ok",0
    contador      dd 0
    imgY          dd 100  
    Xplayer       dd 190 ;Coordenada x do jogador
    Yplayer       dd 100 ;Coordenada y do jogador
    LOL           dd 25
    temBala       dd 0
    aparece1      dd 0
    aparece2      dd 0
    ondeAparece1  dd 0
    ondeAparece2  dd 0
    apareceGas    dd 0
    ondeApareceGas dd 0
    vivo1         dd 0
    vivo2         dd 0
    bala          POINT <>
    gas           POINT <>
    gasNaTela     dd 0
    pontuacao     dd 0
    gasolina      dd 2000
    inimigo1      POINT <>
    musica        dd 0
    inimigo2      POINT <>
    random_bytes dd 1 DUP (?)
;bullet struct

    ;x dd 0
    ;y dd 0
    ;hit BYTE 0
    ;enemyHit BYTE 0

;bullet ends

;plane struct

    ;x dd 0
    ;y dd 0
    ;bullets bullet 5 dup ({})

;plane ends
      .386                   ; minimum processor needed for 32 bit
      .model flat, stdcall   ; FLAT memory model & STDCALL calling
      option casemap :none   ; set code to case sensitive

; #########################################################################

; Libraries and includes
      include \masm32\include\masm32rt.inc

      ; ---------------------------------------------
      ; main include file with equates and structures
      ; ---------------------------------------------
      include \masm32\include\windows.inc

      

      ; -------------------------------------------------------------
      ; In MASM32, each include file created by the L2INC.EXE utility
      ; has a matching library file. If you need functions from a
      ; specific library, you use BOTH the include file and library
      ; file for that library.
      ; -------------------------------------------------------------

    include \masm32\include\user32.inc
    include \masm32\include\kernel32.inc
    include \MASM32\INCLUDE\gdi32.inc
    include \MASM32\INCLUDE\Comctl32.inc
    include \MASM32\INCLUDE\comdlg32.inc
    include \MASM32\INCLUDE\shell32.inc
    INCLUDE \Masm32\Include\msimg32.inc
    INCLUDE \Masm32\Include\oleaut32.inc
    INCLUDE \MASM32\INCLUDE\cryptdll.inc

    INCLUDELIB \Masm32\Lib\cryptdll.lib
    includelib \masm32\lib\kernel32.lib
    includelib \MASM32\LIB\gdi32.lib
    includelib \MASM32\LIB\Comctl32.lib
    includelib \MASM32\LIB\comdlg32.lib
    includelib \MASM32\LIB\shell32.lib

    INCLUDELIB \Masm32\Lib\msimg32.lib
    INCLUDELIB \Masm32\Lib\oleaut32.lib
    INCLUDELIB \Masm32\Lib\msvcrt.lib
    INCLUDELIB \Masm32\Lib\masm32.lib

    include \masm32\include\windows.inc

    include \masm32\include\user32.inc
    include \masm32\include\kernel32.inc

    include \MASM32\INCLUDE\gdi32.inc
	  include \Masm32\include\winmm.inc 


    includelib \masm32\lib\user32.lib
    includelib \masm32\lib\kernel32.lib
    includelib \MASM32\LIB\gdi32.lib

; Bibliotecas para MCI tocar o mp3
;
 
	  includelib \Masm32\lib\winmm.lib

    include base.inc

; #########################################################################

; ------------------------------------------------------------------------
; MACROS are a method of expanding text at assembly time. This allows the
; programmer a tidy and convenient way of using COMMON blocks of code with
; the capacity to use DIFFERENT parameters in each block.
; ------------------------------------------------------------------------

      ; 1. szText
      ; A macro to insert TEXT into the code section for convenient and 
      ; more intuitive coding of functions that use byte data as text.

      ; 3. return
      ; Every procedure MUST have a "ret" to return the instruction
      ; pointer EIP back to the next instruction after the call that
      ; branched to it. This macro puts a return value in eax and
      ; makes the "ret" instruction on one line. It is mainly used
      ; for clear coding in complex conditionals in large branching
      ; code such as the WndProc procedure.

      return MACRO arg
        mov eax, arg
        ret
      ENDM

      szText MACRO Name, Text:VARARG
        LOCAL lbl
          jmp lbl
            Name db Text,0
          lbl:
        ENDM

      ; 2. m2m
      ; There is no mnemonic to copy from one memory location to another,
      ; this macro saves repeated coding of this process and is easier to
      ; read in complex code.

      m2m MACRO M1, M2
        push M2
        pop  M1
      ENDM

      ; 3. return
      ; Every procedure MUST have a "ret" to return the instruction
      ; pointer EIP back to the next instruction after the call that
      ; branched to it. This macro puts a return value in eax and
      ; makes the "ret" instruction on one line. It is mainly used
      ; for clear coding in complex conditionals in large branching
      ; code such as the WndProc procedure.

      return MACRO arg
        mov eax, arg
        ret
      ENDM

; #########################################################################

; ----------------------------------------------------------------------
; Prototypes are used in conjunction with the MASM "invoke" syntax for
; checking the number and size of parameters passed to a procedure. This
; improves the reliability of code that is written where errors in
; parameters are caught and displayed at assembly time.
; ----------------------------------------------------------------------

        WinMain PROTO :DWORD,:DWORD,:DWORD,:DWORD
        WndProc PROTO :DWORD,:DWORD,:DWORD,:DWORD
        PlaySound PROTO STDCALL :DWORD, :DWORD, :DWORD
        TopXY PROTO   :DWORD,:DWORD

; #########################################################################

; ------------------------------------------------------------------------
; This is the INITIALISED data section meaning that data declared here has
; an initial value. You can also use an UNINIALISED section if you need
; data of that type [ .data? ]. Note that they are different and occur in
; different sections.
; ------------------------------------------------------------------------


; Constantes
.const
    ICONE   equ     500 ; define o numero associado ao icon igual ao arquivo RC
    ; define o numero da mensagem criada pelo usuario
    WM_FINISH equ WM_USER+100h  ; o numero da mensagem ?? a ultima + 100h
    img1    equ     100
    img2    equ     101
    img3    equ     103
    img4    equ     104
    img5    equ     105
    img6    equ     106
    img7    equ     107
    img8    equ     108
    img9    equ     109

    CREF_TRANSPARENT  EQU 00FFFFFFh
; ############################################
NumberOfNumbers = 1        ; Number of random numbers to be generated and shown
RangeOfNumbersAppear = 200
RangeOfNumbersPlace = 1000   
RangeOfNumbersGasAppear = 100
; Vari??veis ja com valor
.data
        
        ;jogador plane {}
        ;bala          bullet <Xplayer,Yplayer,0,0>
        
        Explosion     db "explosion.wav", 0
        Fuel          db "fuel.wav", 0
        MusicBackground db "soundtrack.mp3", 0

        ; - MCI_OPEN_PARMS Structure ( API=mciSendCommand ) -
        open_dwCallback     dd ?
        open_wDeviceID     dd ?
        open_lpstrDeviceType  dd ?
        open_lpstrElementName  dd ?
        open_lpstrAlias     dd ?

            ; - MCI_GENERIC_PARMS Structure ( API=mciSendCommand ) -
            generic_dwCallback   dd ?

            ; - MCI_PLAY_PARMS Structure ( API=mciSendCommand ) -
        play_dwCallback     dd ?
        play_dwFrom       dd ?
        play_dwTo        dd ?
; #########################################################################

; Vari??veis ainda sem valor
.data?
      
        hitpoint    POINT <>
        hitpointEnd POINT <>
        threadID    DWORD ?
        thread2ID   DWORD ?  
        hEventStart HANDLE ?
        hBmp        dd ?
        hBmpImg        dd ?
        hBmpHommer dd ?
        hBmpBllt dd ?
        hBmpEnemy1 dd ?
        hBmpEnemy2 dd ?
        hBmpGas dd ?
        ; Musics


;##############################################

.code

; -----------------------------------------------------------------------
; The label "start:" is the address of the start of the code section and
; it has a matching "end start" at the end of the file. All procedures in
; this module must be written between these two.
; -----------------------------------------------------------------------

start:
    invoke GetModuleHandle, NULL ; provides the instance handle
    mov hInstance, eax

    invoke  GetCommandLine        ; provides the command line address
    mov     CommandLine, eax

    ; carrego o bitmap
    invoke LoadBitmap, hInstance, img1
    mov    hBmp, eax

    invoke LoadBitmap, hInstance, img4
    mov    hBmpImg, eax

    invoke LoadBitmap, hInstance, img3
    mov    hBmpHommer, eax

    invoke LoadBitmap, hInstance, img6
    mov hBmpBllt, eax

    invoke LoadBitmap, hInstance, img7
    mov hBmpEnemy1, eax

    invoke LoadBitmap, hInstance, img8
    mov hBmpEnemy2, eax

    invoke LoadBitmap, hInstance, img9
    mov hBmpGas, eax


    ; Chamamos a janela.
    invoke WinMain,hInstance,NULL,CommandLine,SW_SHOWDEFAULT
    
    invoke ExitProcess,eax       ; cleanup & return to operating system

; #########################################################################

WinMain proc hInst     :DWORD, 
             hPrevInst :DWORD,;Parametro irrelevante
             CmdLine   :DWORD,;Parametro irrelevante
             CmdShow   :DWORD ;Parametro irrelevante


        ;====================
        ; Put LOCALs on stack
        ;====================

        LOCAL wc   :WNDCLASSEX ; Janela
        LOCAL msg  :MSG

        LOCAL Wwd  :DWORD
        LOCAL Wht  :DWORD

        szText szClassName,"Generic_Class"

        ;==================================================
        ; Fill WNDCLASSEX structure with required variables
        ;==================================================

        mov wc.cbSize,         sizeof WNDCLASSEX 
        mov wc.style,          CS_BYTEALIGNWINDOW  ; Estilo da tela 
        mov wc.lpfnWndProc,    offset WndProc      ; address of WndProc
        m2m wc.hInstance,      hInst               ; instance handle
        mov wc.hbrBackground,  COLOR_WINDOWTEXT    ; cor do fundo
        mov wc.lpszClassName,  offset szClassName  ; nome da classe windows

        invoke LoadIcon,hInst,500                  ; icon ID   ; resource icon ; id do icon no arquivo RC
        mov wc.hIcon,          eax

        invoke LoadCursor,NULL,IDC_ARROW         ; Definir cursor 
        mov wc.hCursor,        eax
        mov wc.hIconSm,        0

        invoke RegisterClassEx, ADDR wc     ; register the window class

        ;largura da tela em pixels
        mov Wwd, 1366

        ;altura da tela em pixels
        mov Wht, 768


        ; ==================================
        ; Create the main application window
        ; ==================================
        invoke CreateWindowEx,WS_EX_OVERLAPPEDWINDOW,
                              ADDR szClassName,
                              ADDR szDisplayName,
                              WS_OVERLAPPEDWINDOW,
                              CW_USEDEFAULT,CW_USEDEFAULT,Wwd,Wht,
                              NULL,NULL,
                              hInst,NULL

        mov   hWnd,eax  ; Guarda inst??ncia da janela em hWnd

        invoke ShowWindow,hWnd,SW_SHOWNORMAL      ; display the window
        invoke UpdateWindow,hWnd                  ; update the display

      ;===================================
      ; Loop until PostQuitMessage is sent
      ;===================================

    StartLoop:
      invoke GetMessage,ADDR msg,NULL,0,0         ; get each message
      cmp eax, 0                                  ; exit if GetMessage()
      je ExitLoop                                 ; returns zero
      invoke TranslateMessage, ADDR msg           ; translate it
      invoke DispatchMessage,  ADDR msg           ; send it to message proc
      jmp StartLoop
    ExitLoop:

      return msg.wParam

WinMain endp

; PseudoRandom PROC                       ; Deliver EAX: Range (0..EAX-1)
;       push  edx                         ; Preserve EDX
;       imul  edx,RandSeed,08088405H      ; EDX = RandSeed * 0x08088405 (decimal 134775813)
;       inc   edx
;       mov   RandSeed, edx               ; New RandSeed
;       mul   edx                         ; EDX:EAX = EAX * EDX
;       mov   eax, edx                    ; Return the EDX from the multiplication
;       pop   edx                         ; Restore EDX
;       ret
; ret
; PseudoRandom ENDP                       ; Return EAX: Random number in range

;createBullet proc addrPlayer:DWORD
  ;local bal: bullet
  ;assume edx:ptr plane
  ;assume ebx:ptr bullet
  ;mov edx, addrPlayer
  ;mov ecx, [edx].x
  ;mov [edx].bullets[0].x,ecx
  ;mov bal.x, eax
  ;mov ecx, [edx].y
  ;mov [edx].bullets[0].y,ecx
  ;mov bal.y, eax

;createBullet ENDP

; #########################################################################
; Fun????o da janela principal.
WndProc proc hWin   :DWORD,
             uMsg   :DWORD,
             wParam :DWORD,
             lParam :DWORD

    LOCAL hDC    :DWORD
    LOCAL Ps     :PAINTSTRUCT
    LOCAL hOld   :DWORD
    LOCAL memDC  :DWORD

    LOCAL rect   :RECT
    LOCAL Font   :DWORD
    LOCAL Font2  :DWORD

    ; cuidado ao declarar variaveis locais pois ao terminar o procedimento
    ; seu valor ?? limpado colocado lixo no lugar.

    .if uMsg == WM_COMMAND

    ;   Pegar as teclas do teclado

    .elseif uMsg == WM_KEYDOWN
      .if (wParam == 57h) ; Tecla W
        .if (Yplayer > 20)
          sub Yplayer,10
        .endif
      .elseif(wParam == 53h); Tecla S
        .if(Yplayer < 630)
          add Yplayer,10
          .if (musica < 1)
            mov   open_lpstrDeviceType, 0h         ;fill MCI_OPEN_PARMS structure
            mov   open_lpstrElementName,OFFSET MusicBackground
            invoke mciSendCommandA,0,MCI_OPEN, MCI_OPEN_ELEMENT,offset open_dwCallback 
            invoke mciSendCommandA,open_wDeviceID,MCI_PLAY,MCI_FROM or MCI_NOTIFY,offset play_dwCallback
            mov ebx, 1
            mov musica, ebx
          .endif
        .endif
      .elseif(wParam == 41h);Tecla A
        .if (Xplayer > 200)
          sub Xplayer,10
        .endif
      .elseif(wParam == 44h); Tecla D
        .if (Xplayer < 1150)
          add Xplayer,10
        .endif
      .elseif(wParam == 20h); barra de espa??o
        mov ecx, 1
        mov temBala, ecx
        mov ebx, Yplayer
        sub ebx, 2
        mov bala.y, ebx 
        mov ebx, Xplayer
        mov bala.x, ebx
      ;.elseif(wParam == 20h); barra de espa??o
        ;assume edx:ptr bala bullet <Xplayer,Yplayer,0,0>
        
    .endif          

; #################################################



    ;   Tudo relacionado a desenhar na tela tem de ser feito aqui 
    .elseif uMsg == WM_PAINT

            invoke BeginPaint,hWin,ADDR Ps
            ; aqui entra o desejamos desenha, escrever e outros.
            ; h?? uma outra maneira de fazer isso, mas veremos mais adiante.
            
            mov    hDC, eax

            invoke CreateCompatibleDC, hDC
            mov   memDC, eax
            invoke SelectObject, memDC, hBmpHommer
            mov  hOld, eax  
            invoke BitBlt, hDC, 0, 0,1366,768, memDC, 0,0, SRCCOPY
            invoke SelectObject,hDC,hOld
            invoke DeleteDC,memDC  
            
            ; codigo para manipular a imagem bmp
            invoke CreateCompatibleDC, hDC
            mov   memDC, eax

            invoke CDGenerateRandomBits, Addr random_bytes, (NumberOfNumbers)
              lea esi, random_bytes
              lodsd 
              mov ecx, RangeOfNumbersGasAppear             ; Range (0..RangeOfNumbers-1)
              xor edx, edx                        ; Needed for DIV
              div ecx

            mov apareceGas, edx
            .if (apareceGas > 5)
              .if (gasNaTela < 1)
                mov ebx, 1
                mov gasNaTela, ebx
                invoke CDGenerateRandomBits, Addr random_bytes, (NumberOfNumbers)
                  lea esi, random_bytes
                  lodsd 
                  mov ecx, RangeOfNumbersPlace             ; Range (0..RangeOfNumbers-1)
                  xor edx, edx                        ; Needed for DIV
                  div ecx
                add edx, 250
                mov ondeApareceGas, edx
                mov ebx, 0
                mov gas.y, ebx
              .endif
            .endif

            invoke SelectObject, memDC, hBmpGas
            mov  hOld, eax  
            invoke TransparentBlt, hDC, ondeApareceGas,gas.y, 48,48, memDC, \
                          0,0,32,32, CREF_TRANSPARENT
            
            mov ebx, gas.y
            add ebx, 5
            mov gas.y, ebx

            .if (gas.y > 700)
              mov ebx, 0
              mov gasNaTela, ebx
            .endif

            invoke CDGenerateRandomBits, Addr random_bytes, (NumberOfNumbers)
              lea esi, random_bytes
              lodsd 
              mov ecx, RangeOfNumbersAppear             ; Range (0..RangeOfNumbers-1)
              xor edx, edx                        ; Needed for DIV
              div ecx

            mov aparece1, edx
            .if (aparece1 > 198)
              .if (vivo1 < 1)
                mov ebx, 1
                mov vivo1, ebx
                invoke CDGenerateRandomBits, Addr random_bytes, (NumberOfNumbers)
                  lea esi, random_bytes
                  lodsd 
                  mov ecx, RangeOfNumbersPlace             ; Range (0..RangeOfNumbers-1)
                  xor edx, edx                        ; Needed for DIV
                  div ecx
                add edx, 250
                mov ondeAparece1, edx
                mov ebx, 0
                mov inimigo1.y, ebx
              .endif
            .endif

            .if (ondeAparece1 > 200)
              .if (vivo1 > 0)
                invoke SelectObject, memDC, hBmpEnemy1
                mov  hOld, eax  
                invoke TransparentBlt, hDC, ondeAparece1,inimigo1.y, 48,48, memDC, \
                              0,0,32,32, CREF_TRANSPARENT
                mov ebx, inimigo1.y
                add ebx, 5
                mov inimigo1.y, ebx
              .endif
            .endif

            invoke CDGenerateRandomBits, Addr random_bytes, (NumberOfNumbers)
              lea esi, random_bytes
              lodsd 
              mov ecx, RangeOfNumbersAppear             ; Range (0..RangeOfNumbers-1)
              xor edx, edx                        ; Needed for DIV
              div ecx

            mov aparece2, edx
            .if (aparece2 > 198)
              .if (vivo2 < 1)
                mov ebx, 1
                mov vivo2, ebx
                invoke CDGenerateRandomBits, Addr random_bytes, (NumberOfNumbers)
                  lea esi, random_bytes
                  lodsd 
                  mov ecx, RangeOfNumbersPlace             ; Range (0..RangeOfNumbers-1)
                  xor edx, edx                        ; Needed for DIV
                  div ecx
                add edx, 500
                mov ondeAparece2, edx
                mov ebx, 0
                mov inimigo2.y, ebx
              .endif
            .endif

            .if (ondeAparece2 > 200)
              .if (vivo2 > 0)
                invoke SelectObject, memDC, hBmpEnemy2
                mov  hOld, eax  
                invoke TransparentBlt, hDC, ondeAparece2,inimigo2.y, 48,48, memDC, \
                              0,0,32,32, CREF_TRANSPARENT
                mov ebx, inimigo2.y
                add ebx, 5
                mov inimigo2.y, ebx
              .endif
            .endif

            invoke SelectObject, memDC, hBmpImg
            mov  hOld, eax  
            invoke TransparentBlt, hDC, Xplayer,Yplayer, 32,32, memDC, \
                            0,0,14,17, CREF_TRANSPARENT
            
            .if (temBala == 1)
              invoke SelectObject, memDC, hBmpBllt
              mov  hOld, eax  
              invoke TransparentBlt, hDC, bala.x,bala.y, 48,48, memDC, \
                            0,0,32,32, CREF_TRANSPARENT
              mov ebx, bala.y
              sub ebx, 5
              mov bala.y, ebx

              .if (bala.y < 10)
                mov ebx, 0
                mov temBala, ebx
              .endif
            .endif

            mov ebx, ondeApareceGas
            sub ebx, 10
            .if (Xplayer > ebx)
              mov ebx, ondeApareceGas
              add ebx, 10
              .if (Xplayer < ebx)
                mov ebx, gas.y
                sub ebx, 10
                .if (Yplayer > ebx)
                  mov ebx, gas.y
                  add ebx, 10
                  .if (Yplayer < ebx)
                    mov   open_lpstrDeviceType, 0h         ;fill MCI_OPEN_PARMS structure
                    mov   open_lpstrElementName,OFFSET Fuel
                    invoke mciSendCommandA,0,MCI_OPEN, MCI_OPEN_ELEMENT,offset open_dwCallback 
                    invoke mciSendCommandA,open_wDeviceID,MCI_PLAY,MCI_FROM or MCI_NOTIFY,offset play_dwCallback
                    mov ebx, gasolina
                    add ebx, 250
                    mov gasolina, ebx
                  .endif
                .endif
              .endif
            .endif

            .if (inimigo1.y > 700)
              mov ebx, 0
              mov vivo1, ebx
            .endif

            .if (inimigo2.y > 700)
              mov ebx, 0
              mov vivo2, ebx
            .endif

            mov ebx, ondeAparece1
            sub ebx, 10
            .if (bala.x > ebx)
              mov ebx, ondeAparece1
              add ebx, 10
              .if (bala.x < ebx)
                mov ebx, inimigo1.y
                sub ebx, 10
                .if (bala.y > ebx)
                  mov ebx, inimigo1.y
                  add ebx, 10
                  .if (bala.y < ebx)
                    mov ebx, 0
                    mov vivo1, ebx
                    mov ebx, pontuacao
                    add ebx, 10
                    mov pontuacao, ebx
                    mov   open_lpstrDeviceType, 0h         ;fill MCI_OPEN_PARMS structure
                    mov   open_lpstrElementName,OFFSET Explosion
                    invoke mciSendCommandA,0,MCI_OPEN, MCI_OPEN_ELEMENT,offset open_dwCallback 
                    invoke mciSendCommandA,open_wDeviceID,MCI_PLAY,MCI_FROM or MCI_NOTIFY,offset play_dwCallback
                  .endif
                .endif
              .endif
            .endif
            mov ebx, ondeAparece2
            sub ebx, 10
            .if (bala.x > ebx)
              mov ebx, ondeAparece2
              add ebx, 10
              .if (bala.x < ebx)
                mov ebx, inimigo2.y
                sub ebx, 10
                .if (bala.y > ebx)
                  mov ebx, inimigo2.y
                  add ebx, 10
                  .if (bala.y < ebx)
                    mov ebx, 0
                    mov vivo2, ebx
                    mov ebx, pontuacao
                    add ebx, 10
                    mov pontuacao, ebx
                    mov   open_lpstrDeviceType, 0h         ;fill MCI_OPEN_PARMS structure
                    mov   open_lpstrElementName,OFFSET Explosion
                    invoke mciSendCommandA,0,MCI_OPEN, MCI_OPEN_ELEMENT,offset open_dwCallback 
                    invoke mciSendCommandA,open_wDeviceID,MCI_PLAY,MCI_FROM or MCI_NOTIFY,offset play_dwCallback
                  .endif
                .endif
              .endif
            .endif

            mov ebx, ondeAparece1
            sub ebx, 30
            .if (Xplayer > ebx)
              mov ebx, ondeAparece1
              add ebx, 30
              .if (Xplayer < ebx)
                mov ebx, inimigo1.y
                sub ebx, 30
                .if (Yplayer > ebx)
                  mov ebx, inimigo1.y
                  add ebx, 30
                  .if (Yplayer < ebx)
                    invoke wsprintf,addr buffer,chr$("PERDEU O JOGO PONTACAO =  %d"), pontuacao
                    invoke MessageBox,hWin,ADDR buffer,ADDR szDisplayName,MB_OK
                    invoke ExitProcess, NULL 
                  .endif
                .endif
              .endif
            .endif
            mov ebx, ondeAparece2
            sub ebx, 30
            .if (Xplayer > ebx)
              mov ebx, ondeAparece2
              add ebx, 30
              .if (Xplayer < ebx)
                mov ebx, inimigo2.y
                sub ebx, 30
                .if (Yplayer > ebx)
                  mov ebx, inimigo2.y
                  add ebx, 30
                  .if (Yplayer < ebx)
                    invoke wsprintf,addr buffer,chr$("PERDEU O JOGO PONTACAO =  %d"), pontuacao
                    invoke MessageBox,hWin,ADDR buffer,ADDR szDisplayName,MB_OK
                    invoke ExitProcess, NULL 
                  .endif
                .endif
              .endif
            .endif

            mov ebx, gasolina
            sub ebx, 1
            mov gasolina, ebx
            .if(gasolina < 20)
              invoke wsprintf,addr buffer,chr$("PERDEU O JOGO ACABOU A GASOLINA PONTACAO =  %d"), pontuacao
              invoke MessageBox,hWin,ADDR buffer,ADDR szDisplayName,MB_OK
              invoke ExitProcess, NULL 
            .endif

        ;     invoke wsprintf,addr buffer,chr$("Pontuacao = %d"), pontuacao
        ;  ;   invoke MessageBox,hWin,ADDR buffer,ADDR szDisplayName,MB_OK
        ;     ;invoke InvalidateRect, hWnd, NULL, FALSE
        ;     mov   rect.left, 10
        ;     mov   rect.top , 200
        ;     mov   rect.right, 350
        ;     mov   rect.bottom, 230
        ;     ;invoke InvalidateRect, hWnd, addr rect, TRUE

            ; mov   rect.left, 20
            ; mov   rect.top , 20
            ; mov   rect.right, 220
            ; mov   rect.bottom, 40
            ; ;invoke wsprintf,addr buffer,chr$("Pontuacao = %d"), pontuacao

            ; invoke SetBkMode, hDC, TRANSPARENT
            ; invoke SetTextColor,hDC,00EE12FAh   ;
            ; szText texto2,"Pontuacao = %d"
            ; invoke DrawText, hDC, ADDR texto2, -1, ADDR rect, \
            ;      DT_SINGLELINE or DT_CENTER ; or DT_VCENTER

            invoke SelectObject,hDC,hOld
            invoke DeleteDC,memDC  
        
            invoke EndPaint,hWin,ADDR Ps
            return  0
; ######################################################################



    .elseif uMsg == WM_CREATE
    ; --------------------------------------------------------------------
    ; This message is sent to WndProc during the CreateWindowEx function
    ; call and is processed before it returns. This is used as a position
    ; to start other items such as controls. IMPORTANT, the handle for the
    ; CreateWindowEx call in the WinMain does not yet exist so the HANDLE
    ; passed to the WndProc [ hWin ] must be used here for any controls
    ; or child windows.
    ; --------------------------------------------------------------------
        ;mov     X,40
        ;mov     Y,60
        ;mov     imgY,13
        invoke  CreateEvent, NULL, FALSE, FALSE, NULL
        mov     hEventStart, eax
    
        mov eax, offset ThreadProc
        invoke CreateThread, NULL, NULL, eax,  \
                                 NULL, NORMAL_PRIORITY_CLASS, \
                                 ADDR threadID
        ; mov eax, offset drawThread
        ; invoke CreateThread, NULL, NULL, eax, 0, 0, addr thread2ID
        invoke CloseHandle, eax
        mov     contador, 0       
 
    .elseif uMsg == WM_DESTROY
        invoke PostQuitMessage,NULL
        return 0 
    .endif

    invoke DefWindowProc,hWin,uMsg,wParam,lParam

    ret

WndProc endp

drawThread proc p:DWORD
  .while LOL > 0
      invoke Sleep,17
      invoke InvalidateRect, hWnd, NULL, FALSE

  .endw

    ret
drawThread endp




ThreadProc PROC USES ecx Param:DWORD

  invoke WaitForSingleObject, hEventStart, 17
  .if eax == WAIT_TIMEOUT
    invoke InvalidateRect, hWnd, NULL, FALSE
    invoke SendMessage, hWnd, WM_FINISH, NULL, NULL

  .endif
  jmp  ThreadProc
  ret  

ThreadProc ENDP 

end start
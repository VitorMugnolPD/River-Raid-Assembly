

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
    
    
    includelib \masm32\lib\kernel32.lib
    includelib \MASM32\LIB\gdi32.lib
    includelib \MASM32\LIB\Comctl32.lib
    includelib \MASM32\LIB\comdlg32.lib
    includelib \MASM32\LIB\shell32.lib

    INCLUDELIB \Masm32\Lib\msimg32.lib
    INCLUDELIB \Masm32\Lib\oleaut32.lib
    INCLUDELIB \Masm32\Lib\msvcrt.lib
    INCLUDELIB \Masm32\Lib\masm32.lib

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
    WM_FINISH equ WM_USER+100h  ; o numero da mensagem é a ultima + 100h
    img1    equ     100
    img2    equ     101
    img3    equ     103
    img4    equ     104
    img5    equ     105

    CREF_TRANSPARENT  EQU 00FFFFFFh
; ############################################

; Variáveis ja com valor
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
        jogador plane <Xplayer,Yplayer,<NULL>>
        ;bala          bullet <Xplayer,Yplayer,0,0>
; #########################################################################

; Variáveis ainda sem valor
.data?
      
        hitpoint    POINT <>
        hitpointEnd POINT <>
        threadID    DWORD ?
        thread2ID   DWORD ?  
        hEventStart HANDLE ?
        hBmp        dd ?
        hBmpImg        dd ?
        hBmpHommer dd ?
        


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

        mov   hWnd,eax  ; Guarda instância da janela em hWnd

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

; #########################################################################
; Função da janela principal.
WndProc proc hWin   :DWORD,
             uMsg   :DWORD,
             wParam :DWORD,
             lParam :DWORD

    LOCAL hDC    :DWORD
    LOCAL Ps     :PAINTSTRUCT
    LOCAL hOld   :DWORD
    LOCAL memDC  :DWORD

    ; cuidado ao declarar variaveis locais pois ao terminar o procedimento
    ; seu valor é limpado colocado lixo no lugar.

    .if uMsg == WM_COMMAND

    ;   Pegar as teclas do teclado

    .elseif uMsg == WM_KEYDOWN
      .if (wParam == 57h) ; Tecla W
        sub Yplayer,30
      .elseif(wParam == 53h); Tecla S
        add Yplayer,30
      .elseif(wParam == 41h);Tecla A
        sub Xplayer,30
      .elseif(wParam == 44h); Tecla D
        add Xplayer,30
      ;.elseif(wParam == 20h); barra de espaço
        ;assume edx:ptr bala bullet <Xplayer,Yplayer,0,0>
        
    .endif          

; #################################################



    ;   Tudo relacionado a desenhar na tela tem de ser feito aqui 
    .elseif uMsg == WM_PAINT

            invoke BeginPaint,hWin,ADDR Ps
            ; aqui entra o desejamos desenha, escrever e outros.
            ; há uma outra maneira de fazer isso, mas veremos mais adiante.
            
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

            invoke SelectObject, memDC, hBmpImg
            mov  hOld, eax  


            invoke TransparentBlt, hDC, Xplayer,Yplayer, 32,32, memDC, \
                            0,0,14,17, CREF_TRANSPARENT

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

createBullet proc addrPlayer:DWORD
  local bala: bullet
  assume edx:ptr plane
  assume ebx:ptr bullet
  mov edx, addrPlayer
  mov eax, [edx].x
  mov bala.x, eax
  mov eax, [edx].y
  mov bala.y, eax
  lea ebx, [bala]
  mov [edx].bullets, ebx

createBullet ENDP

end start
; Compilation on Linux:
;
; nasm -f win32 hello-win.asm
; i586-mingw32msvc-gcc hello-win.obj -o hello-win.exe
;
; wine hello-win.exe
;
;
; Comiplation on Windows:
; 
; First you have to install the nasm and mingw. Follow this guide:
; http://ccm.net/faq/1559-compiling-an-assembly-program-with-nasm
;
; Then compile and link:
;
; nasm -f win32 hello-win.asm -o hello-win.o
; ld hello-win.o -o hello-win.exe
;
; hello-win.exe


section .data
message:
    db      'Hello, World!', 10, 0

section .text
    global  _main
    extern  _printf

_main:
    push    message
    call    _printf
    add     esp, 4
    ret
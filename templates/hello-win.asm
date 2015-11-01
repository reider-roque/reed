; ----------------------
; Compilation on Linux:
; ----------------------
;
; nasm -f win32 hello-win.asm
; i586-mingw32msvc-gcc hello-win.obj -o hello-win.exe
;
; wine hello-win.exe
;
; ----------------------
; Compilation on Windows:
; ----------------------
; 
; Install MinGW; place the latest versions of nasm.exe and ndisasm.exe into 
; MinGW\bin; add MinGW\bin to path
;
; nasm -f win32 hello-win.asm
; gcc hello-win.obj -o hello-win.exe
;
; Remember that in this case you have to link with gcc instead of ld because 
; the printf function used here is a part of the standard C library


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

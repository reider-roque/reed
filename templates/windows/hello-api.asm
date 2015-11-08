; Assembling and linking in Windows using ld.exe (from mingw) and 
; nasm.exe
;
; Link with ld against static kernel32.lib (Windows SDK must be installed):
;
; nasm -f win32 hello.nasm && ^ 
; ld hello.obj -L"C:\Program Files (x86)\Microsoft SDKs\Windows\v7.1A\Lib" ^
;     -lkernel32 -o hello.exe
;
;
; Link with ld against kernel32.dll (Windows x64):
; Note that in this case you'll have to remove all @## prefixes from function
; names!
;
; nasm -f win32 hello.nasm && ^
; ld hello.obj -L"C:\Windows\SysWOW64" -lkernel32 -o hello.exe
;
;
; Link with golink:
;
; nasm -f win32 hello.nasm && ^
; golink /console /entry _start hello.obj kernel32.dll
;
;
; Link with link (MS linker):
; Note that though the entry point is actually named _start it should be
; used without the leading underscore as an argument to the /entry flag
;
; link /entry:start /subsystem:console hello.obj kernel32.lib
;


;Constants
STD_OUTPUT_HANDLE equ -11

extern _GetStdHandle@4, _WriteConsoleA@20, _ExitProcess@4

section .data
    msg     db "Hello World!", 13, 10, 0
    msglen  equ $-msg

section .bss
    tmpbuf resd 1

section .text
    global _start

_start:
    push STD_OUTPUT_HANDLE
    call _GetStdHandle@4    ; Get stdout handle in EAX

    push 0          ; NULL (per function definition)
    push tmpbuf     ; Number of written bytes; we don't care about it
    push msglen     ; Buffer length
    push msg        ; Buffer
    push eax        ; The stdout handle is in EAX
    call _WriteConsoleA@20
    
    push 0      ; Exit code
    call _ExitProcess@4

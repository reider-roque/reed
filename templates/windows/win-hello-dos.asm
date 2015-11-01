;
; This program uses DOS interruptions and will not run under Windows 7 x64
; It runs under Windows XP SP3 x86; I didn't check Windows 7 x86
;
; Build and link under Windows:
;
; nasm -f obj hello.asm
; alink -c -oEXE hello.obj
;

bits 16

section data
    message db "Hello World!", 13, 10, "$"

section text

..start:
    mov ax, data     ; Have data segment point to the data section
    mov ds, ax
    mov dx, message  ; Load message address into dx
    mov ah, 9        ; Write string to stdout function #
    int 21h
    mov ah, 4Ch      ; Exit function #
    int 21h

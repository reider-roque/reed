; Compilation on Linux:
;
; nasm -f elf hello-lin.asm
; ld hello-lin.o -o hello-lin
;
; ./hello-lin

section .data
    msg:     db "Hello, world!", 10    ; The string and a newline char
    msg_len: equ $-msg   

section .text
    global _start   ; Default entry point for ELF linking

_start:
; Print message to the screen 
    mov eax, 4          ; write syscall code 
    mov ebx, 1          ; stdout
    mov ecx, msg        ; Address of the string to print 
    mov edx, msg_len    ; Length of the string to print 
    int 0x80            ; Invoke the syscall 
    
; Exit 
    mov eax, 1      ; exit syscall code 
    mov ebx, 0      ; program exit code (0 = no errors) 
    int 0x80        ; Invoke the syscall
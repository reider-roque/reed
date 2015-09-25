; Remember that to link object files referencing GLIBC you must use
; gcc instead of ld

section .text
    global main

main:
; Prologue
    push ebp        ; Create a stack frame
    mov ebp, esp
    push ebx        ; Save 'sacred' registers
    push esi
    push edi
    
; Function body

; Epilogue
    pop edi         ; Restore 'sacred' registers
    pop esi
    pop ebx
    mov esp, ebp    ; Destroy the stack frame
    pop ebp
    mov eax, 0  ; Indicate exit status code, 
                ; like `return 0;` from main() function in C
    ret

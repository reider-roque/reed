; Shellcode testing frame written in pure assembly
;
; Remember to link with ld -z execstack!
; In gdb set breakpoint at scexec label, the call instruction after that
; label will jump execution to the shellcode. To dissassemble then use 
; `disas $eip,+20`
;
; Author: Oleg Mitrofanov (reidre-roque) 2015

section .data
    shellcode_ascii: db "\xSH\xEL\xLC\xOD\xEE" ; SHELLCODE GOES HERE

    shellcode_len:   equ $-shellcode_ascii
    len_err_msg: db "Error: Shellcode shellcode_len must be a multiple of 4 (it wasn't).", 10
    len_err_len: equ $-len_err_msg
    dig_err_msg: db "Error: The following symbol is not valid hexadecimal digit: "
    dig_err_len: equ $-dig_err_msg
    eol:         db 10

section .bss
    shellcode_bin:  resb shellcode_len / 4

section .text
    global _start

; Description: converts ASCII code to correspoindg hexadecimal digit
; In:          ASCII digit code in EAX
; Returns:     Single digit (0-9a-f) in EAX
; Changes:     None
; Reference:   ASCII 0-9 take 30-39 range in hex
;              ASCII A-F take 41-46 range in hex
;              ASCII a-f take 61-66 range in hex
process_opcode_digit:
    cmp eax, 0x30    
    jb digit_error
    cmp eax, 0x66
    ja digit_error
    cmp eax, 0x39
    ja .check_uppercase
    ; It is a digit
    sub eax, 0x30   ; Convert ascii digit to hex digit
    ret

.check_uppercase:
    cmp eax, 0x41
    jb digit_error
    cmp eax, 0x46
    ja .check_lowercase
    ; It is an uppercase
    sub eax, 0x37     ; Convert ascii upercase to hex digit
    ret

.check_lowercase:
    cmp eax, 0x61
    jb digit_error
    ; It is a lowercase
    sub eax, 0x57     ; Convert ascii lowercase to hex digit
    ret

_start:
    mov eax, shellcode_len
    mov ebx, 4
    xor edx, edx    ; Clean DX to check for remainder
    div bx          ; Quotient will be in AX, remainder in DX
    cmp edx, 0
    jnz len_error

    mov esi, shellcode_ascii
    mov edi, shellcode_bin
    mov ecx, eax    ; Set the string length in dwords

parse_opcode:
    lodsd
    shr eax, 16
    mov ebx, eax    ; Copy ASCII value of the byte to ebx
    shr eax, 8      ; Process first opcode byte digit in eax (high 8 bytes)
    call process_opcode_digit
    mov edx, eax    ; Store processed first digit in edx

    and ebx, 0xFF   ; Process second opcode byte digit in ebx (low 8 bytes)
    mov eax, ebx
    call process_opcode_digit

    mov ebx, 0x10   ; Use ebx for multiplication
    push edx        ; Store first digit on stack 
    mul ebx         ; Multiply firt digit by 10
    pop edx         ; Restore edx
    add eax, edx    ; Add second digit to the first digit to get the end result
    
    stosb           ; Store the parsed opcode into the binary shellcode space
    loop parse_opcode

scexec:    
    call shellcode_bin
        
    jmp exit

len_error:
    mov eax, 4      ; write system call
    mov ebx, 1      ; stdout
    mov ecx, len_err_msg
    mov edx, len_err_len 
    int 80h
    jmp exit

; Display the invalid symbol found in the shellcode string
digit_error:
    push eax    ; eax at this point contains ASCII code of the invalid hex symbol
    mov eax, 4
    mov ebx, 1
    mov ecx, dig_err_msg
    mov edx, dig_err_len
    int 80h
    mov eax, 4
    mov ebx, 1
    mov ecx, esp
    mov edx, 1
    int 80h
    mov eax, 4
    mov ebx, 1
    mov ecx, eol
    mov edx, 1
    int 80h

exit:
    mov eax, 1
    xor ebx, ebx
    int 80h    

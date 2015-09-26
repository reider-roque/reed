; Shellcode testing frame written in pure Assembly
; Author: Oleg Mitrofanov (reidre-roque) 2015
;
; Remember to link with ld -z execstack!
;
; In gdb set breakpoint at scexec label, the call instruction after that
; label will jump execution to the shellcode. To dissassemble then use 
; `disas $eip,+20`
;

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

; Description   : Converts ascii number to hexadecimal integer 
;                 (StrToInt for hexadecimal numbers)
; In            : ascii digit code in EAX
; Returns       : Single hex digit (0-9a-f) in EAX
; Changes       : None
; Reference     : ascii 0-9 take 30-39 range in hex
;                 ascii A-F take 41-46 range in hex
;                 ascii a-f take 61-66 range in hex
hex_ascii_to_int:
    ; Check if ascii code is completely out of range
    ; and then if it is a number in 0-9 range
    cmp eax, 0x30    
    jb symbol_error
    cmp eax, 0x66
    ja symbol_error
    cmp eax, 0x39
    ja .check_uppercase
    ; It is a number 
    sub eax, 0x30   ; Convert ascii digit to hex digit
    ret

.check_uppercase:
    ; Check if ascii code is an uppercase letter in A-F range
    cmp eax, 0x41
    jb symbol_error
    cmp eax, 0x46
    ja .check_lowercase
    ; It is an uppercase
    sub eax, 0x37     ; Convert ascii upercase to hex digit
    ret

.check_lowercase:
    ; Check if ascii code is a lowercase letter in a-f range
    cmp eax, 0x61
    jb symbol_error
    ; It is a lowercase
    sub eax, 0x57     ; Convert ascii lowercase to hex digit
    ret


_start:
    ; Check if shellcode length is multiple of 4
    mov eax, shellcode_len
    mov ebx, 4      ; Divisor
    xor edx, edx    ; Clean DX for remainder
    div bx          ; Quotient will be in AX, remainder in DX
    cmp edx, 0      ; See if remainder is 0
    jnz len_error   ; Jump to error meessage if not

    ; Parse opcodes one by one converting their ascii representation
    ; into hexadecimal integers
    mov esi, shellcode_ascii
    mov edi, shellcode_bin
    mov ecx, eax    ; Set the string length in dwords

parse_opcode:
    lodsd           ; Copy next ascii opcode representation into EAX
    shr eax, 16     ; Shed the '\x' part, leaving only ascii digits
    mov ebx, eax    ; Copy ascii value of the byte to ebx
    shr eax, 8      ; Process first ascii digit in eax (high 8 bytes)
    call hex_ascii_to_int
    push eax        ; Store first converted integer on the stack

    and ebx, 0xFF   ; Process second ascii digit (low 8 bytes)
    mov eax, ebx    ; Copy to eax
    call hex_ascii_to_int

    ; Note that lodsd loads the ascii text in reverse order. That is first
    ; ascii digit is actually second integer digit and vice versa. Thus
    ; we multiply the second processed ascii digit by 10, not the first one
    mov ebx, 0x10   ; Use ebx for multiplication
    mul ebx         ; Multiply second ascii digit (now first integer digit) by 10
    pop edx         ; Restore first converted digit (second integer) to edx
    add eax, edx    ; Add second integer to the result of multiplication to get the end result
    
    stosb           ; Store the parsed opcode into the binary shellcode space
    loop parse_opcode

scexec:    
    call shellcode_bin
    jmp exit


len_error:
    ; Display error if shellcode length is not multiple of 4
    mov eax, 4      ; write syscall
    mov ebx, 1      ; stdout
    mov ecx, len_err_msg
    mov edx, len_err_len 
    int 80h
    jmp exit

symbol_error:
    ; Display the invalid symbol found in the shellcode string
    push eax    ; eax at this point contains ascii code of the invalid hex symbol
    mov eax, 4  ; write syscall
    mov ebx, 1  ; stdout
    mov ecx, dig_err_msg
    mov edx, dig_err_len
    int 80h
    mov eax, 4
    mov ebx, 1
    mov ecx, esp ; The invalid symbol
    mov edx, 1
    int 80h
    mov eax, 4
    mov ebx, 1
    mov ecx, eol ; Newline char
    mov edx, 1
    int 80h

exit:
    mov eax, 1
    xor ebx, ebx
    int 80h    

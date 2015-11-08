;
; Build and link with the following commands:
;
;    ml.exe /c win-hello-api-masm.asm
;    link.exe /subsystem:console kernel32.lib win-hello-api-masm.obj
;
; Author: Oleg Mitrofanov (reider-roque) 2015
;

.386
.model flat, stdcall
option casemap :none

extrn GetStdHandle@4: PROC
extrn WriteConsoleA@20: PROC
extrn ExitProcess@4: PROC

.const
        STD_OUTPUT_HANDLE equ -11

.data
        msg db "Hello world!", 0
        msglen equ sizeof msg
        tmpbuf dd ?

.code
start:
        push STD_OUTPUT_HANDLE
        call GetStdHandle@4 ; Get stdout handle in EAX

        push 0              ; NULL (per function definition)
        push tmpbuf         ; Number of written bytes; we don't care about it
        push msglen         ; Message length is in EBX
        push offset msg     ; Message
        push eax            ; The stdout handle is in EAX
        call WriteConsoleA@20

        push eax
        call ExitProcess@4
end start
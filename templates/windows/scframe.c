// Build with either gcc.exe or cl.exe:
//
//     gcc scframe.c -o scframe.exe
//     cl scframe.c
//
// Interesting observation: if built with gcc.exe the shellcode will execute
// even without calling VirtualProtect on it. Probably gcc.exe makes the stack
// executable by default.
//
// Author: Oleg Mitrofanov (reider-roque) 2015


#include <stdio.h>
#include <string.h>
#include <windows.h>

// using unsigned char[] instead of char* because the first one
// gets stored in .data, while the second in .rodata. The second
// case becomes a problem with shellcode that modifies itself.
unsigned char shellcode[] = "\xSH\xEL\xLC\xOD\xEE"; // SHELLCODE GOES HERE

int main(void)
{
	DWORD oldProtect;
    
    printf("Shellcode length: %d\n", strlen(shellcode));

    VirtualProtect(shellcode, strlen(shellcode), PAGE_EXECUTE_READWRITE, &oldProtect);
    
    // Cast shellcode string to a function that takes and returns 
    // nothing (void) and execute it
    (*(void(*)(void))shellcode)();

    return 0;
}



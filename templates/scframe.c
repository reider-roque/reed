// Remember to build with gcc -fno-stack-protector -z execstack!

#include <stdio.h>
#include <string.h>

// using unsigned char[] instead of char* because the first one
// gets stored in .data, while the second in .rodata. The second
// case becomes a problem with shellcode that modifies itself.
unsigned char shellcode[] = "\xSH\xEL\xLC\xOD\xEE"; // SHELLCODE GOES HERE

int main(void)
{
    printf("Shellcode length: %d\n", strlen(shellcode));
    
    // Cast shellcode string to a function that takes and returns 
    // nothing (void) and execute it
    (*(void(*)(void))shellcode)();

    return 0;
}

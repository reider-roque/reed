// Remember to build with gcc -fno-stack-protector -z execstack!

#include <stdio.h>
#include <string.h>

char* shellcode = "\xSH\xEL\xCO\xDE";

int main(void)
{
    printf("Shellcode length: %d\n", strlen(shellcode));
    
    // Cast shellcode string to a function that takes and returns 
    // nothing (void) and execute it
    (*(void(*)(void))shellcode)();

    return 0;
}

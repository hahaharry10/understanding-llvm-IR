#include <stdio.h>

int intFunc(void) {
    fprintf(stdout, "intFunc started.\n");
    return 0;
}

void voidFunc(void) {
    fprintf(stdout, "voidFunc started.\n");
    return;
}

int main(void) {
    int x;

    fprintf(stdout, "Some code...\n");

    x = intFunc();
    voidFunc();
    
    fprintf(stdout, "More code...\n");

    return 0;
}

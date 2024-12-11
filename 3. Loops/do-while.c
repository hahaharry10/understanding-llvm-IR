#include <stdio.h>

int main(void) {
    int i, j;

    i = 1;
    j = 0;
    do {
        fprintf(stdout, "%i\n", j);
        j++;
    } while ( j < 10 );

    return 0;
}

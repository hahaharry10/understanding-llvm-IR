#include <stdio.h>

int main(void) {
    int i, j;

    i = 1;
    j = 0;
    while( i ) {
        fprintf(stdout, "%i\n", j);
        if( j > 10 )
            break;
        j++;
    }

    return 0;
}

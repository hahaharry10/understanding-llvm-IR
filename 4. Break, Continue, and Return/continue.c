#include <stdio.h>

int main(void) {
    int i;

    for( i = 0; i < 10; i++ ) {
        if( i == 3 ) {
            continue;
        }
        fprintf(stdout, "%i\n", i);
    }

    i = 0;
    while( i < 10 ) {
        if( i == 3 ) {
            continue;
        }
        fprintf(stdout, "%i\n", i);
        i++;
    }

    i = 0;
    do {
        if( i == 3 ) {
            continue;
        }
        fprintf(stdout, "%i\n", i);
        i++;
    } while( i < 10 );
    
    return 0;
}

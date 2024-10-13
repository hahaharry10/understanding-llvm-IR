int main( int argc, char** argv ) {
    int cond;
    int result;

    cond = 0;
    switch( cond ) {
        case 0:
            result = 0;
            break;
        case 1:
            result = 1;
            break;
        case 2:
            result = 2;
            break;
        default:
            result = 3;
            break;
    }

    return result;
}

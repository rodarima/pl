int do_magic(int hats) {
    int a_lot_of_magic = hats/2;

 return a_lot_of_magic;
}

int main(int argc, char *argv[]) {
    int i;
    double hat = 1.0;
    
    /* Here are a lot of magic, please use it carefully. With great power comes 
       great responsability */

    struct magic {
        int a_lot;
        int more_magic;
        char is_magician;
    } man;
    
    if(i == 0) {
        printf("IT'S MAGIC!\n");
    }
    
    for(i=0; i<10; i++) {
        hat += hat*2;
        if(hat == 10) {
            man.is_magician = 1;
           do_magic(100);
        }
    }
    
    return 0;
}

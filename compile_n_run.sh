# /bin/bash
nasm -f elf main.asm; ld -m elf_i386 -s -o main.out *.o
./main.out
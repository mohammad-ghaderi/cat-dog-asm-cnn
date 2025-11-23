#!/bin/bash
set -e
mkdir -p obj

# Assemble
nasm -f elf64 -g -F dwarf _start.asm -o obj/_start.o
nasm -f elf64 -g -F dwarf loader.asm -o obj/loader.o
nasm -f elf64 -g -F dwarf buffer.asm -o obj/buffer.o
nasm -f elf64 -g -F dwarf parameters.asm -o obj/parameters.o
nasm -f elf64 -g -F dwarf padding.asm -o obj/padding.o

# Link
ld -o model obj/padding.o obj/parameters.o obj/buffer.o obj/loader.o  obj/_start.o \
   -dynamic-linker /lib64/ld-linux-x86-64.so.2 -lc -lm


echo "Build complete: ./model"

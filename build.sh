#!/bin/bash
set -e
mkdir -p obj

# Assemble
nasm -f elf64 -g -F dwarf _start.asm -o obj/_start.o

# Link
ld -o model  obj/_start.o \
   -dynamic-linker /lib64/ld-linux-x86-64.so.2 -lc -lm


echo "Build complete: ./model"

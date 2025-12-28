#!/bin/bash
set -e
mkdir -p obj

# Assemble
nasm -f elf64 -g -F dwarf _start.asm -o obj/_start.o
nasm -f elf64 -g -F dwarf loader.asm -o obj/loader.o
nasm -f elf64 -g -F dwarf buffer.asm -o obj/buffer.o
nasm -f elf64 -g -F dwarf parameters.asm -o obj/parameters.o
nasm -f elf64 -g -F dwarf padding.asm -o obj/padding.o
nasm -f elf64 -g -F dwarf debug_tools.asm -o obj/debug.o
nasm -f elf64 -g -F dwarf debug_buffer.asm -o obj/debug_buffer.o
nasm -f elf64 -g -F dwarf forward.asm -o obj/forward.o
nasm -f elf64 -g -F dwarf convolution.asm -o obj/conv.o
nasm -f elf64 -g -F dwarf maxpool.asm -o obj/maxpool.o
nasm -f elf64 -g -F dwarf dense.asm -o obj/dense.o
nasm -f elf64 -g -F dwarf dot_product.asm -o obj/dot_product.o
nasm -f elf64 -g -F dwarf activation_functions.asm -o obj/act_f.o
nasm -f elf64 -g -F dwarf loss.asm -o obj/loss.o
nasm -f elf64 -g -F dwarf backward.asm -o obj/backward.o
nasm -f elf64 -g -F dwarf matrix_ops.asm -o obj/matrix_ops.o
nasm -f elf64 -g -F dwarf update_weights.asm -o obj/update_weights.o
nasm -f elf64 -g -F dwarf print.asm -o obj/print.o

# Link
ld -o model obj/buffer.o obj/debug_buffer.o obj/debug.o obj/print.o obj/padding.o \
      obj/loss.o obj/matrix_ops.o obj/backward.o obj/update_weights.o \
      obj/act_f.o obj/dot_product.o obj/dense.o \
      obj/conv.o obj/maxpool.o obj/forward.o \
      obj/parameters.o obj/loader.o  obj/_start.o \
   -dynamic-linker /lib64/ld-linux-x86-64.so.2 -lc -lm


echo "Build complete: ./model"

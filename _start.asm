%include "macros.inc"

section .data
    debug2 db "debug/debug2.raw", 0
    msg db "Hello World", 0xa
    len equ $ - msg


section .text
global _start

extern load_train_images, load_sample
extern initialize_parameters
extern forward_path
extern input, label

extern B

_start:

    mov rax, 1
    mov rdi, 1
    lea rsi, [rel msg]
    mov rdx, len
    syscall

    call load_train_images

    call initialize_parameters

    lea r8, [rel input]
    lea r9, [rel label]
    xor rax, rax            ; sample index
    xor rbx, rbx
    call load_sample

    ;CALL_WRITE_FLOATS_FILE input, 49152, debug2     ; 128*128*3


    call forward_path


    ; exit
    mov rax, 60
    xor rdi, rdi
    syscall
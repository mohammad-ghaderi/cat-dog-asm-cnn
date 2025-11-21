
section .data
    msg db "Hello World", 0xa
    len equ $ - msg


section .text
global _start

extern load_train_images, load_batch
extern forward_path
extern input, label

_start:

    mov rax, 1
    mov rdi, 1
    lea rsi, [rel msg]
    mov rdx, len
    syscall

    call load_train_images

    lea r8, [rel input]
    lea r9, [rel label]
    xor rax, rax            ; batch index
    call load_batch

    ; exit
    mov rax, 60
    xor rdi, rdi
    syscall
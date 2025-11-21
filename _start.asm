
section .data
    msg db "Hello World", 0xa
    len equ $ - msg


section .text
global _start

extern load_train_images
extern forward_path

_start:

    mov rax, 1
    mov rdi, 1
    lea rsi, [rel msg]
    mov rdx, len
    syscall

    call load_train_images

    ; exit
    mov rax, 60
    xor rdi, rdi
    syscall
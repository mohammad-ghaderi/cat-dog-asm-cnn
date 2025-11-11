
section .data
    msg db "Hello World", 0xa
    len equ $ - msg


section .text
global _start

_start:

    mov rax, 1
    mov rdi, 1
    lea rsi, [rel msg]
    mov rdx, len
    syscall


    ; exit
    mov rax, 60
    xor rdi, rdi
    syscall
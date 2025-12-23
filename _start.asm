%include "macros.inc"

section .data
    debug2 db "debug/debug2.raw", 0
    msg db "Hello World", 0xa
    len equ $ - msg

section .text
global _start

extern load_train_images, load_sample, initialize_parameters
extern forward_pass
extern backward_pass, update_weights, compute_loss
extern input, label, output
extern print_double

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

    call forward_pass

    movss xmm1, [output]
    movzx eax, byte [label]
    cvtsi2ss xmm0, eax
    call compute_loss           ; compute the loss

    ; print loss
    cvtss2sd xmm0, xmm0           ; convert to double
    call print_double
    

    call backward_pass

    call update_weights
    
    inc r8
    ; exit
    mov rax, 60
    xor rdi, rdi
    syscall
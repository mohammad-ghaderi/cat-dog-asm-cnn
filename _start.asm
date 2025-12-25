BATCH_SIZE equ 32           
EPOCHS equ 10
TOTAL_SAMPLES equ (19998 / BATCH_SIZE) * BATCH_SIZE
BATCHES_PER_EPOCH equ TOTAL_SAMPLES / BATCH_SIZE  ; 624 batches

section .data
    msg db "Hello World", 0xa
    len equ $ - msg

section .rodata
global BATCH_SIZE_INV
BATCH_SIZE_INV dd 0.03125    ; 1/32

section .bss
losses resd BATCH_SIZE      ; store per sample losses

section .text
global _start
extern load_train_images, load_sample, initialize_parameters
extern forward_pass
extern backward_pass, update_weights, compute_loss
extern input, label, output
extern print_double
extern print_layers_out, print_parameters, print_gradients, print_new_parameteres

extern B



_start:

    mov rax, 1
    mov rdi, 1
    lea rsi, [rel msg]
    mov rdx, len
    syscall

    call load_train_images

    call initialize_parameters

    mov rcx, 32             ; epoch
    push rcx

.epoch_loop:
    xor rax, rax            ; batch index
.batch_loop:
    push rax                
    xor rbx, rbx            ; sample index
.sample_loop:
    push rbx
    lea r8, [rel input]
    lea r9, [rel label]
    
    call load_sample

    call forward_pass

    movss xmm1, [output]
    movzx eax, byte [label]
    cvtsi2ss xmm0, eax
    call compute_loss           ; compute the loss

    pop rbx
    push rbx
    movss [losses + rbx*4], xmm0    ; store loss for avg loss

    call backward_pass          ; ======= backpropagation =======

    pop rbx
    inc rbx
    cmp rbx, BATCH_SIZE
    jne .sample_loop            ; go to next sample

    ; Average loss for batch
    pxor xmm1, xmm1
    xor rbx, rbx
.sum_loop:
    addss xmm1, [losses + rbx*4]
    inc rbx
    cmp rbx, BATCH_SIZE
    jl .sum_loop

    mov rax, BATCH_SIZE
    cvtsi2ss xmm0, rax
    divss xmm1, xmm0           ; avg loss in xmm1
    movss xmm0, xmm1
    cvtss2sd xmm0, xmm0           ; convert to double
    ; print loss
    call print_double
    

    call update_weights

    pop rax
    inc rax
    cmp rax, BATCHES_PER_EPOCH
    jne .batch_loop             ; go to next batch

    pop rcx
    inc rcx
    cmp rcx, EPOCHS
    jne .epoch_loop             ; go to next epoch

    
    inc r8
    ; exit
    mov rax, 60
    xor rdi, rdi
    syscall

section .data
    msg db "Hello World", 0xa
    len equ $ - msg

section .text
global _start
extern BATCH_SIZE, BATCHES_PER_EPOCH, EPOCHS, MAX_SIZE_TEST
extern load_train_images, load_test_images, load_sample, initialize_parameters
extern forward_pass, backward_pass, update_weights, compute_loss
extern input, label, output, losses
extern print_double, print_epoch_step, print_layers_out, print_parameters, print_gradients
extern print_new_parameteres, print_accuracy, print_input, print_input_padd

_start:
    mov rax, 1
    mov rdi, 1
    lea rsi, [rel msg]
    mov rdx, len
    syscall

    call load_train_images

    call initialize_parameters

    xor rcx, rcx             ; epoch

.epoch_loop:
    push rcx
    xor rax, rax            ; batch index
.batch_loop:
    push rax                
    xor rbx, rbx            ; sample index
.sample_loop:
    push rbx
    lea r8, [rel input]
    lea r9, [rel label]
    
    imul rax, BATCH_SIZE
    add rax, rbx
    call load_sample

    ; call print_input        ; #debug

    call forward_pass

    ; call print_input_padd   ; #debug

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

    ; print Epoch: number Step: number
    pop rax
    pop rcx
    push rcx
    push rax
    call print_epoch_step

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

    ; call print_parameters       ; $debug
    ; call print_gradients        ; $debug
    ; call print_layers_out       ; $debug
    

    call update_weights

    ; call print_new_parameteres  ; $debug
    pop rax
    inc rax
    cmp rax, BATCHES_PER_EPOCH
    jne .batch_loop             ; go to next batch

    pop rcx
    inc rcx
    cmp rcx, EPOCHS
    jne .epoch_loop             ; go to next epoch


    ; ============= TEST ================

    call load_test_images

    xor rax, rax            ; index of the test image
    xor r12, r12            ; number of valid predictions

.test_loop:
    push rax
    push r12
    lea r8, [rel input]
    lea r9, [rel label]

    call load_sample

    call forward_pass

    movss xmm0, [output]
    cvttss2si eax, xmm0  
    movzx ecx, byte [label]

    pop r12
    cmp eax, ecx
    jne .not_equal
    inc r12
.not_equal:

    pop rax
    inc rax
    cmp rax, MAX_SIZE_TEST
    jne .test_loop

    cvtsi2ss xmm0, r12
    mov rax, MAX_SIZE_TEST
    cvtsi2ss xmm1, rax
    divss xmm0, xmm1

    cvtss2sd xmm0, xmm0 ; convert to double for print input
    call print_accuracy ; print the accuracy saved in xmm0
    
    ; exit
    mov rax, 60
    xor rdi, rdi
    syscall
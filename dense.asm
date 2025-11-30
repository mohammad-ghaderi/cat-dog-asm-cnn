global dense

extern dot_product
extern relu, sigmoid


section .text
; rdi = pointer to input vector
; rsi = pointer to weights matrix (flattened row-major)
; rdx = pointer to bias vector
; r8  = pointer to output buffer
; r9 = num_neurons
; rcx = input_size
; r12 = 0 = ReLU, 1 = Sigmoid
dense:
    mov r10, r9             ; neuron index
    imul r11, rcx, 4        ; bytes of a row          
.layer_loop:

    call dot_product

    cmp r12, 1
    je .no_relu
    
    call relu
    jmp .save_value

.no_relu:
    ; call sigmoid

.save_value:
    movss [r8], xmm0        ; save 

    add r8, 4               ; go to next output
    add rsi, r11            ; set W to next row of it
    add rdx, 4              ; next bias

    dec r10
    jnz .layer_loop    

    ret
global backward_pass
extern label, output
extern outer_product_add, matrix_vector_multiply
extern fc1_out, d_fc1_out, d_fc2_w, d_fc2_b
extern pool1_argmax, pool2_argmax, pool3_argmax
extern pool2_out, conv3_out, pool3_out, fc1_out
extern d_fc2_out, d_fc2_w, d_fc2_b, d_fc1_out, d_fc1_w, d_fc1_b
extern d_pool3, d_conv3_out, d_conv3_w, d_conv3_b
extern d_pool2, d_conv2_out, d_conv2_w, d_conv2_b
extern d_pool1, d_conv1_out, d_conv1_w, d_conv1_b
extern conv1_w, conv2_w, conv3_w
extern fc1_w, fc2_w
extern maxpool_backward
extern relu_backward
extern conv2d_backward

backward_pass:
    movss xmm0, [output]
    movzx eax, byte [label]
    cvtsi2ss xmm1, eax

    subss xmm0, xmm1    ; grad = pred - y
    movss [d_fc2_out], xmm0

    ; d_fc2_w += d_fc2_out^T * fc1_out
    lea rdi, [rel d_fc2_out]        ; gradient from output
    lea rsi, [rel fc1_out]          ; input
    lea rdx, [rel d_fc2_w]          ; gradient for W
    mov rcx, 1                      ; output size
    mov r9, 128                     ; input size
    call outer_product_add

    ; d_fc2_b += d_fc2_out
    movss xmm0, [d_fc2_out]
    addss xmm0, [d_fc2_b]
    movss [d_fc2_b], xmm0

    ; d_fc1_out += d_fc2_out * fc2_w
    lea rdi, [rel d_fc2_out]        ; gradient from output from grad
    lea rsi, [fc2_w]                ; pointer to matrix W
    lea rdx, [d_fc1_out]            ; pointer to output vector
    mov rcx, 1                      ; number of columns in x (size of x)
    mov r9, 128                     ; number of columns in W (size of y)
    call matrix_vector_multiply


    ; gradients with ReLU
    lea rdi, [rel fc1_out]         ; pre-activation
    lea rsi, [rel d_fc1_out]    ; gradient from above
    mov rcx, 128               ; size
    call relu_backward         ; result in d_fc1_out

    ; d_fc1_w += d_fc1_out^T * pool3_out
    lea rdi, [rel d_fc1_out]        ; gradient from output
    lea rsi, [rel pool3_out]        ; input
    lea rdx, [rel d_fc1_w]          ; gradient for W
    mov rcx, 128                    ; output size
    mov r9, 32768                   ; input size
    call outer_product_add

    ; d_fc1_b += d_fc1_out
    lea rdi, [rel d_fc1_out]
    lea rdx, [rel d_fc1_b]
    mov rcx, 128
    call accumulate_db

    ; d_pool3 += d_fc1_out * fc1_w
    lea rdi, [rel d_fc1_out]        ; gradient from output from grad
    lea rsi, [fc1_w]                ; pointer to matrix W
    lea rdx, [d_pool3]              ; pointer to output vector
    mov rcx, 128                    ; number of columns in x (size of x)
    mov r9, 128*16*16               ; number of columns in W (size of y)
    call matrix_vector_multiply


    ; Convolution Section

    ; gradients with ReLU
    lea rdi, [rel pool3_out]        ; pre-activation
    lea rsi, [rel d_pool3]          ; gradient from above
    mov rcx, 128*16*16              ; size
    call relu_backward              ; result in d_fc1_out

    lea rdx, [rel d_conv3_out]      ; grad_conv input address of maxpool
    lea rsi, [rel d_pool3]          ; grad_output address of maxpool
    lea rbx, [rel pool3_argmax]     ; input size
    mov rdi, 32                     ; channel size
    mov rcx, 128                    ; pool_argmax address
    call maxpool_backward


    lea rdi, [rel conv3_w]          ; filter address
    lea rsi, [rel pool2_out]        ; x adress
    lea rdx, [rel d_conv3_out]      ; grade_output address
    mov rcx, 128                    ; number of filters
    mov rax, 32                     ; x(input) size (one of dim)
    lea r14, [rel d_conv3_w]        ; address of d_W
    lea r8, [rel d_pool2]           ; address of d_X
    lea r9, [rel d_conv3_b]         ; address of d_B
    mov rbx, 0xFFFF
    kmovw k1, ebx                   ; k1 = mask
    mov rbx, 64                     ; number of channel
    call conv2d_backward

    ; gradients with ReLU
    lea rdi, [rel pool3_out]        ; pre-activation
    lea rsi, [rel d_pool3]          ; gradient from above
    mov rcx, 128*16*16              ; size
    call relu_backward              ; result in d_fc1_out


    ret



; rdi = pointer to input  (out_grad)
; rdx = pointer to output (db)
; rcx = size of the vector
accumulate_db:
    shr rcx, 4
.db_loop:
    vmovups zmm0, [rdi]
    vmovups zmm1, [rdx]
    vaddps  zmm1, zmm1, zmm0
    vmovups [rdx], zmm1

    add rdi, 64             ; 16 * 4 bytes
    add rdx, 64
    dec rcx
    jnz .db_loop

    ret

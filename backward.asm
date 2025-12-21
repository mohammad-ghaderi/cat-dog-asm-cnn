global backward_pass
extern label, output
extern outer_product_add
extern fc1_out, d_fc1_out, d_fc2_w, d_fc2_b
extern pool1_argmax, pool2_argmax, pool3_argmax
extern pool2_out, conv3_out, pool3_out, fc1_out
extern d_fc2_out, d_fc2_w, d_fc2_b, d_fc1_out, d_fc1_w, d_fc1_b
extern d_pool3, d_conv3_out, d_conv3_w, d_conv3_b
extern d_pool2, d_conv2_out, d_conv2_w, d_conv2_b
extern d_pool1, d_conv1_out, d_conv1_w, d_conv1_b

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

    ; d_fc1_w += d_fc1_out^T * pool3_out
    lea rdi, [rel d_fc1_out]        ; gradient from output
    lea rsi, [rel pool3_out]        ; input
    lea rdx, [rel d_fc1_w]          ; gradient for W
    mov rcx, 128                    ; output size
    mov r9, 32768                   ; input size
    call outer_product_add




    ret
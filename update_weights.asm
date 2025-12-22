global update_weights

extern d_fc2_w, d_fc2_b, d_fc1_w, d_fc1_b
extern d_pool3, d_conv3_out, d_conv3_w, d_conv3_b
extern d_pool2, d_conv2_out, d_conv2_w, d_conv2_b
extern d_pool1, d_conv1_out, d_conv1_w, d_conv1_b

extern conv1_w, conv2_w, conv3_w
extern conv1_b, conv2_b, conv3_b
extern fc1_w, fc1_b, fc2_w, fc2_b

update_weights:
    ; update fc2_w
    lea rdi, [rel d_fc2_w]
    lea rsi, [rel fc2_w]
    mov rcx, 128
    mov rbx, 0xFFFF
    kmovw k1, ebx               ; k1 = mask
    call add_to_vector

    ; update fc2_b
    vmovss xmm0, [rdi]       
    vaddss xmm0, xmm0, [rsi]
    vmulss xmm0, xmm0, [Learning_rate]
    vmovss [rdi], xmm0

    vxorps xmm1, xmm1, xmm1
    vmovss [rsi], xmm1

    ; update fc1_w
    lea rdi, [rel d_fc1_w]
    lea rsi, [rel fc1_w]
    mov rcx, 128*16*16*128
    mov rbx, 0xFFFF
    kmovw k1, ebx               
    call add_to_vector

    ; update fc1_b
    lea rdi, [rel d_fc1_b]
    lea rsi, [rel fc1_b]
    mov rcx, 128
    mov rbx, 0xFFFF
    kmovw k1, ebx               
    call add_to_vector

    ; update conv3_w
    lea rdi, [rel d_conv3_w]
    lea rsi, [rel conv3_w]
    mov rcx, 3*3*64*128
    mov rbx, 0xFFFF
    kmovw k1, ebx               
    call add_to_vector

    ; update conv3_b
    lea rdi, [rel d_conv3_b]
    lea rsi, [rel conv3_b]
    mov rcx, 128
    mov rbx, 0xFFFF
    kmovw k1, ebx               
    call add_to_vector

    ; update conv2_w
    lea rdi, [rel d_conv2_w]
    lea rsi, [rel conv2_w]
    mov rcx, 3*3*32*64
    mov rbx, 0xFFFF
    kmovw k1, ebx               
    call add_to_vector

    ; update conv2_b
    lea rdi, [rel d_conv2_b]
    lea rsi, [rel conv2_b]
    mov rcx, 64
    mov rbx, 0xFFFF
    kmovw k1, ebx               
    call add_to_vector

    
    ; update conv1_w
    lea rdi, [rel d_conv1_w]
    lea rsi, [rel conv1_w]
    mov rcx, 3*3*3*32
    mov rbx, 0000000111111111b
    kmovw k1, ebx               
    call add_to_vector

    ; update conv1_b
    lea rdi, [rel d_conv1_b]
    lea rsi, [rel conv1_b]
    mov rcx, 32
    mov rbx, 0xFFFF
    kmovw k1, ebx               
    call add_to_vector

    ret



; rdi = input
; rsi = output
; rcx = size
; k1 = mask
; output += input
add_to_vector:
    shr rcx, 4
.loop:
    vmovups zmm1{k1}{z}, [rdi]
    vmovups zmm0{k1}{z}, [rsi]
    vaddps  zmm0{k1}, zmm0, zmm1

    vbroadcastss zmm1, [Learning_rate]
    vmulps zmm0, zmm0, zmm1

    vmovups [rsi]{k1}, zmm0

    ; fill the vector with zero
    vpxorq zmm1, zmm1, zmm1
    vmovups [rdi]{k1}, zmm1

    dec rcx
    jnz .loop

    ret


section .rodata
align 4
Learning_rate: dd 0.01        ; float32

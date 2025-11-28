global maxpool

; rdx = input address
; rsi = output address
; rdi = input size
; rcx = channel size
maxpool:
    mov r8, rdi
    imul r8, rdi   ; loop on grid
    shr r8, 1           ; divide by 2

    imul r10, rcx, 4
    mov r11, r10
    imul r11, rdi
    mov r12, r10
    add r12, r11

.loop:
    xor r10, r10
    vmovdqu32 zmm0, [rdx]
    vmovdqu32 zmm1, [rdx + r10]
    vmovdqu32 zmm2, [rdx + r11]
    vmovdqu32 zmm3, [rdx + r12]

    vmaxps zmm0, zmm0, zmm1
    vmaxps zmm0, zmm0, zmm2
    vmaxps zmm0, zmm0, zmm3

    vmovdqu32 [rsi], zmm0       ; save
    add rsi, r10
    lea rdi, [rdi + r10*2]      ; stride is 2

    dec r8
    jnz .loop
    
    ret ; end
    

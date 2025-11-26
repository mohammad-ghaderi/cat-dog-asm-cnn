global maxpool

; rdx = input address
; rsi = output address
; rdi = input size
; rcx = channel size
maxpool:
    imul r8, rdx, rdx   ; loop on grid
    shr r8, 1           ; divide by 2

    imul r10, rcx, 4
    imul r11, rcx, rdi
    add r12, r11, r10

.loop:
    xor r10, r10
    vmovdqu32 zmm0, [rdi]
    vmovdqu32 zmm1, [rdi + r10]
    vmovdqu32 zmm2, [rdi + r11]
    vmovdqu32 zmm3, [rdi + r12]

    vmaxps zmm0, zmm0, zmm1
    vmaxps zmm0, zmm0, zmm2
    vmaxps zmm0, zmm0, zmm3

    vmovdqu32 [rsi], zmm0       ; save
    add rsi, r10
    lea rdi, [rdi + r10*2]      ; stride is 2

    dec r8
    jnz .loop
    
    ret ; end
    

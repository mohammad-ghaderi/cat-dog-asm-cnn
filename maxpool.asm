global maxpool, maxpool_backward

; rdx = input address
; rsi = output address
; rdi = input size
; rcx = channel size
; rbx = pool_argmax address
maxpool:
    mov r8, rdi
    shr r8, 1           ; divide by 2*2
    mov r9, r8          ; r8 = j, r9 = i on grid
    mov rax, r8         ; save for reseting

    imul r10, rcx, 4
    mov r11, r10
    imul r11, rdi       ; size of a layer of input
    mov r12, r10
    add r12, r11

    mov r13, rcx        ; channel cnt from rcx to zero
.loop:
    vmovdqu32 zmm0, [rdx]
    vmovdqu32 zmm1, [rdx + r10]
    vmovdqu32 zmm2, [rdx + r11]
    vmovdqu32 zmm3, [rdx + r12]
    ; save before overwriting zmm0
    vmovdqa32 zmm16, zmm0
    vmovdqa32 zmm17, zmm1
    vmovdqa32 zmm18, zmm2
    vmovdqa32 zmm19, zmm3

    vmaxps zmm0, zmm0, zmm1
    vmaxps zmm0, zmm0, zmm2
    vmaxps zmm0, zmm0, zmm3

    vmovdqu32 [rsi], zmm0       ; save

    vcmpps k0, zmm0, zmm16, 0x0E     ; from zmm0 -> index 0
    vcmpps k1, zmm0, zmm17, 0x0E     ; from zmm1 -> index 1
    vcmpps k2, zmm0, zmm18, 0x0E     ; from zmm2 -> index 2
    vcmpps k3, zmm0, zmm19, 0x0E     ; from zmm3 -> index 3

    ; i think i should not use that 0x0E
    ; the left zeroes are being ignored

    kandw k4, k0, k1         ; k4 = k0 & k1
    kandw k5, k2, k4         ; k5 = k0 & k1 & k2
    knotw k6, k0
    korw k1, k1, k6             ; k1 |= ~k0
    knotw k6, k4
    korw k2, k2, k6             ; k2 |= ~k4
    knotw k6, k5
    korw k3, k3, k6             ; k3 |= ~k5

    kmovw [rbx], k0   ; store 16-bit mask k0 to memory at rbx
    kmovw [rbx+2], k1
    kmovw [rbx+4], k2
    kmovw [rbx+6], k3

    add rsi, 64      ; next output
    add rbx, 8       ; next argmax
    add rdx, 64      ; next input
    sub r13, 16         ; next channel
    jnz .loop

    mov r13, rcx    ; reset channel cnt
    add rdx, r10    ; go to next column, stride 2

    dec r8
    jnz .loop

    mov r8, rax
    add rdx, r11

    dec r9
    jnz .loop
    
    ret ; end




; rdx = grad_conv input address of maxpool
; rsi = grad_output address of maxpool
; rdi = input size
; rcx = channel size
; rbx = pool_argmax address
maxpool_backward:
    mov r8, rdi
    shr r8, 1           ; divide by 2*2
    mov r9, r8          ; r8 = j, r9 = i on grid
    mov rax, r8         ; save for reseting

    imul r10, rcx, 4
    mov r11, r10
    imul r11, rdi       ; size of a layer of input
    mov r12, r10
    add r12, r11

    mov r13, rcx        ; channel cnt from rcx to zero
.loop:

    kmovw k1, [rbx]
    kmovw k2, [rbx+2]
    kmovw k3, [rbx+4]
    kmovw k4, [rbx+6]

    knotw k1, k1
    knotw k2, k2
    knotw k3, k3
    knotw k4, k4

    vmovdqu32 zmm0, [rsi]       

    vmovdqu32 zmm1, [rdx]
    vmovdqu32 zmm2, [rdx + r10]
    vmovdqu32 zmm3, [rdx + r11]
    vmovdqu32 zmm4, [rdx + r12]

    vaddps zmm1{k1}, zmm1, zmm0
    vaddps zmm2{k2}, zmm2, zmm0
    vaddps zmm3{k3}, zmm3, zmm0
    vaddps zmm4{k4}, zmm4, zmm0

    vmovdqu32 [rdx], zmm1
    vmovdqu32 [rdx + r10], zmm2
    vmovdqu32 [rdx + r11], zmm3
    vmovdqu32 [rdx + r12], zmm4

    add rsi, 64      ; next output grade
    add rbx, 8       ; next argmax
    add rdx, 64      ; next input
    sub r13, 16         ; next channel
    jnz .loop

    mov r13, rcx    ; reset channel cnt
    add rdx, r10    ; go to next column, stride 2

    dec r8
    jnz .loop

    mov r8, rax
    add rdx, r11

    dec r9
    jnz .loop
    
    ret ; end
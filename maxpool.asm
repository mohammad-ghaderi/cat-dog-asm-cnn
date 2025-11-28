global maxpool

; rdx = input address
; rsi = output address
; rdi = input size
; rcx = channel size
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

    vmaxps zmm0, zmm0, zmm1
    vmaxps zmm0, zmm0, zmm2
    vmaxps zmm0, zmm0, zmm3

    vmovdqu32 [rsi], zmm0       ; save

    add rsi, 64      ; next output
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
    

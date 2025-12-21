global relu
global sigmoid
global relu_backward

extern expf

section .text

; xmm0 = input
; output = max(0, xmm0)
relu:
    xorps xmm1, xmm1       ; xmm1 = 0
    maxss xmm0, xmm1
    ret


; xmm0 = input
; output = sigmoid(x) in xmm0
sigmoid:
    movaps xmm1, xmm0        ; xmm1 = x
    xorps xmm2, xmm2
    subss xmm2, xmm1         ; xmm2 = -x

    movaps xmm0, xmm2

    push rcx
    push rdx
    push rsi
    push rdi
    push r8
    push r9
    push r10
    push r11

    call expf                ; exp(-x) returned in xmm0

    pop r11
    pop r10
    pop r9
    pop r8
    pop rdi
    pop rsi
    pop rdx
    pop rcx

    mov rax, __one           ; load address of constant
    movss xmm1, [rax]        ; xmm1 = 1.0
    addss xmm0, xmm1         ; xmm0 = 1 + exp(-x)

    movss xmm1, [rax]        ; xmm1 = 1.0
    divss xmm1, xmm0         ; xmm1 = 1.0 / (1 + exp(-x))

    movaps xmm0, xmm1        ; return value in xmm0
    ret



; -----------------------------(later i may optimize here using AVX-512)
; rdi = pre-activation z
; rsi = gradient from above
; rcx = size
relu_backward:
    xor rax, rax
.relu_backward_loop:
    movss xmm0, [rdi + rax*4]  ; z[i]
    xorps xmm1, xmm1
    comiss xmm0, xmm1
    jbe .zero_grad
    movss xmm0, [rsi + rax*4]  ; gradient from above
    jmp .store_grad
.zero_grad:
    xorps xmm0, xmm0
.store_grad:
    movss [rsi + rax*4], xmm0
    inc rax
    cmp rax, rcx
    jl .relu_backward_loop
    ret



section .data
__one: dd 1.0

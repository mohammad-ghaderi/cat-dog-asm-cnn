; from my last project https://github.com/mohammad-ghaderi/mnist-asm-nn/blob/main/dot_product.asm
global dot_product
; rdi = pointer to input vector x (float32[])
; rsi = pointer to weights row W[j] (float32[])
; rcx = length of row
; rdx = pointer to bias (float32)
; returns result in xmm0 (float32)
default rel
section .text

dot_product:
    xor rax, rax           ; index = 0
    vxorps zmm0, zmm0, zmm0      ; accumulator = 0.0

    cmp rcx, 16
    jb .tail

.dp_loop:
    vmovups zmm1, [rdi + rax*4]   ; loading 16 floats from x
    vmovups zmm2, [rsi + rax*4]   ; loading 16 floats from w
    vfmadd231ps zmm0, zmm1, zmm2  ; zmm0 += zmm1 * zmm2     --- beautifullllll instruction :) ---
    add rax, 16
    mov rbx, rcx
    sub rbx, rax              ; remaining elements
    cmp rbx, 16
    jae .dp_loop

    ; zmm0 (16 floats -> 1 float) ; 
    vextractf32x8 ymm1, zmm0, 1   ; high 256 bits
    vaddps  ymm0, ymm0, ymm1      ; add high half to low half
    vextractf128 xmm1, ymm0, 1    ; high 128 bits
    vaddps  xmm0, xmm0, xmm1      ; add high to low        ---  xmm0 [a, b, c, d]
    haddps  xmm0, xmm0            ; adds pairs of floats inside  --- [a+b, c+d, ?, ?]
    haddps  xmm0, xmm0            ; then                         --- [sum_total, ?, ?, ?]

    ; zmm0 = [f0, f1, f2, f3, f4, f5, f6, f7, f8, f9, f10, f11, f12, f13, f14, f15]
    ; ymm0 = [f0+f8, f1+f9, f2+f10, f3+f11, f4+f12, f5+f13, f6+f14, f7+f15]
    ; xmm0 = [f0+f8+f4+f12, f1+f9+f5+f13, f2+f10+f6+f14, f3+f11+f7+f15]
    ; xmm0 = sum of f1...f15
    ; these wierd instructions were usefull

    jmp .tail_end

.tail:
    vxorps xmm0, xmm0, xmm0      ; zero acc if input len is less than 16 at all
    xor rax, rax

.tail_end:
    pxor xmm2, xmm2            ; tail accumulator = 0.0

.tail_loop:
    cmp rax, rcx
    jge .add_bias
    movss xmm3, [rdi + rax*4]
    movss xmm4, [rsi + rax*4]
    mulss xmm3, xmm4
    addss xmm2, xmm3
    inc rax
    jmp .tail_loop

.add_bias:
    addss xmm0, xmm2
    movss xmm1, [rdx]           ; bias
    addss xmm0, xmm1
    ret
global conv2d

extern input, conv1_out
extern conv1_w, conv1_b
extern B

section .text

; rdi = filter address
; rsi = x adress
; rdx = output address
; rcx = number of filters
; rbx = number of channel
; rax = x(input) size (one of dim)
; r14 = address of bias vector
; k1 = mask
conv2d:
    xor r8, r8      ; i
    xor r9, r9      ; j
    lea r10, [rax + 2]      ; r10 = rax + 2         add padding
    imul r10, r10, 12       ; r10 = r10 * 3*4       size of one layer of input (byte)
    imul r12, rbx, 12       ; r12 = rbx * 3*4       size of one layer of filter (byte)       

.next_i_j
    vxorps zmm0, zmm0, zmm0         ; answer of zmm(4,5,6)

    vmovdqu32 zmm1 {k1}{z}, [rsi]
    vmovdqu32 zmm2 {k1}{z}, [rsi + r10]
    vmovdqu32 zmm3 {k1}{z}, [rsi + r10*2]
    xor r13, r13            ; filter idx
.filter_loop:
    mov r11, r12
    shr r11, 6              ; number of blocks of 16 float32 number

    vmovdqu32 zmm4 {k1}{z}, [rdi]               ; from layer 1
    vmovdqu32 zmm5 {k1}{z}, [rdi + r12]         ; from layer 2
    vmovdqu32 zmm6 {k1}{z}, [rdi + r12*2]       ; from layer 3
    vfmadd231ps zmm0, zmm1, zmm4                ; zmm0 += zmm1 * zmm4
    vfmadd231ps zmm0, zmm2, zmm5                ; zmm0 += zmm2 * zmm5
    vfmadd231ps zmm0, zmm3, zmm6                ; zmm0 += zmm3 * zmm6
    
    dec r11
    jnz .next

    ; sum of 16 float in zmm0
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
    movss xmm1, [r14 + r13*4]   ; bias
    addss xmm0, xmm1
    movss [rdx], xmm0           ; save the answer of a filter for output[i][j]

    add rdx, 4          ; to next output

    inc r13
    cmp r13, rcx
    je .end_filters
    lea rdi, [rdi + r12*3]                      ; rdi += r12*3 next filter
    lea rdi, [rdi + rbx*(-4)]                   ; undo the shifting for filter
    lea rsi, [rsi + rbx*(-4)]                   ; same as above for input
    jmp .filter_loop

.next:
    add rdi, 64     ; 16*4 go for next 16 numbers of filter
    add rsi, 64     ; 16*4 go for next 16 numbers of input 
    jmp .filter_loop

.end_filters:
    inc r9
    cmp r9, rax
    jne .next_i_j
    add rsi, 24     ; 2*3*4 skip 2 last pixels ( j is at the end)

    inc r8
    cmp r8, rax
    jne .next_i_j

    ret             ; ---------------------  finaly end :)




    
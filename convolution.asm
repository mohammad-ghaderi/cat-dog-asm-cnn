global conv1_3x3

extern input, conv1_out
extern conv1_w, conv1_b
extern B

section .text

; rsi = x adress
; rdx = output address
; rcx for F loop
; r8 for B loop
; r9 for R loop
; r10 for C loop
; zmm0 for output
conv1_3x3:
    mov rbx, 0000000111111111b
    kmovw k1, ebx               ; mask
    mov rbx, 3*130*4            ; one layer below in 3d input

    vxorps zmm0, zmm0, zmm0
    
    vmovdqu32 zmm2 {k1}{z}, [rdi]
    vmovdqu32 zmm3 {k1}{z}, [rdi+9*4]
    vmovdqu32 zmm4 {k1}{z}, [rdi+18*4]

    lea rsi, [rel input]    ; address of input
    lea rdx, [rel conv1_out]; address of ouput

    xor rcx, rcx        ; filter index
.filter_loop:

    xor r8, r8      ; sample index in batch
    xor r9, r9      ; i for input row
    xor r10, r10    ; j for input column
.kernel_loop:
    vmovdqu32 zmm1 {k1}{z}, [rsi]               ; first layer of the 3d window(3*3) of input
    vfmadd231ps zmm0, zmm1, zmm2
    
    vmovdqu32 zmm1 {k1}{z}, [rsi + rbx]         ; second ... ...
    vfmadd231ps zmm0, zmm1, zmm3

    vmovdqu32 zmm1 {k1}{z}, [rsi + rbx*2]       ; third ... ... 
    vfmadd231ps zmm0, zmm1, zmm4

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

    movss xmm1, [conv1_b + rcx*4] ; bias
    addss xmm0, xmm1

    movss [conv1_out ], xmm0

    add rsi, 3*4    ; move input  cursor
    add rdx, 32*4   ; move output cursor
    
    inc r10
    cmp r10, 128
    jl .next
    xor r10, r10
    add rsi, 2*3*4     ; next row 2*3*4 ,skip 2 last pixel

    inc r9
    cmp r9, 128
    jl .next
    xor r9, r9
    add rsi, 2*130*4    ; next sample 2*130*4 , skip 2 last row
    add rdx, 31*128*128*4  ; skip 31 filter output for reaching same filter in next sample output

    inc r8
    cmp r8, B
    jl .next
    xor r8, r8
    lea rdx, [rel input]    ; go back
    add rdx, 128*128*4      ; next filter output

    cmp rcx, 32
    jl .filter_loop

    ret                 ; end

.next:
    jmp .kernel_loop
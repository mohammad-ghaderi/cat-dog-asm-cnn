global conv2d

extern input, conv1_out
extern conv1_w, conv1_b
extern B

section .text

; rdi = filter address
; rsi = x adress
; rdx = output address
; rcx for F loop
; r8 for R loop
; r9 for C loop
; zmm0 for output
conv2d:
    xor r8, r8      ; i
    xor r9, r9      ; j
    xor rcx, rcx        ; filter idx
    vxorps zmm0, zmm0, zmm0         ; answer of zmm(4,5,6)
    vxorps zmm7, zmm7, zmm7         ; answer of zmm(8,9,10)
    vxorps zmm11, zmm11, zmm11      ; answer of zmm(12,13,14)
    vxorps zmm15, zmm15, zmm15      ; answer of zmm(16,17,18)


    ; r10, r11, k1, bias ---------
.i_loop:
.j_loop:
    vmovdqu32 zmm1 {k1}{z}, [rsi]
    vmovdqu32 zmm2 {k1}{z}, [rsi + r10]
    vmovdqu32 zmm3 {k1}{z}, [rsi + r11]
    
.filter_loop:
    ; each time calculate for 4 filter, to reduce read and write current answer of filters on RAM by using registers
    ; 1st filter of 4
    vmovdqu32 zmm4 {k1}{z}, [rdi]               ; from layer 1
    vmovdqu32 zmm5 {k1}{z}, [rdi + r12]         ; from layer 2
    vmovdqu32 zmm6 {k1}{z}, [rdi + r12*2]       ; from layer 3
    vfmadd231ps zmm0, zmm1, zmm4                ; zmm0 += zmm1 * zmm4
    vfmadd231ps zmm0, zmm2, zmm5                ; zmm0 += zmm2 * zmm5
    vfmadd231ps zmm0, zmm3, zmm6                ; zmm0 += zmm3 * zmm6
    ; 2nd filter of 4
    vmovdqu32 zmm8 {k1}{z}, [rdi]               ; from layer 1
    vmovdqu32 zmm9 {k1}{z}, [rdi + r12]         ; from layer 2
    vmovdqu32 zmm10 {k1}{z}, [rdi + r12*2]      ; from layer 3
    vfmadd231ps zmm7, zmm1, zmm8                ; zmm7 += zmm1 * zmm8
    vfmadd231ps zmm7, zmm2, zmm9                ; zmm7 += zmm2 * zmm9
    vfmadd231ps zmm7, zmm3, zmm10               ; zmm7 += zmm3 * zmm10
    ; 3rd filter of 4
    vmovdqu32 zmm12 {k1}{z}, [rdi]              ; from layer 1
    vmovdqu32 zmm13 {k1}{z}, [rdi + r12]        ; from layer 2
    vmovdqu32 zmm14 {k1}{z}, [rdi + r12*2]      ; from layer 3
    vfmadd231ps zmm11, zmm1, zmm12              ; zmm11 += zmm1 * zmm12
    vfmadd231ps zmm11, zmm2, zmm13              ; zmm11 += zmm2 * zmm13
    vfmadd231ps zmm11, zmm3, zmm14              ; zmm11 += zmm3 * zmm14
    ; 4th filter of 4
    vmovdqu32 zmm16 {k1}{z}, [rdi]              ; from layer 1
    vmovdqu32 zmm17 {k1}{z}, [rdi + r12]        ; from layer 2
    vmovdqu32 zmm18 {k1}{z}, [rdi + r12*2]      ; from layer 3
    vfmadd231ps zmm15, zmm1, zmm16              ; zmm15 += zmm1 * zmm16
    vfmadd231ps zmm15, zmm2, zmm17              ; zmm15 += zmm2 * zmm17
    vfmadd231ps zmm15, zmm3, zmm18              ; zmm15 += zmm3 * zmm18

    inc 


    
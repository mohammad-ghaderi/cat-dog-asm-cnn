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
    imul r10, rbx
    imul r10, r10, 4        ; r10 = r10 * rbx*4     size of one layer of input (byte)
    imul r12, rbx, 12       ; r12 = rbx * 3*4       size of one layer of filter (byte)       

.next_i_j:
    xor r13, r13            ; filter idx
    vxorps zmm0, zmm0, zmm0         ; answer of zmm(4,5,6)

    mov r11, r12
    shr r11, 6              ; number of blocks of 16 float32 number
.filter_loop:
    vmovdqu32 zmm1 {k1}{z}, [rsi]
    vmovdqu32 zmm2 {k1}{z}, [rsi + r10]
    vmovdqu32 zmm3 {k1}{z}, [rsi + r10*2]

    vmovdqu32 zmm4 {k1}{z}, [rdi]               ; from layer 1
    vmovdqu32 zmm5 {k1}{z}, [rdi + r12]         ; from layer 2
    vmovdqu32 zmm6 {k1}{z}, [rdi + r12*2]       ; from layer 3
    vfmadd231ps zmm0, zmm1, zmm4                ; zmm0 += zmm1 * zmm4
    vfmadd231ps zmm0, zmm2, zmm5                ; zmm0 += zmm2 * zmm5
    vfmadd231ps zmm0, zmm3, zmm6                ; zmm0 += zmm3 * zmm6
    
    add rdi, 64     ; 16*4 go for next 16 numbers of filter
    add rsi, 64     ; 16*4 go for next 16 numbers of input 
    dec r11
    jg .filter_loop

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

    ; --- ReLU ---
    pxor xmm1, xmm1
    maxps xmm0, xmm1    ; xmm0 = max(xmm0, xmm1=0)

    movss [rdx], xmm0           ; save the answer of a filter for output[i][j]
    vxorps zmm0, zmm0, zmm0         ; answer to 0

    add rdx, 4          ; to next output

    imul r15, r12, 3                
    add rdi, r15                ; rdi += r12*3 next filter
    lea r15, [r12 + 30]          ; just a trick hhhhhhhhhaaaaaaaaaahaaaaaaa
    shr r15, 6                  ; later i would change these two lines with (and r15, 0xFFFFC0)***
    shl r15, 6                  ; niccccceeeeeeee ;)
    sub rdi, r15                ; set the rdi to the start of the filter (has been moved before)
    sub rsi, r15                ; same as above for input                

    inc r13
    cmp r13, rcx
    jne .filter_loop

    ; end of filters. move the window
    lea rsi, [rsi + rbx*4]     ; mov j = j + 1 also on input
    imul r15, r12, 3
    imul r15, rcx
    sub rdi, r15
    inc r9
    cmp r9, rax
    jne .next_i_j
    xor r9, r9
    lea rsi, [rsi + rbx*8]     ; skip next two j , it is at the last

    inc r8
    cmp r8, rax
    jne .next_i_j
.end_of_end:
    ret             ; ---------------------  finaly end :)




    
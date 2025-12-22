global conv2d, conv2d_backward

extern input, conv1_out
extern conv1_w, conv1_b
extern B
extern relu

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

    mov r11, r12
    shr r11, 6              ; number of blocks of 16 float32 number
.next_i_j:
    xor r13, r13            ; filter idx
    vxorps zmm0, zmm0, zmm0         ; answer of zmm(4,5,6)

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
    
    mov r11, r12
    shr r11, 6              ; number of blocks of 16 float32 number

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
    call relu

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




; rdi = filter address
; rsi = x adress
; rdx = grade_output address
; rcx = number of filters
; rbx = number of channel
; rax = x(input) size (one of dim)
; r14 = address of d_W
; r8 = address of d_X
; r9 = address of d_B
; k1 = mask
conv2d_backward:
    push 0              ; i
    push 0              ; j
    lea r10, [rax + 2]      ; r10 = rax + 2         add padding
    imul r10, rbx
    imul r10, r10, 4        ; r10 = r10 * rbx*4     size of one layer of input (byte)
    imul r12, rbx, 12       ; r12 = rbx * 3*4       size of one layer of filter (byte)       

    mov r11, r12
    shr r11, 6              ; number of blocks of 16 float32 number
.next_i_j:
    xor r13, r13            ; filter idx
    vbroadcastss zmm0, [rdx]                    ; grad (repeats 16 times)

.filter_loop:
    vmovdqu32 zmm1 {k1}{z}, [rsi]               ; from X
    vmovdqu32 zmm2 {k1}{z}, [rsi + r10]
    vmovdqu32 zmm3 {k1}{z}, [rsi + r10*2]

    vmovdqu32 zmm4 {k1}{z}, [rdi]               ; from layer 1
    vmovdqu32 zmm5 {k1}{z}, [rdi + r12]         ; from layer 2
    vmovdqu32 zmm6 {k1}{z}, [rdi + r12*2]       ; from layer 3

    ; compute d_W -----------------
    vmulps zmm7, zmm1, zmm0
    vmulps zmm8, zmm2, zmm0
    vmulps zmm9, zmm3, zmm0

    vmovups zmm13, [r14]            ; load d_W
    vmovups zmm14, [r14 + r12]
    vmovups zmm15, [r14 + r12*2]

    vaddps  zmm13, zmm13, zmm7 ;
    vaddps  zmm14, zmm14, zmm8 ;
    vaddps  zmm15, zmm15, zmm9 ;

    vmovups [r14], zmm13             ; save the d_W
    vmovups [r14 + r12], zmm14
    vmovups [r14 + r12*2], zmm15
    
    ; compute d_X -----------------
    vmulps zmm10, zmm4, zmm0
    vmulps zmm11, zmm5, zmm0
    vmulps zmm12, zmm6, zmm0

    vmovups zmm13, [r8]            ; load d_X
    vmovups zmm14, [r8 + r10]
    vmovups zmm15, [r8 + r10*2]

    vaddps  zmm13, zmm13, zmm7 ;
    vaddps  zmm14, zmm14, zmm8 ;
    vaddps  zmm15, zmm15, zmm9 ;

    vmovups [r8], zmm13             ; save the d_X
    vmovups [r8 + r10], zmm14
    vmovups [r8 + r10*2], zmm15
    
    
    add rdi, 64     ; 16*4 go for next 16 numbers of filter
    add r14, 64     ; d_W
    add rsi, 64     ; 16*4 go for next 16 numbers of input 
    add r8, 64      ; d_X
    dec r11
    jg .filter_loop
    
    mov r11, r12
    shr r11, 6              ; number of blocks of 16 float32 number

    ; compute d_B
    vmovss xmm1, [r9 + r13*4]       ; load existing scalar
    vaddss xmm1, xmm1, xmm0         ; xmm0.low = zmm0 lane 0
    vmovss [r9 + r13*4], xmm1       ; store back

    add rdx, 4          ; to next output

    imul r15, r12, 3                
    add rdi, r15                ; rdi += r12*3 next filter
    add r14, r15                ; r14 += r12*3  -> d_W
    lea r15, [r12 + 30]          
    shr r15, 6                  
    shl r15, 6                  
    sub rdi, r15                ; set the rdi to the start of the filter (has been moved before)
    sub r14, r15                ; d_W
    sub rsi, r15                ; same as above for input                
    sub r8, r15                 ; d_X

    inc r13
    cmp r13, rcx
    jne .filter_loop

    ; end of filters. move the window
    lea rsi, [rsi + rbx*4]     ; mov j = j + 1 also on input
    lea r8, [r8 + rbx*4]     ; mov j = j + 1 also on d_x
    imul r15, r12, 3
    imul r15, rcx
    sub rdi, r15
    sub r14, r15
    
    pop r15         ; j
    inc r15
    push r15
    cmp r15, rax
    jne .next_i_j
    pop r15
    lea rsi, [rsi + rbx*8]     ; skip next two j , it is at the last
    lea r8, [r8 + rbx*8]     ; skip next two j , it is at the last

    pop r15         ; i
    inc r15
    push r15        ; save i+1
    push 0          ; j = 0
    cmp r15, rax
    jne .next_i_j
.end_of_end:
    pop r15
    pop r15
    ret             ; ---------------------  finaly end :)

; from my last project https://github.com/mohammad-ghaderi/mnist-asm-nn/blob/main/matrix_ops.asm

global outer_product_add, matrix_vector_multiply

section .text

; outer_product_add
; Computes: C += A^T × B (outer product accumulated)
; rdi = pointer to vector A (size r9)
; rsi = pointer to vector B (size rcx) 
; rdx = pointer to matrix C (r9 × rcx) - accumulated result
; r9 = size of vector A
; rcx = size of vector B
outer_product_add:
    xor r8, r8              ; i index for vector A
.outer_loop:    
    cmp r8, r9
    jae .outer_end

    vbroadcastss zmm0, dword [rdi + r8*4]   ; zmm0 = A[i]

    mov r12, r8
    imul r12, rcx
    shl r12, 2
    add r12, rdx          ; r12 = &C[i,0]

    xor r10, r10            ; j index for vector B

    cmp rcx, 16
    jb .tail_loop
    
.inner_loop:
    vmovups zmm1, [rsi + r10*4]        ; load B[j..j+15]
    vmovups zmm2, [r12  + r10*4]       ; load C[i, j..J+15]

    ; zmm2 += zmm0 * zmm1  (C += A[i] * B[j..j+15])
    vfmadd231ps zmm2, zmm0, zmm1
    vmovups [r12 + r10*4], zmm2        ; updated C row

    add r10, 16
    mov r11, rcx
    sub r11, r10
    cmp r11, 16
    jae .inner_loop

.tail_loop:
    movss xmm0, dword [rdi + r8*4]   ; A[i]

.tail_inner_loop:
    cmp r10, rcx
    jge .next_outer_i

    movss xmm1, dword [rsi + r10*4]  ; B[j]
    mulss xmm1, xmm0                 ; A[i] * B[j]

    ; load C[i,j], add and store
    movss xmm2, dword [r12 + r10*4]
    addss xmm2, xmm1
    movss dword [r12 + r10*4], xmm2

    inc r10
    jmp .tail_inner_loop

.next_outer_i:
    inc r8
    jmp .outer_loop

.outer_end:
    ret

; matrix_vector_multiply
; Computes: y = x * W  (where x is row vector, W is matrix)
; rdi = pointer to input vector x (size rcx) 
; rsi = pointer to matrix W (rcx × r9) in row-major order
; rdx = pointer to output vector y (size r9)
; rcx = number of columns in x (size of x)
; r9 = number of columns in W (size of y)
matrix_vector_multiply:
    
    xor r8, r8              ; j index for output vector
.outer_loop:
    cmp r8, r9
    jae .outer_end

    mov r11, r9
    sub r11, r8
    cmp r11, 16
    jb .tail_loop

    vxorps zmm0, zmm0, zmm0
    xor r10, r10            ; i index for input vector
.inner_loop:
    cmp r10, rcx
    jae .store_inner

    vbroadcastss zmm1, dword [rdi + r10*4]    ; zmm1 = x[i]

    ; address of W[i, j] = rsi + (i * r9 + j) * 4
    mov r12, r10
    imul r12, r9
    shl r12, 2
    add r12, rsi            ; r12 = &W[i, 0]
    vmovups zmm2, [r12 + r8*4]  ; w[i, j...j+15]

    vfmadd231ps zmm0, zmm1, zmm2 ; zmm0 += x[i] * Wrow_block

    inc r10
    jmp .inner_loop

.store_inner:
    vmovups [rdx + r8*4], zmm0     ; storing 16 results into y

    add r8, 16
    jmp .outer_loop

.tail_loop:
    ; j = r8 .. r9-1
    mov r13, r8          ; j = current column
.tail_loop_col:
    cmp r13, r9
    jge .tail_end

    ; accumulator in xmm0
    pxor xmm0, xmm0

    xor r10, r10         ; i = 0

    .tail_inner:
    cmp r10, rcx
    jge .tail_store

    ; load x[i]
    movss xmm1, dword [rdi + r10*4]
    ; load W[i, j]
    mov r12, r10
    imul r12, r9
    add r12, r13
    shl r12, 2
    add r12, rsi
    movss xmm2, dword [r12]    ; W[i,j]

    mulss xmm1, xmm2
    addss xmm0, xmm1

    inc r10
    jmp .tail_inner

.tail_store:
    movss dword [rdx + r13*4], xmm0

    inc r13
    jmp .tail_loop_col

.tail_end:
    jmp .outer_end

.outer_end:
    ret
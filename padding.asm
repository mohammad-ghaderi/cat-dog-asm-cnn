global add_padding

extern B
PADDING_SIZE equ 1

; rdi = address of the input
; rsi = size of the input
; rdx = number of channels
add_padding:
    mov rcx, rsi
    add rcx, PADDING_SIZE
    add rcx, PADDING_SIZE
    mov r10, rcx 
    imul rcx, rcx           ; rcx = (size + padd)^2
    imul rcx, rdx           ; (size + padd)^2 * channels
    imul rcx, B             ; rcx is size of output

    mov rbx, rsi
    imul rbx, rbx
    imul rbx, rdx
    imul rbx, B             ; rbx is size of input

    dec rcx
    dec rbx

    mov r8, rdi
    lea rdi, [rdi + rcx*4]  ; end of the output
    lea r8, [r8 + rbx*4]    ; end of the input

    vpxord zmm0, zmm0, zmm0 ; zmm0 = 0

    imul r10, rdx    ; r10 = (size + padd) * channels
    mov r15, r10
    
    xor r13, r13
.loop:
    ; last row
    mov r10, r15
    call fill_zero
    
    ; middle
    xor r12, r12
.middle_loop:

    mov r10, rdx
    call fill_zero  ; middle last zero

    mov rax, rsi
    imul rax, rdx  ; rax = numbers to move
    imul rax, 4
    mov r14, rax
    sub rdi, rax        ; rdi = first of row of the ouput, right after padding
    sub r8, rax         ; first of row of the input
    shr rax, 6          ; count of 16 number to move
.middle_block_loop:
    vmovdqu32 zmm1, [r8]
    vmovdqu32 [rdi], zmm1

    add r8, 64
    add rdi, 64
    dec rax
    jnz .middle_block_loop

    sub rdi, r14
    sub r8, r14

    mov r10, rdx
    call fill_zero  ; middle first zero

    inc r12
    cmp r12, rsi
    jne .middle_loop

    ; first row
    mov r10, r15
    imul r10, rdx    ; r10 = (size + padd) * channels
    call fill_zero

    inc r13
    cmp r13, B
    jne .loop

    ret

; r10 = cnt
; rdi = output address
fill_zero:
    mov rax, r10
    imul rax, 4
    sub rdi, rax    ; start

    mov rax, r10
    shr rax, 4      ; rax = number of full zmm blocks

.full_block_loop:
    test rax, rax
    jz .tail
    vmovdqu32 [rdi], zmm0
    add rdi, 64             ; 16*4
    dec rax
    jmp .full_block_loop

.tail:
    mov rax, r10
    and rax, 15     ; rax = leftover over float
    test rax, rax
    jz .done

    kmovd k1, eax    ; mask for leftover floats
    vmovdqu32 [rdi]{k1}, zmm0

.done:
    shr r10, 4
    shl r10, 6
    sub rdi, r10
    ret

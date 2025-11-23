global add_padding

extern B


section .bss
temp resd B*66*66*32    ; this is the max needed

section .text

; rdi = address of the input
; rsi = size of the input
; rdx = number of channels
; (r8 = temp address, r9 = sample index)
add_padding:
    lea r8, [rel temp]
    mov r9, B

    mov rbx, rsi
    add rbx, 2          ; padding to side
    imul rbx, rdx

.loop:
    ; top zero layer
    mov r10, rbx
    call fill_zero

    ; middle layers
    mov r12, rsi
.middle_layer:
    ; first (left) zero side
    mov r10, rdx
    call fill_zero

    ; move numbers
    mov r11, rsi
    imul r11, rdx
    shr r11, 4
.middle_layer_loop:
    vmovdqu32 zmm1, [rdi]
    vmovdqu32 [r8], zmm1
    add rdi, 64
    add r8, 64
    dec r11
    jnz .middle_layer_loop

    ; last (right) zero side
    mov r10, rdx
    call fill_zero

    dec r12
    jnz .middle_layer

    ; bottom zero layer
    mov r10, rbx
    call fill_zero

    dec r9              ; for sample loop of batch
    jnz .loop

    ; mov from temp to input
    ; next step

    ret


; r10 = cnt
; r8 = output address
fill_zero:
    vpxord zmm0, zmm0, zmm0
    mov rax, r10
    shr rax, 4      ; rax = number of full zmm blocks

.full_block_loop:
    test rax, rax
    jz .tail
    vmovdqu32 [r8], zmm0
    add r8, 64             ; 16*4
    dec rax
    jmp .full_block_loop

.tail:
    and r10, 15
    jz .done
    mov ecx, r10d      ; number of elements (0-15)
    mov eax, 1
    shl eax, cl        ; 1 << r10
    dec eax            ; (1 << r10) - 1
    
    kmovd k1, eax      
    vmovdqu32 [r8]{k1}, zmm0
.done:
    shl r10, 2
    add r8, r10
    ret

global add_padding

extern B
PADDING_SIZE equ 1

section .bss
temp resb B*66*66*32    ; this is the max needed

section .text

; rdi = address of the input
; rsi = size of the input
; rdx = number of channels
add_padding:
; next would be implemented

; r10 = cnt
; rdi = output address
fill_zero:
    vpxord zmm0, zmm0, zmm0
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
    and r10, 15
    jz .done
    mov ecx, r10d      ; number of elements (0-15)
    mov eax, 1
    shl eax, cl        ; 1 << r10
    dec eax            ; (1 << r10) - 1
    
    kmovd k1, eax      
    vmovdqu32 [rdi]{k1}, zmm0
.done:
    ret

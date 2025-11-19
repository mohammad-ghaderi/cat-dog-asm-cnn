global load_train_images
global load_test_images

extern input
extern labels
extern B

section .bss
temp resb B*3*128*128

; rdi = batch index
load_train_images:
    mov rbx, rdi            ; save the index

    mov rax, 2              ; sys open
    mov rdi, train_data
    mov rsi, 0              ; O_RDONLY
    syscall
    mov f12, rax            ; save fd

    mov rax, rbx
    imul rax, 3*128*128*B   ; byte per batch
    mov rsi, rax

    mov rax, 8              ; sys lseek
    mov rdi, r12            ; fd
    mov rdi, 0              ; seek set
    syscall

    mov rax, 0              ; sys read
    mov rdi, r12            ; fd
    mov rdx, 3*128*128*B    ; bytes to read
    mov rsi, temp  
    syscall

    ; convert to float from byte and store in input
    mov rbx, 3*128*128*B
    call convert_to_float

    ; close
    mov rax, 3              ; sys close
    mov rdi, r12
    syscall

    ret

load_test_images:
; later...


convert_to_float:
    xor rcx, rcx
.convert_loop:
    cmp rcx, rbx
    jge .done
    
    movzx eax, byte [temp + rcx]    ; load byte
    cvtsi2ss xmm0, eax              ; convert to float
    mulss xmm0, [one_over_255]      ; normalize 0-1
    movss [input + rcx*4], xmm0

    inc rcx
    jmp .convert_loop

.done:
    ret


section .data
train_data  db "dataset/raw_files/train_data.raw",0
train_label db "dataset/raw_files/train_label.raw",0
test_data   db "dataset/raw_files/test_data.raw",0
test_label  db "dataset/raw_files/test_label.raw",0
one_over_255 dd 0.0039215689  ; 1/255.0
global load_train_images
global load_test_images

extern input
extern label
B equ 32
MAX_SIZE equ 19998

section .bss
all_data resb MAX_SIZE*3*128*128
all_label resb MAX_SIZE

section .text
load_train_images:
    mov rax, 2              ; sys open
    lea rdi, [rel train_data]
    mov rsi, 0              ; O_RDONLY
    syscall
    mov r12, rax            ; save fd

    xor rsi, rsi
    mov rax, 8              ; sys lseek
    mov rdi, r12            ; fd
    mov rdx, 0              ; seek set
    syscall

    mov rax, 0              ; sys read
    mov rdi, r12            ; fd
    mov rdx, 3*128*128*MAX_SIZE    ; bytes to read (all)
    lea rsi, [rel all_data]  
    syscall

    ; load labels
    mov rax, 2              ; sys open
    lea rdi, [rel train_label]
    mov rsi, 0              ; O_RDONLY
    syscall
    mov r13, rax            ; save fd

    xor rsi, rsi
    mov rax, 8              ; sys lseek
    mov rdi, r13            ; fd
    mov rdx, 0              ; seek set
    syscall

    mov rax, 0              ; sys read
    mov rdi, r13            ; fd
    mov rdx, MAX_SIZE    ; bytes to read (all)
    lea rsi, [rel all_label]
    syscall

    ; close
    mov rax, 3              ; sys close
    mov rdi, r12
    syscall
    mov rdi, r13
    syscall

    ret

load_test_images:
; later...


convert_to_float:
    xor rcx, rcx
.convert_loop:
    cmp rcx, rbx
    jge .done
    
    movzx eax, byte [all_data + rcx]    ; load byte
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
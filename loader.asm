global load_train_images
global load_test_images

extern input
extern labels
extern B

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
    mov rdx, 3*128*128*B    ; bytes to read
    mov rsi, input  
    syscall


    mov rax, 3              ; sys close
    mov rdi, r12
    syscall

    return

load_test_images:



section .data
train_data  db "dataset/raw_files/train_data.raw",0
train_label db "dataset/raw_files/train_label.raw",0
test_data   db "dataset/raw_files/test_data.raw",0
test_label  db "dataset/raw_files/test_label.raw",0
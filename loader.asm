global load_train_images
global load_test_images
global load_batch

B equ 32
IMAGE_SIZE equ 3*128*128
BATCH_BYTES equ B*IMAGE_SIZE
MAX_SIZE equ 19998

section .bss
all_data resb MAX_SIZE*IMAGE_SIZE
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
    mov rdx, IMAGE_SIZE*MAX_SIZE    ; bytes to read (all)
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


;=============== Load & Convert batch to float ==================
; rax = index of the batch, batch size should be 2^n and n >= 4
; r8 = input address for a batch
; r9 = labels address for a batch
load_batch:
    xor rcx, rcx
    lea rsi, [rel all_data]
    lea rdi, [rel all_label]
    imul rax, B
    add rdi, rax
    imul rax, IMAGE_SIZE
    add rsi, rax
.data_loop:
    cmp rcx, BATCH_BYTES
    jge .data_done
    
    vmovdqu8 zmm0, [rsi + rcx]                      ; load 16 bytes
    vpmovzxbd zmm1, xmm0                            ; expand low 16 bytes
    vcvtdq2ps zmm2, zmm1                            ; convert to float32
    vbroadcastss zmm3, dword [one_over_255]
    vmulps zmm2, zmm2, zmm3                         ; normalize 0-1
    vmovups [r8 + rcx*4], zmm2                      ; store 16 float
    add rcx, 16
    jmp .data_loop

.data_done:
    xor rcx, rcx

.label_loop:
    cmp rcx, B
    jge .label_done
    vmovdqu8 zmm0, [rdi + rcx]
    vmovdqu8 [r9 + rcx], zmm0                       ; mov 16 labels from all_labels to labels
    add rcx, 16

.label_done:
    ret


section .data
train_data  db "dataset/raw_files/train_data.raw",0
train_label db "dataset/raw_files/train_label.raw",0
test_data   db "dataset/raw_files/test_data.raw",0
test_label  db "dataset/raw_files/test_label.raw",0
one_over_255 dd 0.0039215689  ; 1/255.0
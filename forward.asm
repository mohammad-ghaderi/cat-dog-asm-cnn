%include "macros.inc"

global forward_path

extern conv2d
extern conv1_w, conv2_w, conv3_w
extern conv1_b, conv2_b, conv3_b
extern input, label
extern conv1_out, pool1_out, conv2_out
extern pool2_out, conv3_out, pool3_out, fc1_out
extern output, fc1_w, fc1_b, fc2_w, fc2_b

extern maxpool
extern add_padding
extern dense

section .text

forward_path:

    ; ---- First layer ---------------------------------
    lea rdi, [rel input]
    mov rsi, 128
    mov rdx, 3
    call add_padding

    ; CALL_WRITE_FLOATS_FILE input, 50700 , debug1   ; (1+128+1)*(1+128+1)*3

    lea rdi, [rel conv1_w]      ; rdi = filter address
    lea rsi, [rel input]        ; rsi = x adress
    lea rdx, [rel conv1_out]    ; rdx = output address
    mov rcx, 32                 ; rcx = number of filters
    mov rax, 128                ; rax = x(input) size (one of dim)
    lea r14, [rel conv1_b]      ; r14 = address of bias vector
    mov rbx, 0000000111111111b
    kmovw k1, ebx               ; k1 = mask
    mov rbx, 3                  ; rbx = number of channel

    call conv2d

    ; CALL_WRITE_FLOATS_FILE conv1_out, 524288 , debug3   ; 128*128*32

    lea rdx, [rel conv1_out]    ; rdx = input address
    lea rsi, [rel pool1_out]    ; rsi = output address
    mov rdi, 128                ; rdi = input size
    mov rcx, 32                 ; rcx = channel size  (not changed)
    call maxpool

    ; CALL_WRITE_FLOATS_FILE pool1_out, 131072 , debug4   ; 64*64*32

    ;----- Second layer --------------------------------------
    lea rdi, [rel pool1_out]    ; rdi = address of the input
    mov rsi, 64                 ; rsi = size of the input
    mov rdx, 32                 ; rdx = number of channels
    call add_padding

    ; CALL_WRITE_FLOATS_FILE pool1_out, 139392 , debug5   ; (1+64+1)*(1+64+1)*32

    lea rdi, [rel conv2_w]      ; rdi = filter address
    lea rsi, [rel pool1_out]    ; rsi = x adress
    lea rdx, [rel conv2_out]    ; rdx = output address
    mov rcx, 64                 ; rcx = number of filters
    mov rax, 64                 ; rax = x(input) size (one of dim)
    lea r14, [rel conv2_b]      ; r14 = address of bias vector
    mov rbx, 0xFFFF
    kmovw k1, ebx               ; k1 = mask
    mov rbx, 32                 ; rbx = number of channel

    call conv2d

    ; CALL_WRITE_FLOATS_FILE conv1_out, 131072 , debug6   ; 64*64*32

    lea rdx, [rel conv2_out]    ; rdx = input address
    lea rsi, [rel pool2_out]    ; rsi = output address
    mov rdi, 64                 ; rdi = input size
    mov rcx, 64                 ; rcx = channel size  (not changed)
    call maxpool
    
    ;----- Third layer --------------------------------------
    lea rdi, [rel pool2_out]    ; rdi = address of the input
    mov rsi, 32                 ; rsi = size of the input
    mov rdx, 64                 ; rdx = number of channels
    call add_padding

    lea rdi, [rel conv3_w]      ; rdi = filter address
    lea rsi, [rel pool2_out]    ; rsi = x adress
    lea rdx, [rel conv3_out]    ; rdx = output address
    mov rcx, 128                ; rcx = number of filters
    mov rax, 32                 ; rax = x(input) size (one of dim)
    lea r14, [rel conv3_b]      ; r14 = address of bias vector
    mov rbx, 0xFFFF
    kmovw k1, ebx               ; k1 = mask
    mov rbx, 64                 ; rbx = number of channel

    call conv2d

    lea rdx, [rel conv3_out]    ; rdx = input address
    lea rsi, [rel pool3_out]    ; rsi = output address
    mov rdi, 32                 ; rdi = input size
    mov rcx, 128                 ; rcx = channel size  (not changed)
    call maxpool

    ; CALL_WRITE_FLOATS_FILE pool3_out, 32768 , debug7   ; 16*16*128

    ; pool3_out is the flattend (features)

    lea rdi, [rel pool3_out]    ; rdi = pointer to input vector x (float32[])
    lea rsi, [rel fc1_w]        ; rsi = pointer to weights row W[j] (float32[])
    mov rcx, 32768              ; rcx = length of row
    lea rdx, [rel fc1_b]        ; rdx = pointer to bias (float32)
    mov r12, 0                  ; flag for ReLU as activation function
    mov r8, fc1_out             ; output of the first dense layer
    mov r9, 128
    call dense


    lea rdi, [rel fc1_out]      ; rdi = pointer to input vector x (float32[])
    lea rsi, [rel fc2_w]        ; rsi = pointer to weights row W[j] (float32[])
    mov rcx, 128                ; rcx = length of row
    lea rdx, [rel fc2_b]        ; rdx = pointer to bias (float32)
    mov r12, 1                  ; flag for ReLU as activation function
    mov r8, output              ; output of the first dense layer
    mov r9, 1
    call dense
    
.stop_here:

    ret

section .data
    debug1 db "debug/debug1.raw", 0
    debug3 db "debug/debug3.raw", 0
    debug4 db "debug/debug4.raw", 0
    debug5 db "debug/debug5.raw", 0
    debug6 db "debug/debug6.raw", 0
    debug7 db "debug/debug7.raw", 0
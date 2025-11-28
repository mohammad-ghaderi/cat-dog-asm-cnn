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

section .text

forward_path:

    lea rdi, [rel input]
    mov rsi, 128
    mov rdx, 3
    call add_padding

    ; CALL_WRITE_FLOATS_FILE input, 50700 , debug1   ; (1+128+1)*(1+128+128)*3

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

    ret

section .data
    debug1 db "debug/debug1.raw", 0
    debug3 db "debug/debug3.raw", 0
    debug4 db "debug/debug4.raw", 0
global forward_path

extern conv2d
extern conv1_w, conv2_w, conv3_w
extern conv1_b, conv2_b, conv3_b
extern input, label
extern conv1_out, pool1_out, conv2_out
extern pool2_out, conv3_out, pool3_out, fc1_out
extern output, fc1_w, fc1_b, fc2_w, fc2_b

section .text

forward_path:

; rdi = filter address
; rsi = x adress
; rdx = output address
; rcx = number of filters
; rbx = number of channel
; rax = x(input) size (one of dim)
; r14 = address of bias vector
; k1 = mask
    lea rdi, [rel conv1_w]
    lea rsi, [rel input]
    lea rdx, [rel conv1_out]
    mov rcx, 32
    mov rax, 128
    lea r14, [rel conv1_b]
    mov rbx, 0000000111111111b
    kmovw k1, ebx               ; mask
    mov rbx, 3

    call conv2d



    ret
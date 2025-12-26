%include "macros.inc"

global print_layers_out, print_parameters, print_gradients, print_new_parameteres
global write_floats

extern fc1_out, d_fc1_out, d_fc2_w, d_fc2_b
extern pool1_argmax, pool2_argmax, pool3_argmax
extern pool2_out, conv3_out, pool3_out, fc1_out, pool1_out
extern d_fc2_out, d_fc2_w, d_fc2_b, d_fc1_out, d_fc1_w, d_fc1_b
extern d_pool3, d_conv3_out, d_conv3_w, d_conv3_b
extern d_pool2, d_conv2_out, d_conv2_w, d_conv2_b
extern d_pool1, d_conv1_out, d_conv1_w, d_conv1_b
extern conv1_w, conv2_w, conv3_w
extern output, fc1_w, fc1_b, fc2_w, fc2_b
extern conv1_out, pool1_out, conv2_out
extern pool2_out, conv3_out, pool3_out, fc1_out
extern conv1_w, conv2_w, conv3_w
extern conv1_b, conv2_b, conv3_b
extern input, label, output

; rdi = pointer to array
; rsi = count
; rdx = file name
write_floats:
    push rax
    push r8
    push r9
    push r10
    push r11

    push rbp
    mov rbp, rsp

    mov r8, rdi       ; A
    mov r9, rsi       ; x
    mov r10, rdx      ; filename

    ; openat(AT_FDCWD, filename, flags, mode)
    mov rax, 257      ; sys_openat
    mov rdi, -100     ; AT_FDCWD
    mov rsi, r10      ; filename
    mov rdx, 1+64+512 ; O_WRONLY|O_CREAT|O_TRUNC
    mov r10, 0o644    ; mode
    syscall

    cmp rax, 0
    js .error
    mov r11, rax      ; fd

    ; write(fd, A, x*4)
    mov rax, 1
    mov rdi, r11
    mov rsi, r8
    mov rdx, r9
    shl rdx, 2
    syscall

    ; close(fd)
    mov rax, 3
    mov rdi, r11
    syscall

    mov rax, 0
    jmp .end

.error:
    mov rax, -1

.end:
    leave
    pop r11
    pop r10
    pop r9
    pop r8
    pop rax
    ret



print_layers_out:
    CALL_WRITE_FLOATS_FILE conv1_out, 524288, debug_out_1       ; 32*128*128
    CALL_WRITE_FLOATS_FILE pool1_out, 131072, debug_out_2       ; 32*64*64
    CALL_WRITE_FLOATS_FILE conv2_out, 262144, debug_out_3       ; 64*64*64
    CALL_WRITE_FLOATS_FILE pool2_out, 65536, debug_out_4        ; 64*32*32
    CALL_WRITE_FLOATS_FILE conv3_out, 131072, debug_out_5       ; 128*32*32
    CALL_WRITE_FLOATS_FILE pool3_out, 32768, debug_out_6        ; 128*16*16
    CALL_WRITE_FLOATS_FILE fc1_out, 128, debug_out_7            ; 128
    CALL_WRITE_FLOATS_FILE output, 1, debug_out_8               ; 1
    ret


print_parameters:
    CALL_WRITE_FLOATS_FILE conv1_w, 864, debug_w_1              ; 3*3*3*32
    CALL_WRITE_FLOATS_FILE conv2_w, 18432, debug_w_3            ; 3*3*32*64
    CALL_WRITE_FLOATS_FILE conv3_w, 73728, debug_w_5            ; 3*3*64*128
    CALL_WRITE_FLOATS_FILE fc1_w, 4194304, debug_w_7            ; 128*16*16*128
    CALL_WRITE_FLOATS_FILE fc2_w, 128, debug_w_8                ; 128

    CALL_WRITE_FLOATS_FILE conv1_b, 32, debug_b_1               ; 32
    CALL_WRITE_FLOATS_FILE conv2_b, 64, debug_b_3               ; 64
    CALL_WRITE_FLOATS_FILE conv3_b, 128, debug_b_5              ; 128
    CALL_WRITE_FLOATS_FILE fc1_b, 128, debug_b_7                ; 128
    CALL_WRITE_FLOATS_FILE fc2_b, 1, debug_b_8                  ; 1
    ret


print_gradients:
    CALL_WRITE_FLOATS_FILE d_conv1_out, 524288, debug_d_out_1   ; 32*128*128
    CALL_WRITE_FLOATS_FILE d_pool1, 131072, debug_d_out_2       ; 32*64*64
    CALL_WRITE_FLOATS_FILE d_conv2_out, 262144, debug_d_out_3   ; 64*64*64
    CALL_WRITE_FLOATS_FILE d_pool2, 65536, debug_d_out_4        ; 64*32*32
    CALL_WRITE_FLOATS_FILE d_conv3_out, 131072, debug_d_out_5   ; 128*32*32
    CALL_WRITE_FLOATS_FILE d_pool3, 32768, debug_d_out_6        ; 128*16*16
    CALL_WRITE_FLOATS_FILE d_fc1_out, 128, debug_d_out_7        ; 128
    CALL_WRITE_FLOATS_FILE d_fc2_out, 1, debug_d_out_8          ; 1

    CALL_WRITE_FLOATS_FILE d_conv1_w, 864, debug_d_w_1          ; 3*3*3*32
    CALL_WRITE_FLOATS_FILE d_conv2_w, 18432, debug_d_w_3        ; 3*3*32*64
    CALL_WRITE_FLOATS_FILE d_conv3_w, 73728, debug_d_w_5        ; 3*3*64*128
    CALL_WRITE_FLOATS_FILE d_fc1_w, 4194304, debug_d_w_7        ; 128*16*16*128
    CALL_WRITE_FLOATS_FILE d_fc2_w, 128, debug_d_w_8            ; 128

    CALL_WRITE_FLOATS_FILE d_conv1_b, 32, debug_d_b_1           ; 32
    CALL_WRITE_FLOATS_FILE d_conv2_b, 64, debug_d_b_3           ; 64
    CALL_WRITE_FLOATS_FILE d_conv3_b, 128, debug_d_b_5          ; 128
    CALL_WRITE_FLOATS_FILE d_fc1_b, 128, debug_d_b_7            ; 128
    CALL_WRITE_FLOATS_FILE d_fc2_b, 1, debug_d_b_8              ; 1
    ret


print_new_parameteres:
    CALL_WRITE_FLOATS_FILE conv1_w, 864, debug_new_w_1          ; 3*3*3*32
    CALL_WRITE_FLOATS_FILE conv2_w, 18432, debug_new_w_3        ; 3*3*32*64
    CALL_WRITE_FLOATS_FILE conv3_w, 73728, debug_new_w_5        ; 3*3*64*128
    CALL_WRITE_FLOATS_FILE fc1_w, 4194304, debug_new_w_7        ; 128*16*16*128
    CALL_WRITE_FLOATS_FILE fc2_w, 128, debug_new_w_8            ; 128

    CALL_WRITE_FLOATS_FILE conv1_b, 32, debug_new_b_1           ; 32
    CALL_WRITE_FLOATS_FILE conv2_b, 64, debug_new_b_3           ; 64
    CALL_WRITE_FLOATS_FILE conv3_b, 128, debug_new_b_5          ; 128
    CALL_WRITE_FLOATS_FILE fc1_b, 128, debug_new_b_7            ; 128
    CALL_WRITE_FLOATS_FILE fc2_b, 1, debug_new_b_8              ; 1
    ret


section .data

    debug_out_1 db "debug/01/raw/debug_out_1.raw", 0
    debug_out_2 db "debug/01/raw/debug_out_2.raw", 0
    debug_out_3 db "debug/01/raw/debug_out_3.raw", 0
    debug_out_4 db "debug/01/raw/debug_out_4.raw", 0
    debug_out_5 db "debug/01/raw/debug_out_5.raw", 0
    debug_out_6 db "debug/01/raw/debug_out_6.raw", 0
    debug_out_7 db "debug/01/raw/debug_out_7.raw", 0
    debug_out_8 db "debug/01/raw/debug_out_8.raw", 0
    debug_out_9 db "debug/01/raw/debug_out_9.raw", 0

    debug_w_1 db "debug/01/raw/debug_w_1.raw", 0
    debug_w_2 db "debug/01/raw/debug_w_2.raw", 0
    debug_w_3 db "debug/01/raw/debug_w_3.raw", 0
    debug_w_4 db "debug/01/raw/debug_w_4.raw", 0
    debug_w_5 db "debug/01/raw/debug_w_5.raw", 0
    debug_w_6 db "debug/01/raw/debug_w_6.raw", 0
    debug_w_7 db "debug/01/raw/debug_w_7.raw", 0
    debug_w_8 db "debug/01/raw/debug_w_8.raw", 0
    debug_w_9 db "debug/01/raw/debug_w_9.raw", 0

    debug_b_1 db "debug/01/raw/debug_b_1.raw", 0
    debug_b_2 db "debug/01/raw/debug_b_2.raw", 0
    debug_b_3 db "debug/01/raw/debug_b_3.raw", 0
    debug_b_4 db "debug/01/raw/debug_b_4.raw", 0
    debug_b_5 db "debug/01/raw/debug_b_5.raw", 0
    debug_b_6 db "debug/01/raw/debug_b_6.raw", 0
    debug_b_7 db "debug/01/raw/debug_b_7.raw", 0
    debug_b_8 db "debug/01/raw/debug_b_8.raw", 0
    debug_b_9 db "debug/01/raw/debug_b_9.raw", 0

    debug_d_out_1 db "debug/01/raw/debug_d_out_1.raw", 0
    debug_d_out_2 db "debug/01/raw/debug_d_out_2.raw", 0
    debug_d_out_3 db "debug/01/raw/debug_d_out_3.raw", 0
    debug_d_out_4 db "debug/01/raw/debug_d_out_4.raw", 0
    debug_d_out_5 db "debug/01/raw/debug_d_out_5.raw", 0
    debug_d_out_6 db "debug/01/raw/debug_d_out_6.raw", 0
    debug_d_out_7 db "debug/01/raw/debug_d_out_7.raw", 0
    debug_d_out_8 db "debug/01/raw/debug_d_out_8.raw", 0
    debug_d_out_9 db "debug/01/raw/debug_d_out_9.raw", 0

    debug_d_w_1 db "debug/01/raw/debug_d_w_1.raw", 0
    debug_d_w_2 db "debug/01/raw/debug_d_w_2.raw", 0
    debug_d_w_3 db "debug/01/raw/debug_d_w_3.raw", 0
    debug_d_w_4 db "debug/01/raw/debug_d_w_4.raw", 0
    debug_d_w_5 db "debug/01/raw/debug_d_w_5.raw", 0
    debug_d_w_6 db "debug/01/raw/debug_d_w_6.raw", 0
    debug_d_w_7 db "debug/01/raw/debug_d_w_7.raw", 0
    debug_d_w_8 db "debug/01/raw/debug_d_w_8.raw", 0
    debug_d_w_9 db "debug/01/raw/debug_d_w_9.raw", 0

    debug_d_b_1 db "debug/01/raw/debug_d_b_1.raw", 0
    debug_d_b_2 db "debug/01/raw/debug_d_b_2.raw", 0
    debug_d_b_3 db "debug/01/raw/debug_d_b_3.raw", 0
    debug_d_b_4 db "debug/01/raw/debug_d_b_4.raw", 0
    debug_d_b_5 db "debug/01/raw/debug_d_b_5.raw", 0
    debug_d_b_6 db "debug/01/raw/debug_d_b_6.raw", 0
    debug_d_b_7 db "debug/01/raw/debug_d_b_7.raw", 0
    debug_d_b_8 db "debug/01/raw/debug_d_b_8.raw", 0
    debug_d_b_9 db "debug/01/raw/debug_d_b_9.raw", 0

    debug_new_w_1 db "debug/01/raw/debug_new_w_1.raw", 0
    debug_new_w_2 db "debug/01/raw/debug_new_w_2.raw", 0
    debug_new_w_3 db "debug/01/raw/debug_new_w_3.raw", 0
    debug_new_w_4 db "debug/01/raw/debug_new_w_4.raw", 0
    debug_new_w_5 db "debug/01/raw/debug_new_w_5.raw", 0
    debug_new_w_6 db "debug/01/raw/debug_new_w_6.raw", 0
    debug_new_w_7 db "debug/01/raw/debug_new_w_7.raw", 0
    debug_new_w_8 db "debug/01/raw/debug_new_w_8.raw", 0
    debug_new_w_9 db "debug/01/raw/debug_new_w_9.raw", 0

    debug_new_b_1 db "debug/01/raw/debug_new_b_1.raw", 0
    debug_new_b_2 db "debug/01/raw/debug_new_b_2.raw", 0
    debug_new_b_3 db "debug/01/raw/debug_new_b_3.raw", 0
    debug_new_b_4 db "debug/01/raw/debug_new_b_4.raw", 0
    debug_new_b_5 db "debug/01/raw/debug_new_b_5.raw", 0
    debug_new_b_6 db "debug/01/raw/debug_new_b_6.raw", 0
    debug_new_b_7 db "debug/01/raw/debug_new_b_7.raw", 0
    debug_new_b_8 db "debug/01/raw/debug_new_b_8.raw", 0
    debug_new_b_9 db "debug/01/raw/debug_new_b_9.raw", 0
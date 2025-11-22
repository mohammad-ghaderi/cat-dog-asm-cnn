global initialize_parameters

extern conv1_w, conv2_w, conv3_w
extern conv1_b, conv2_b, conv3_b
extern fc1_w, fc1_b, fc2_w, fc2_b

section .text
initialize_parameters:
    mov rax, 2                  ; sys open
    lea rdi, [rel parameters_file]
    mov rsi, 0
    syscall

    mov r12, rax                ; save fd

    ; read conv1_w
    mov rax, 0                  ; sys read
    mov rdi, r12                ; fd
    mov rdx, 3*3*3*32*4         ; bytes to read
    lea rsi, [rel conv1_w]
    syscall

    ; read conv2_w
    mov rax, 0
    mov rdi, r12
    mov rdx, 3*3*32*64*4
    lea rsi, [rel conv2_w]
    syscall

    ; read conv3_w
    mov rax, 0
    mov rdi, r12
    mov rdx, 3*3*64*128*4
    lea rsi, [rel conv3_w]
    syscall

    ; read conv1_b
    mov rax, 0
    mov rdi, r12
    mov rdx, 32*4
    lea rsi, [rel conv1_b]
    syscall

    ; read conv2_b
    mov rax, 0
    mov rdi, r12
    mov rdx, 64*4
    lea rsi, [rel conv2_b]
    syscall

    ; read conv3_b
    mov rax, 0
    mov rdi, r12
    mov rdx, 128*4
    lea rsi, [rel conv3_b]
    syscall

    ; read fc1_w
    mov rax, 0
    mov rdi, r12
    mov rdx, 128*16*16*128*4
    lea rsi, [rel fc1_w]
    syscall

    ; read fc1_b
    mov rax, 0
    mov rdi, r12
    mov rdx, 128*4
    lea rsi, [rel fc1_b]
    syscall

    ; read fc2_w
    mov rax, 0
    mov rdi, r12
    mov rdx, 128*4
    lea rsi, [rel fc2_w]
    syscall

    ; read fc2_b
    mov rax, 0
    mov rdi, r12
    mov rdx, 1*4
    lea rsi, [rel fc2_b]
    syscall

    ;close
    mov rax, 3      ; sys close
    mov rdi, r12
    syscall
    mov rdi, r13
    syscall

    ret

section .data
parameters_file db "parameters/parameters.raw",0
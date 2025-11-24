global write_floats

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
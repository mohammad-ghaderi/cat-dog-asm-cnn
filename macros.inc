%macro CALL_WRITE_FLOATS_FILE 3
    extern write_floats
    ; %1 = pointer to array  (label or register)
    ; %2 = count            (integer or register)
    ; %3 = pointer to filename (label or register)

    push rdi
    push rsi
    push rdx

    mov  rdi, %1
    mov  rsi, %2
    lea rdx, [ rel %3]
    call write_floats

    pop rdx
    pop rsi
    pop rdi
%endmacro

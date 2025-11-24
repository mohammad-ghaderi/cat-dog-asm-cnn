%macro CALL_WRITE_FLOATS_FILE 2
    ; %1 = pointer to array  (label or register)
    ; %2 = count            (integer or register)

    push rdi
    push rsi

    mov  rdi, %1
    mov  rsi, %2
    call write_floats

    pop rsi
    pop rdi
%endmacro

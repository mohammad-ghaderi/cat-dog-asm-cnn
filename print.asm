; from last project (make it 6 digit) https://github.com/mohammad-ghaderi/mnist-asm-nn/blob/main/print.asm
section .data
    newline db 10
    epoch_text db "Epoch: ", 0
    accuracy_text db "Accuracy is: ", 0
    scale dq 1000000.0       ; for 6 decimal digits

section .bss
    buffer resb 64
    epoch_buffer resb 16

section .text
global print_double, print_epoch, print_accuracy

print_double:
    push rbp
    mov rbp, rsp
    
    ; Store xmm0 value
    movsd [rsp-8], xmm0
    sub rsp, 8
    
    ; Convert the double to string
    mov rdi, buffer
    movsd xmm0, [rsp]
    call double_to_string
    
    ; Print the string
    mov rsi, buffer
    call string_length      ; returns length in rax
    mov rdx, rax            ; length in rdx
    mov rax, 1              ; sys_write
    mov rdi, 1              ; stdout  
    syscall
    
    ; Print newline
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall
    
    add rsp, 8
    pop rbp
    ret
    

; Print epoch number with text
; r14 = epoch number (integer)
print_epoch:
    push rbp
    mov rbp, rsp
    push r14                ; save epoch number
    
    ; Print "Epoch: " text
    mov rax, 1              ; sys_write
    mov rdi, 1              ; stdout
    mov rsi, epoch_text     ; "Epoch: "
    mov rdx, 7              ; length of "Epoch: "
    syscall
    
    ; Convert epoch number to string
    pop rax                 ; restore epoch number
    mov rdi, epoch_buffer
    call int_to_string
    
    ; Print epoch number
    mov rsi, epoch_buffer
    call string_length      ; returns length in rax
    mov rdx, rax            ; length in rdx
    mov rax, 1              ; sys_write
    mov rdi, 1              ; stdout  
    syscall
    
    ; Print newline
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall
    
    pop rbp
    ret

; the value is in xmm0
print_accuracy:
    push rbp
    
    sub rsp, 8           ; allocate 8 bytes for double
    movsd [rsp], xmm0    ; store xmm0

    mov rbp, rsp

    ; compute string length
    lea rsi, [rel accuracy_text]
    xor rax, rax
.count:
    cmp byte [rsi + rax], 0
    je .len_done
    inc rax
    jmp .count
.len_done:

    ; write to stdout
    mov rdx, rax        ; length
    mov rsi, accuracy_text
    mov rax, 1          ; sys_write
    mov rdi, 1          ; stdout
    syscall
    
    movsd xmm0, [rsp]    ; restore xmm0
    add rsp, 8

    call print_double

    pop rbp
    ret

; Convert double in xmm0 to string in rdi
double_to_string:
    push rbp
    mov rbp, rsp
    
    ; Check if negative
    pxor xmm1, xmm1
    comisd xmm0, xmm1
    jae .not_negative
    mov byte [rdi], '-'
    inc rdi
    ; Make positive
    subsd xmm1, xmm0
    movsd xmm0, xmm1
.not_negative:
    
    ; Get integer part
    cvttsd2si rax, xmm0
    push rax                 ; save integer part
    
    ; Convert integer part to string
    call int_to_string
    
    ; Add decimal point
    mov byte [rdi], '.'
    inc rdi
    
    ; (original - integer) * 1000000
    cvtsi2sd xmm1, qword [rsp]  ; load integer as double
    movsd xmm2, xmm0
    subsd xmm2, xmm1            ; fractional part
    mulsd xmm2, [scale]
    cvttsd2si rax, xmm2         ; fractional part as integer
    
    ; Convert fractional part (6 digits)
    mov rcx, 6
.frac_loop:
    mov rbx, 10
    xor rdx, rdx
    div rbx                 ; rax = quotient, rdx = remainder
    add dl, '0'
    mov [rdi + rcx - 1], dl
    loop .frac_loop

    add rdi, 6
    mov byte [rdi], 0       ; null terminate
    
    pop rax                 ; clean stack
    pop rbp
    ret

int_to_string:
    push rbx
    push rcx
    push rdx
    
    mov rbx, 10
    test rax, rax
    jnz .not_zero
    ; Handle zero case
    mov byte [rdi], '0'
    inc rdi
    jmp .done
    
.not_zero:
    ; Count digits by pushing to stack
    mov rcx, 0
.digit_loop:
    xor rdx, rdx
    div rbx         ; divides rax by 10, quotient in rax, remainder in rdx
    add dl, '0'
    push rdx
    inc rcx
    test rax, rax
    jnz .digit_loop
    
    ; Pop digits into buffer
.pop_loop:
    pop rax
    mov [rdi], al
    inc rdi
    loop .pop_loop
    
.done:
    mov byte [rdi], 0    ; NULL-terminate the string
    pop rdx
    pop rcx
    pop rbx
    ret

; Get length of null-terminated string in rsi
string_length:
    xor rax, rax
.count:
    cmp byte [rsi + rax], 0
    je .done
    inc rax
    jmp .count
.done:
    ret

default rel
global compute_loss

extern logf

; xmm0 = y
; xmm1 = pred
; returns -> xmm0 = loss
compute_loss:
    movss xmm4, xmm0
    movss xmm5, xmm1

    ; term1 = y * log(pred + eps)
    movss xmm0, xmm5        ; xmm0 = pred
    addss xmm0, [eps]       ; pred + eps
    
    sub rsp, 32
    movups [rsp],     xmm4
    movups [rsp + 16], xmm5

    call logf               ; xmm0 = log(pred + eps)

    movups xmm4, [rsp]
    movups xmm5, [rsp + 16]
    add rsp, 32    
    
    mulss xmm0, xmm4        ; xmm0 = y * log(pred+eps)
    movss xmm6, xmm0        ; store term1 in xmm6

    ; term2 = (1-y) * log(1-pred + eps)
    movss xmm0, [one]       ; xmm0 = 1.0
    subss xmm0, xmm5        ; xmm0 = 1 - pred
    addss xmm0, [eps]       ; xmm0 = 1 - pred + eps

    sub rsp, 32
    movups [rsp],     xmm4
    movups [rsp + 16], xmm6

    call logf               ; xmm0 = log(1-pred+eps)

    movups xmm4, [rsp]
    movups xmm6, [rsp + 16]
    add rsp, 32 

    movss xmm1, [one]       ; 1
    subss xmm1, xmm4        ; xmm1 = 1 - y
    mulss xmm0, xmm1        ; xmm0 = (1-y)*log(...)

    ; loss = -(term1 + term2)
    addss xmm0, xmm6        ; term1 + term2
    xorps xmm1, xmm1        ; xmm1 = 0
    subss xmm1, xmm0        ; xmm1 = -(term1 + term2)

    movaps xmm0, xmm1       ; return value in xmm0
    ret

section .data
    eps:        dd 1.0e-7
    one:        dd 1.0

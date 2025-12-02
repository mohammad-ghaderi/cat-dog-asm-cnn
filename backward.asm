global backward_pass
extern label, output

backward_pass:
    movss xmm0, [output]
    movzx eax, byte [label]
    cvtsi2ss xmm1, eax

    subss xmm0, xmm1    ; grad = pred - y
    

    ret
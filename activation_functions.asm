global relu
global sigmoid



; xmm0 = input
; output = max(0, xmm0)
relu:
    xorps xmm1, xmm1       ; xmm1 = 0
    maxss xmm0, xmm1
    ret


sigmoid:

    ret
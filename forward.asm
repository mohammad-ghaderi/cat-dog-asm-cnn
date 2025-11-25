global forward_path

extern conv1_3x3

section .text

forward_path:

    call conv1_3x3

    ret
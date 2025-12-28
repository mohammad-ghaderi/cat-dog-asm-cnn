global debug_input, debug_input_padd, debug_out_1, debug_out_2, debug_out_3, debug_out_4, debug_out_5, debug_out_6, debug_out_7, debug_out_8, debug_out_9, debug_w_1, debug_w_2, debug_w_3, debug_w_4, debug_w_5, debug_w_6, debug_w_7, debug_w_8, debug_w_9, debug_b_1, debug_b_2, debug_b_3, debug_b_4, debug_b_5, debug_b_6, debug_b_7, debug_b_8, debug_b_9, debug_d_out_1, debug_d_out_2, debug_d_out_3, debug_d_out_4, debug_d_out_5, debug_d_out_6, debug_d_out_7, debug_d_out_8, debug_d_out_9, debug_d_w_1, debug_d_w_2, debug_d_w_3, debug_d_w_4, debug_d_w_5, debug_d_w_6, debug_d_w_7, debug_d_w_8, debug_d_w_9, debug_d_b_1, debug_d_b_2, debug_d_b_3, debug_d_b_4, debug_d_b_5, debug_d_b_6, debug_d_b_7, debug_d_b_8, debug_d_b_9, debug_new_w_1, debug_new_w_2, debug_new_w_3, debug_new_w_4, debug_new_w_5, debug_new_w_6, debug_new_w_7, debug_new_w_8, debug_new_w_9, debug_new_b_1, debug_new_b_2, debug_new_b_3, debug_new_b_4, debug_new_b_5, debug_new_b_6, debug_new_b_7, debug_new_b_8, debug_new_b_9
global COUNT
COUNT equ 7

section .data
    debug_input db "debug/07/raw/debug_input.raw", 0

    debug_input_padd db "debug/07/raw/debug_input_padd.raw", 0
    debug_out_1 db "debug/07/raw/debug_out_1.raw", 0
    debug_out_2 db "debug/07/raw/debug_out_2.raw", 0
    debug_out_3 db "debug/07/raw/debug_out_3.raw", 0
    debug_out_4 db "debug/07/raw/debug_out_4.raw", 0
    debug_out_5 db "debug/07/raw/debug_out_5.raw", 0
    debug_out_6 db "debug/07/raw/debug_out_6.raw", 0
    debug_out_7 db "debug/07/raw/debug_out_7.raw", 0
    debug_out_8 db "debug/07/raw/debug_out_8.raw", 0
    debug_out_9 db "debug/07/raw/debug_out_9.raw", 0

    debug_w_1 db "debug/07/raw/debug_w_1.raw", 0
    debug_w_2 db "debug/07/raw/debug_w_2.raw", 0
    debug_w_3 db "debug/07/raw/debug_w_3.raw", 0
    debug_w_4 db "debug/07/raw/debug_w_4.raw", 0
    debug_w_5 db "debug/07/raw/debug_w_5.raw", 0
    debug_w_6 db "debug/07/raw/debug_w_6.raw", 0
    debug_w_7 db "debug/07/raw/debug_w_7.raw", 0
    debug_w_8 db "debug/07/raw/debug_w_8.raw", 0
    debug_w_9 db "debug/07/raw/debug_w_9.raw", 0

    debug_b_1 db "debug/07/raw/debug_b_1.raw", 0
    debug_b_2 db "debug/07/raw/debug_b_2.raw", 0
    debug_b_3 db "debug/07/raw/debug_b_3.raw", 0
    debug_b_4 db "debug/07/raw/debug_b_4.raw", 0
    debug_b_5 db "debug/07/raw/debug_b_5.raw", 0
    debug_b_6 db "debug/07/raw/debug_b_6.raw", 0
    debug_b_7 db "debug/07/raw/debug_b_7.raw", 0
    debug_b_8 db "debug/07/raw/debug_b_8.raw", 0
    debug_b_9 db "debug/07/raw/debug_b_9.raw", 0

    debug_d_out_1 db "debug/07/raw/debug_d_out_1.raw", 0
    debug_d_out_2 db "debug/07/raw/debug_d_out_2.raw", 0
    debug_d_out_3 db "debug/07/raw/debug_d_out_3.raw", 0
    debug_d_out_4 db "debug/07/raw/debug_d_out_4.raw", 0
    debug_d_out_5 db "debug/07/raw/debug_d_out_5.raw", 0
    debug_d_out_6 db "debug/07/raw/debug_d_out_6.raw", 0
    debug_d_out_7 db "debug/07/raw/debug_d_out_7.raw", 0
    debug_d_out_8 db "debug/07/raw/debug_d_out_8.raw", 0
    debug_d_out_9 db "debug/07/raw/debug_d_out_9.raw", 0

    debug_d_w_1 db "debug/07/raw/debug_d_w_1.raw", 0
    debug_d_w_2 db "debug/07/raw/debug_d_w_2.raw", 0
    debug_d_w_3 db "debug/07/raw/debug_d_w_3.raw", 0
    debug_d_w_4 db "debug/07/raw/debug_d_w_4.raw", 0
    debug_d_w_5 db "debug/07/raw/debug_d_w_5.raw", 0
    debug_d_w_6 db "debug/07/raw/debug_d_w_6.raw", 0
    debug_d_w_7 db "debug/07/raw/debug_d_w_7.raw", 0
    debug_d_w_8 db "debug/07/raw/debug_d_w_8.raw", 0
    debug_d_w_9 db "debug/07/raw/debug_d_w_9.raw", 0

    debug_d_b_1 db "debug/07/raw/debug_d_b_1.raw", 0
    debug_d_b_2 db "debug/07/raw/debug_d_b_2.raw", 0
    debug_d_b_3 db "debug/07/raw/debug_d_b_3.raw", 0
    debug_d_b_4 db "debug/07/raw/debug_d_b_4.raw", 0
    debug_d_b_5 db "debug/07/raw/debug_d_b_5.raw", 0
    debug_d_b_6 db "debug/07/raw/debug_d_b_6.raw", 0
    debug_d_b_7 db "debug/07/raw/debug_d_b_7.raw", 0
    debug_d_b_8 db "debug/07/raw/debug_d_b_8.raw", 0
    debug_d_b_9 db "debug/07/raw/debug_d_b_9.raw", 0

    debug_new_w_1 db "debug/07/raw/debug_new_w_1.raw", 0
    debug_new_w_2 db "debug/07/raw/debug_new_w_2.raw", 0
    debug_new_w_3 db "debug/07/raw/debug_new_w_3.raw", 0
    debug_new_w_4 db "debug/07/raw/debug_new_w_4.raw", 0
    debug_new_w_5 db "debug/07/raw/debug_new_w_5.raw", 0
    debug_new_w_6 db "debug/07/raw/debug_new_w_6.raw", 0
    debug_new_w_7 db "debug/07/raw/debug_new_w_7.raw", 0
    debug_new_w_8 db "debug/07/raw/debug_new_w_8.raw", 0
    debug_new_w_9 db "debug/07/raw/debug_new_w_9.raw", 0

    debug_new_b_1 db "debug/07/raw/debug_new_b_1.raw", 0
    debug_new_b_2 db "debug/07/raw/debug_new_b_2.raw", 0
    debug_new_b_3 db "debug/07/raw/debug_new_b_3.raw", 0
    debug_new_b_4 db "debug/07/raw/debug_new_b_4.raw", 0
    debug_new_b_5 db "debug/07/raw/debug_new_b_5.raw", 0
    debug_new_b_6 db "debug/07/raw/debug_new_b_6.raw", 0
    debug_new_b_7 db "debug/07/raw/debug_new_b_7.raw", 0
    debug_new_b_8 db "debug/07/raw/debug_new_b_8.raw", 0
    debug_new_b_9 db "debug/07/raw/debug_new_b_9.raw", 0

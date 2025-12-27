global conv1_w, conv2_w, conv3_w
global conv1_b, conv2_b, conv3_b
global input, label
global conv1_out, pool1_out, conv2_out
global pool2_out, conv3_out, pool3_out, fc1_out
global output, fc1_w, fc1_b, fc2_w, fc2_b
global pool1_argmax, pool2_argmax, pool3_argmax
global d_fc2_out, d_fc2_w, d_fc2_b, d_fc1_out, d_fc1_w, d_fc1_b
global d_pool3, d_conv3_out, d_conv3_w, d_conv3_b
global d_pool2, d_conv2_out, d_conv2_w, d_conv2_b
global d_pool1, d_conv1_out, d_conv1_w, d_conv1_b
global d_input_not_needed
global losses

global BATCH_SIZE, EPOCHS, BATCHES_PER_EPOCH
  

BATCH_SIZE equ 32            ; Batch size              
EPOCHS equ 10
TOTAL_SAMPLES equ (19998 / BATCH_SIZE) * BATCH_SIZE
BATCHES_PER_EPOCH equ TOTAL_SAMPLES / BATCH_SIZE  ; 624 batches


section .rodata
global BATCH_SIZE_INV
BATCH_SIZE_INV dd 0.03125    ; 1/32


section .bss
losses resd BATCH_SIZE      ; store per sample losses


conv1_w resd 3*3*3*32
conv2_w resd 3*3*32*64
conv3_w resd 3*3*64*128

conv1_b resd 32
conv2_b resd 64
conv3_b resd 128

input resd 3*130*130  
label resb 1

conv1_out resd 32*128*128
pool1_out resd 32*66*66  
pool1_argmax resw 32*66*66

conv2_out resd 64*64*64  
pool2_out resd 64*34*34  
pool2_argmax resw 64*34*34

conv3_out resd 128*32*32 
pool3_out resd 128*16*16 
pool3_argmax resw 128*16*16 

fc1_out resd 128         
output resd  1

fc1_w resd 128*16*16*128         
fc1_b resd 128         

fc2_w resd 128
fc2_b resd 1

; Gradient Vars
d_fc2_out resd 1
d_fc2_w resd 128
d_fc2_b resd 1

d_fc1_out resd 128
d_fc1_w resd 128*16*16*128
d_fc1_b resd 128

d_pool3 resd 128*16*16
d_conv3_out resd 128*32*32
d_conv3_w resd 3*3*64*128
d_conv3_b resd 128

d_pool2 resd 64*34*34
d_conv2_out resd 64*64*64 
d_conv2_w resd 3*3*32*64
d_conv2_b resd 64

d_pool1 resd 32*66*66 
d_conv1_out resd 32*128*128
d_conv1_w resd 3*3*3*32
d_conv1_b resd 32

d_input_not_needed resd 3*130*130
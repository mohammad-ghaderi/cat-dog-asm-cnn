global conv1_w, conv2_w, conv3_w
global conv1_b, conv2_b, conv3_b
global input, label
global conv1_out, pool1_out, conv2_out
global pool2_out, conv3_out, pool3_out, fc1_out
global output, fc1_w, fc1_b, fc2_w, fc2_b
global B

B equ 32        ; Batch size     

section .bss

conv1_w resd 3*3*3*32
conv2_w resd 3*3*32*64
conv3_w resd 3*3*64*128

conv1_b resd 32
conv2_b resd 64
conv3_b resd 128

input resd B*3*128*128  
label resb B

conv1_out resd B*32*128*128
pool1_out resd B*32*64*64  

conv2_out resd B*64*64*64  
pool2_out resd B*64*32*32  

conv3_out resd B*128*32*32 
pool3_out resd B*128*16*16 

fc1_out resd B*128         
output resd  B

fc1_w resd 128*16*16*128         
fc1_b resd 128         

fc2_w resd 128
fc2_b resd 1


s1: DC "What is your name?\0"
c1: DC "Hello "

ld x29, c1(x0)
addi x28, x0, s1
ecall x0, x28, 4 ;info string
ecall x6, x0, 8

ecall x1, x29, 3 #prints Hello
ecall x0, x6, 3  #prints raj


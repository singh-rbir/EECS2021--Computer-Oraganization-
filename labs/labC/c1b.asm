c: DD 0x1000000000000001
ld x5, c(x0)
addi x6, x0, 16
mulh x7, x5, x6	;upper 64 bits
mul x8, x5, x6	;lower 64
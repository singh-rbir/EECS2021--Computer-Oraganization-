ORG	0x80808
st: DM  10 ;storage for the entered integers
ORG 	0
s0: DC	"Int:\0"
;Write your code below

#loading the value of st in a register
b20: EQU (st >> 12)
b12: EQU (st & 0xfff)
lui x6, b20
addi x6, x6, b12

add x29, x0, x0

loop:	ld x28, s0(x0)
	ecall x7, x28, 5	;prints Int, inputs Int, x7 stores it
	sd x7, 0(x6)
	addi x6, x6, 8 ;iterating memory
	add x10, x10, x7 ;storing sum
	
	bne x29, x0, skip	;checks to see if its the first iteration of loop
first:	add x11, x0, x7
	addi x29, x0, 1
skip:	blt x11, x7, next 
	add x11, x0, x7	;x7 < x11, so x11 stores the smallest
next:	bge x7, x0, skip2
	addi x12, x12, 1	;if it's negative, add 1 to x12
skip2:	bne x7, x0, loop



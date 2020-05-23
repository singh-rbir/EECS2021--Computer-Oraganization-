s0: DC "Find all divisors"
s1: DC "Enter i: "
s2: DC "Divisors:\0"

addi x5, x0, s0
ecall x1, x5, 4	;out info
addi x5, x0, s1
ecall x1, x5, 4	;out info
ecall x6, x0, 5	;input n, x6 stores n
addi x5, x0, s2
ecall x0, x5, 4

addi x7, x0, 1	;x7 stores the val 1
loop:	rem x8, x6, x7
	bne  x8, x0, dontprint
	ecall x0, x8, 0
dontprint:	
	addi x7, x7, 1
	bne x7, x0, loop

ecall x1, x6, 0




	

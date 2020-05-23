s0: DC "sum(1..n-1) Enter n:"
s1: DC "sum(1.."
s2: DC ")="
s3: DC "(n*(n-1))/2="


addi x5, x0, s0
ecall x1, x5, 4	;out info
ecall x6, x0, 5	;input n 
addi x5, x0, s1 
ecall x1, x5, 4
ecall x1, x6, 0
addi x5, x0, s2
ecall x1, x5, 4

addi x6, x6, -1
addi x7, x6, -1	;x7 stores 1 value less than the integer
loop:	add x6, x7, x6
	addi x7, x7, -1
	bne x7, x0, loop

ecall x1, x6, 0




	

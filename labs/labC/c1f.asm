s0: DC "FACTORIAL"
s1: DC "Enter a small +ve integer: "
s2: DC "! = "


addi x5, x0, s0
ecall x0, x5, 4	;out info
addi x5, x0, s1 
loop:	ecall x1, x5, 4	;prompt a
	ecall x6, x0, 5	;input a
	blt x6, x0, loop
ecall x1, x6, 0	;out integer
addi x5, x0, s2
ecall x1, x5, 4	;out !=

addi x31, x0, 1	;temporarily stores the value 1
addi x7, x6, -1	;x7 stores 1 value less than the integer
loop2:	mul x6, x7, x6
	addi x7, x7, -1
	bne x7, x31, loop2

ecall x1, x6, 0




	

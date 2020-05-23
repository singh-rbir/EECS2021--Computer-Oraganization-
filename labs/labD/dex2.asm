#the following program is not complete because not enough time
#was available, but it is found that it can be done. By tokenizing
#the string. The characters of a string are stored in series. 

s1: DC "Enter a string: \0"
s2: DC "Yes, it's a palindrome. \0"
s3: DC "No, it's not palindrome. \0"
STACK: EQU	0x100000

lui sp, STACK >> 12
addi x5, x0, s1
ecall x1, x5, 4	;out question
ecall x28, x0, 8	;inp string
addi x6, x0, 1	;counter
addi x31, x0, 10

loop1:	div x7, x5, x31	;stores the quo only
	div x5, x5, x31
	rem x8, x5, x31
	sd x8, 0(sp)	;pushing rem to stack
	addi sp, sp, -8
	addi x6, x6, 1	;increment the counter
	bne x7, x0, loop1

	addi x30, x0, 1	;new counter, for loop2


loop2: 	addi sp, sp, 8	;pop 
	ld x8, 0(sp)	;pop the stack, store it in x8
	ecall x1, x8, 0	;out the number from the stack
	addi x30, x30, 1	;counter2
	bge x6, x30, loop2




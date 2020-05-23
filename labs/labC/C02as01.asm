;     DD    x1,y1,x2,y2
sg1:  DD    0, 0, 8, 10       ;the 1-st segment
      DD    1, 2, 3, 4
      DD    5, 6, 7, 8
      DD    9, 10, 11, 12
sgn:  DD    0, 0, 100, 80     ;the n-th segment
mp:   EQU   100               ;the max power value
pi2:  DF    1.570796          ;pi/2.0
;----------------------------------------------------
add x31, x0, x0
addi x30, x0, 0	;loop iterator
addi x9, x0, 5	;loop final value
add x5, x0, x0	;initial value of x5, which stores the shortest seg

loop:	ld x6, sg1(x31)	;x6 stores x1
	addi x31, x31, 8
	ld x7, sg1(x31)	;x7 stores y1
	addi x31, x31, 8
	ld x28, sg1(x31);x28 stores x2
	addi x31, x31, 8;
	ld x29, sg1(x31);y29 stores y2
	sub x6, x28, x6	;x6 stores (x2-x1)
	sub x7, x29, x7	;x7 stores (y2-y1)
	mul x6, x6, x6	;x6 stores the square
	mul x7, x7, x7	;x7 stores the square
	add x8, x6, x7	;temp register to store the sum
	bne x5, x0, notfirststep
	add x5, x0, x8	;x5 stores x8 (smallest seg)
notfirststep: bge x8, x5, checkeq ;means x5 is still the smallest
	add x5, x0, x8	;replaces the value in x5 
	addi x10, x31, -24	;subtract to get the address
checkeq:	bne x5, x8, skip ;(not equals) therefore skip
	add x5, x0, x8	;x5 == x8 but still store the 2nd occurence
	addi x10, x31, -24	;subtract to get the address
skip:	blt x30, x9, loop	;iterates the loop

# Register 5 stores the value of the shortest segment


	
	


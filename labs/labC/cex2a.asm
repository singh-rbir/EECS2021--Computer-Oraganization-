v1: DF	1.21, 5.85, -7.3, 23.1, -5.5
v2: DF	3.14, -2.1, 44.2, 11.0, -7.77
c: DF 0.0

fld f4, c(x0)	;initially stores the value 0.0 in f4
addi x5, x0, 5
addi x6, x0, 0
addi x7, x0, 8

loop:	fld f1, v1(x7)
	fld f2, v2(x7)
	fmul.d f3, f2, f1
	fadd.d f4, f4, f3	;keeps adding the prods in f4
	addi x6, x6, 1	;increments the iterator
	addi x7, x7, 8
	blt x6, x5, loop


# this program is almost done, just has a small error in the final result
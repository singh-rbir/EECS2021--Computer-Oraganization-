s1: DC	"Enter x:\0"
s2: DC	"Result:\0"
c0: DF	0.0
a: DF	3.0
b: DF	5.0

fld f0, c0(x0);f0 stores 0.0
fld f1, a(x0)	;f1 stores 3.0
fld f2, b(x0)	;f2 stores 5.0

loop: 	addi x5, x0, s1
	ecall x1, x5, 4	;out info
	ecall f3, x0, 6	;inp x
	flt.d x1, f3, f1
	beq x1, x0, cont	;if f3<f1 is false, goto cont
	fadd.d f3, f0, f2
	beq x0, x0, done
cont: 	fle.d x1, f2, f3
	beq x1, x0, done	;if f2<=f3 is false, goto done
	fadd.d f3, f0, f1
done: 	addi x5, x0, s2
	ecall x1, x5, 4	;out x
	ecall x0, f3, 1	;out f3(res)
	beq x0, x0, loop
	


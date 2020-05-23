# attempted to do this question, but its wrong (re try later)

src: DD -1, 55, -3, 7, 0

add x6, x0, x0

ld x6, src(x0)
loop: ld 	x5, src(x6)
beq x5, x0, end
bge x5, x6, store
store: ld x6, x5
addi x6, x6, 8
beq x0, x0, loop


end: ebreak	 x0, x0, 0
dst: DM 1




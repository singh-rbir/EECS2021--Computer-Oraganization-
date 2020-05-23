a: DD 0xAAAABBBBCCCCDDDD
b: DD 0x4444333322221111
c: DM 1
d: DM 1

lui x6, a >> 12
addi x6, x6, a & 0xfff
ld x6, 0(x6)

lui x7, b >> 12
addi x7, x7, b & 0xfff
ld x7, 0(x7)

add x5, x6, x7
sd x5, c(x0)

sub x5, x7, x6
sd x5, d(x0)










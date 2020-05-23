c: EQU 0x1234567811223344
fh: EQU (c >> 32)
sh: EQU (c & 0xffffffff)

fh12: EQU (fh & 0xfff)
fh20: EQU (fh >> 12)
sh12: EQU (sh & 0xfff)
sh20: EQU (sh >> 12)

lui x6, fh20
addi x6, x6, fh12
slli x6, x6, 32

lui x7, sh20
addi x7, x7, sh12
or x5, x6, x7


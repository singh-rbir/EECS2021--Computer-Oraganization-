m: EQU 0x0123456789ABCDEF

lui x7, 0x89ABC + 1
addi x7, x7, m & 0xfff
slli x7, x7, 32
srli x7, x7, 32

lui x8, m >> 44
addi x8, x8, (m & 0xfff00000000) >> 32
slli x8, x8, 32
add x6, x7, x8

addi x9, x0, 0xff
slli x9, x9, 28
or x6, x6, x9

srli x6, x6, 8
addi x10, x0, 0xef
slli x10, x10, 56
or x6, x6, x10
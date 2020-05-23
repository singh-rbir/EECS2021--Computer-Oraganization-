a: DD 1024
b: DD 2048
c: DD 4096
d: DD 8192

ld x6, a(x0)
ld x7, b(x0)
add x6, x6, x7

ld x7, c(x0)
add x6, x6, x7

ld x7, d(x0)
add x6, x6, x7

srli x5, x6, 2
sd x5, 72(x0)

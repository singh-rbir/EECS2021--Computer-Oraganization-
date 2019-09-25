s0:   DC          "INPUT\n\0"
s1:   DC          "INSERT\0"
s2:   DC          "REMOVE\0"
s3:   DC          "INVERSE\0"
sm1:  DM          2     ;input string
sm2:  DM          2     ;sorted string
      ld          x30, s0(x0)
      addi        x31, x0, sm1
      ecall       x31, x30, 9 ;input a string
      ld          x30, s1(x0)
      ecall       x0, x30, 3 ;print "INSERT\0"
      addi        a0, x0, sm2 ;destination string argument
m1:   lb          a1, 0(x31) ;character to insert argument
      addi        x31, x31, 1
      beq         a1, x0, m2  ;end of the string?
      jal         x1, ins
m2:
      ebreak      x0, x0, 0

ins:  	ecall a3, x0, 8 ;input char to insert
	
	blt a3, a1, loop
	ecall x1, a3, 3	;output inserted char (it should be the first char)
loop:	ecall x1, a1, 3	;output next char
	lb a1, 0(x31)
	blt a3, a1, skip
	ecall x1, a3, 3	;insert the char in between
	add a3, x0, x0	;reset the char to 0, to print the rest of the string
skip:	addi x31, x31, 1	
	blt a3, a1, loop
	
      jalr        x0, 0(x1)

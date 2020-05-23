c1: 	DC "Lt"
c2: 	DC ":"
s1: 	DC "No of letters: "
src: DD 1

ld x28, c1(x0)
ld x29, c2(x0)
addi x30, x0, s1
ecall x0, x30, 4 ;info string 
ecall x6, x0, 5 #stores the no of letters
addi x6, x6, 1	#adds 1 to the no of letter, for the loop
addi x31, x0, 1	#loop iterator, starts from 1, stored in x31

add x5, x0, x0 #remove this line later if mem trick doesn't work

loop:	ecall x7, x28, 3
	ecall x7, x31, 0
	ecall x7, x29, 3	#above 3 statements print Lt1:, Lt2:,...
	ecall x8, x7, 8	#prints the letter
	
	#trying to add the letter to memory---------
	sd x8, dst(x5)
	addi x5, x5, 8
	#----------------------------------
	
	addi x31, x31, 1 #iterates the loop
	bne x31, x6, loop 
#loop ends here----------------

#----retrieves the letters from memory and prints them on same line
ld x30, src(x0) #loop iterator
loop2: 	ld x7, dst(x4)
	ecall x7, x7, 3
	addi x4, x4, 8
	addi x30, x30, 1	#next two lines iterate the loop
	bne x30, x6, loop2
#loop2 ends here

#--- prints the letter backwards


dst: DM	1



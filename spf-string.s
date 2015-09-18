######################################################################
# spf-main.s
# 
# This is the main function that tests the sprintf function

# The "data" segment is a static memory area where we can 
# allocate and initialize memory for our program to use.
# This is separate from the stack or the heap, and the allocation
# cannot be changed once the program starts. The program can
# write data to this area, though.
	.data
	
# Note that the directives in this section will not be 
# translated into machine language. They are instructions 
# to the assembler, linker, and loader to set aside (and 
# initialize) space in the static memory area of the program. 
# The labels work like pointers-- by the time the code is 
# run, they will be replaced with appropriate addresses.

# For this program, we will allocate a buffer to hold the
# result of your sprintf function. The asciiz blocks will
# be initialized with null-terminated ASCII strings.

buffer:	.space	2000			# 2000 bytes of empty space 
					# starting at address 'buffer'
	
format:	.asciiz "string: %5.5s\n%5.5s\n"# null-terminated string of 
					# ascii bytes.  Note that the 
					# \n counts as one byte: a newline 
					# character.
str1:	.asciiz "abcdefg"		# null-terminated string at
					# address 'str1'
str2:   .asciiz "abc" 			# null-terminated string at
                                        # address 'str2'
chrs:	.asciiz " characters:\n"	# null-terminated string at 
					# address 'chrs'

# The "text" of the program is the assembly code that will
# be run. This directive marks the beginning of our program's
# text segment.

	.text
	
# The sprintf procedure (really just a block that starts with the
# label 'sprintf') will be declared later.  This is like a function
# prototype in C.

	.globl sprintf
		
# The special label called "__start" marks the start point
# of execution. Later, the "done" pseudo-instruction will make
# the program terminate properly.	

main:
	addi	$sp,$sp,-20	# reserve stack space

	# $v0 = sprintf(buffer, format, str1, str2)
	
	la	$a0,buffer	# arg 0 <- buffer
	la	$a1,format	# arg 1 <- format
	la	$a2,str1	# arg 2 <- str1
	la 	$a3,str2        # arg 3 <- str2	
	
	sw	$ra,16($sp)	# save return address
	jal	sprintf		# $v0 = sprintf(...)

	# print the return value from sprintf using
	# putint()

	add	$a0,$v0,$0	# $a0 <- $v0
	jal	putint		# putint($a0)

	## output the string 'chrs' then 'buffer' (which
	## holds the output of sprintf)

 	li 	$v0, 4	
	la     	$a0, chrs
	syscall
	#puts	chrs		# output string chrs
	
	li	$v0, 4
	la	$a0, buffer
	syscall
	#puts	buffer		# output string buffer
	
	addi	$sp,$sp,20	# restore stack
	li 	$v0, 10		# terminate program
	syscall

# putint writes the number in $a0 to the console
# in decimal. It uses the special command
# putc to do the output.
	
# Note that putint, which is recursive, uses an abbreviated
# stack. putint was written very carefully to make sure it
# did not disturb the stack of any other functions. Fortunately,
# putint only calls itself and putc, so it is easy to prove
# that the optimization is safe. Still, we do not recommend 
# taking shortcuts like the ones used here.

# HINT:	You should read and understand the body of putint,
# because you will be doing some similar conversions
# in your own code.
	
putint:	addi	$sp,$sp,-8	# get 2 words of stack
	sw	$ra,0($sp)	# store return address
	
	# The number is printed as follows:
	# It is successively divided by the base (10) and the 
	# reminders are printed in the reverse order they were found
	# using recursion.

	remu	$t0,$a0,10	# $t0 <- $a0 % 10
	addi	$t0,$t0,'0'	# $t0 += '0' ($t0 is now a digit character)
	divu	$a0,$a0,10	# $a0 /= 10
	beqz	$a0,onedig	# if( $a0 != 0 ) { 
	sw	$t0,4($sp)	#   save $t0 on our stack
	jal	putint		#   putint() (putint will deliberately use and modify $a0)
	lw	$t0,4($sp)	#   restore $t0
	                        # } 
onedig:	move	$a0, $t0
	li 	$v0, 11
	syscall			# putc #$t0
	#putc	$t0		# output the digit character $t0
	lw	$ra,0($sp)	# restore return address
	addi	$sp,$sp, 8	# restore stack
	jr	$ra		# return
	
#sprintf!
#$a0 has the pointer to the buffer to be printed to
#$a1 has the pointer to the format string
#$a2 and $a3 have (possibly) the first two substitutions for the format string
#the rest are on the stack
#return the number of characters (ommitting the trailing '\0') put in the buffer

        .text

sprintf:move	$t0, $a1
	move	$t2, $a0
	li	$s0, 0
loop:	lb	$t1, 0($t0)
	beq	$t1, '%', perce
	beq	$t1, '\0', end
	sb	$t1, 0($t2)
	addi	$t0, $t0, 1
	addi	$t2, $t2, 1
	add	$s0, $s0, 1
	j	loop	
	
perce:	addi	$s1, $s1, 1
	bgt	$s1, 2, stack
	beq	$s1, 2, a3
	move	$t3, $a2
	j	perchk
a3:	move	$t3, $a3
perchk:	lb	$t4, 1($t0)
	beq	$t4, '.', period
	beq	$t4, '0', number 
	beq	$t4, '1', number 
	beq	$t4, '2', number
	beq	$t4, '3', number
	beq	$t4, '4', number
	beq	$t4, '5', number
	beq	$t4, '6', number
	beq	$t4, '7', number
	beq	$t4, '8', number
	beq	$t4, '9', number
	beq	$t4, '-', dpl
	beq	$t4, '+', dpl
	beq	$t4, 's', string
	beq	$t4, 'u', uns
	beq	$t4, 'o', oct
	beq	$t4, 'x', hex
	beq	$t4, 'd', dec
	
number:	addi	$t0, $t0, 1
	lb	$s3, 0($t0)
	sub	$s3, $s3, 48
	j	perchk
	
period:	addi	$t0, $t0, 1
	lb	$s4, 1($t0)
	addi	$t0, $t0, 1
	sub	$s4, $s4, 48
	sub	$s3, $s3, 48
	j	perchk

dpl:	move	$s6, $t4
	addi	$t0, $t0, 1
	j	perchk
	
	
stack:	move	$t5, $s1
	move	$t6, $sp
	subi	$t5, $t5, 3
	mul	$t5, $t5, 4
	add	$t6, $t6, $t5
	lw	$t3, 16($t6)
	j	perchk


#strle:	lb	$t5, 0($t3)
#	beq	$t5, '\0', strlend
#	beq	$s5, $s4, strlend
#	sb	$t5, 0($t2)
#	add	$t3, $t3, 1
#	add	$t2, $t2, 1
#	add	$s0, $s0, 1
#	add	$s5, $s5, 1
#	j	strle
#strlend:li	$s5, 0
#	j	loop
	
	
frontspac:move	$t7, $t3
	li	$s7, 0
lopers:	lb	$t8, 0($t7)
	addi	$s7, $s7, 1
	addi	$t7, $t7, 1
	bne	$t8, '\0', lopers
	bgt	$s7, $s3, streng
	sub	$s7, $s3, $s7
counts:	li	$s5, 0
	li	$t4, ' '
	sb	$t4, 0($t2)
	addi	$t2, $t2, 1
	addi	$s0, $s0, 1
	sub	$s3, $s3, 1
	sub	$s7, $s7, 1
	bne	$s7, 0, counts
	j	streng
	
string:	bne	$s3, 0, frontspac
	bne	$s4, 0, streng
	li	$s4, -1
streng:	lb	$t5, 0($t3)
	beq	$t5, '\0', strend
	beq	$t8, $s4, strend
	sb	$t5, 0($t2)
	add	$t3, $t3, 1
	add	$t2, $t2, 1
	add	$t8, $t8, 1
	add	$s0, $s0, 1
	j 	streng
strend:	blt	$t8, $s3, strlspa
	add	$t0, $t0, 2
	#add	$s0,$s0,1
	j 	loop
	
strlspa:li	$t4, ' '
	sb	$t4, 0($t2)
	addi	$t2, $t2, 1
	addi	$t8, $t8, 1
	addi	$s0, $s0, 1
	j	strend
	
uns:	addi	$sp,$sp,-4
	sw	$ra,0($sp)
	jal	unsstr
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	j	unsend

unsstr:	addi	$sp,$sp,-8
	sw	$ra,0($sp)
	remu	$t4,$t3,10	# $t0 <- $a0 % 10
	addi	$t4,$t4,'0'	# $t0 += '0' ($t0 is now a digit character)
	divu	$t3,$t3,10	# $a0 /= 10
	beqz	$t3,oneu	# if( $a0 != 0 ) { 
	sw	$t4,4($sp)	#   save $t0 on our stack
	jal	unsstr		#   putint() (putint will deliberately use and modify $a0)
	lw	$t4,4($sp)	#   restore $t0
	                        # } 
oneu:	sb	$t4, 0($t2)
	add	$s0, $s0, 1
	addi	$t2, $t2, 1	# output the digit character $t0
	lw	$ra,0($sp)	# restore return address
	addi	$sp,$sp, 8	# restore stack
	jr	$ra
	
unsend: addi	$t0, $t0, 2
	j 	loop

		
	
oct:	addi	$sp,$sp,-4
	sw	$ra,0($sp)
	jal	octstr
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	j	octend

octstr:	addi	$sp,$sp,-8
	sw	$ra,0($sp)
	remu	$t4,$t3,8	# $t0 <- $a0 % 10
	addi	$t4,$t4,'0'	# $t0 += '0' ($t0 is now a digit character)
	divu	$t3,$t3,8	# $a0 /= 10
	beqz	$t3,oneo		# if( $a0 != 0 ) { 
	sw	$t4,4($sp)	#   save $t0 on our stack
	jal	octstr		#   putint() (putint will deliberately use and modify $a0)
	lw	$t4,4($sp)	#   restore $t0
	                        # } 
oneo:	sb	$t4, 0($t2)
	add	$s0, $s0, 1
	addi	$t2, $t2, 1	# output the digit character $t0
	lw	$ra,0($sp)	# restore return address
	addi	$sp,$sp, 8	# restore stack
	jr	$ra
	
octend: addi	$t0, $t0, 2
	j 	loop
	


hex:	addi	$sp,$sp,-4
	sw	$ra,0($sp)
	jal	hexstr
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	j	unsend

hexstr:	addi	$sp,$sp,-8
	sw	$ra,0($sp)
	remu	$t4,$t3,16
	ble 	$t4, 9, hexd	# $t0 <- $a0 % 10
	addi	$t4, $t4, 'W'
	j	hexh	
hexd:	addi	$t4,$t4,'0'	# $t0 += '0' ($t0 is now a digit character)
hexh:	divu	$t3,$t3,16	# $a0 /= 10
	beqz	$t3,oneh		# if( $a0 != 0 ) { 
	sw	$t4,4($sp)	#   save $t0 on our stack
	jal	hexstr		#   putint() (putint will deliberately use and modify $a0)
	lw	$t4,4($sp)	#   restore $t0
	                        # } 
oneh:	sb	$t4, 0($t2)
	add	$s0, $s0, 1
	addi	$t2, $t2, 1	# output the digit character $t0
	lw	$ra,0($sp)	# restore return address
	addi	$sp,$sp, 8	# restore stack
	jr	$ra
	
hexend: addi	$t0, $t0, 2
	j 	loop


posi:	li	$t4, 0
	addi	$t4, $t4, '+'
	sb	$t4, 0($t2)
	addi	$t2, $t2, 1
	li	$t4, 0	
	abs	$t3, $t3
	j	dplpos		
	
rightj:	move	$t7, $t3
loper:	div	$t7, $t7, 10
	addi	$s7, $s7, 1
	bne	$t7, 0, loper
	bgt	$s7, $s3, dplpos
	sub	$s7, $s3, $s7
countd:	li	$s5, 0
	li	$t4, ' '
	sb	$t4, 0($t2)
	addi	$t2, $t2, 1
	addi	$s0, $s0, 1
	sub	$s3, $s3, 1
	sub	$s7, $s7, 1
	bne	$s7, 0, countd
	j	dplpos
	
right0:	move	$t7, $t3
loper0:	div	$t7, $t7, 10
	addi	$s7, $s7, 1
	bne	$t7, 0, loper0
	bgt	$s7, $s4, dplpos
	sub	$s7, $s4, $s7
countd0:li	$s5, 0
	li	$t4, '0'
	sb	$t4, 0($t2)
	addi	$t2, $t2, 1
	addi	$s0, $s0, 1
	sub	$s4, $s4, 1
	sub	$s7, $s7, 1
	bne	$s7, 0, countd0
	j	dplpos
	
	
decpl:	li	$s5, 0
	beq	$s6, '+', posi
	beq	$s6, '-', dplpos
	bne	$s4, 0, right0
	bne	$s3, 0, rightj
	#beq	$s6, '+', posi
dplpos:	abs	$t3, $t3
	addi	$sp,$sp,-4
	sw	$ra,0($sp)
	jal	dplstr
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	j	dplend

dplstr:	addi	$sp,$sp,-8
	sw	$ra,0($sp)
	remu	$t4,$t3,10	# $t0 <- $a0 % 10
	addi	$t4,$t4,'0'	# $t0 += '0' ($t0 is now a digit character)
	divu	$t3,$t3,10	# $a0 /= 10
	beqz	$t3,onedpl		# if( $a0 != 0 ) { 
	sw	$t4,4($sp)	#   save $t0 on our stack
	jal	dplstr		#   putint() (putint will deliberately use and modify $a0)
	lw	$t4,4($sp)	#   restore $t0
	                        # } 
onedpl:	sb	$t4, 0($t2)
	add	$s0, $s0, 1
	addi	$t2, $t2, 1
	sub	$s3, $s3, 1	# output the digit character $t0
	lw	$ra,0($sp)	# restore return address
	addi	$sp,$sp, 8	# restore stack
	jr	$ra
	
dplend: bgt	$s3, $s5, addspace
	addi	$t0, $t0, 2
	li	$s5, 0
	li	$s6,0
	j 	loop
	
addspace:li	$t4, ' '
	sb	$t4, 0($t2)
	addi	$t2, $t2, 1
	addi	$s5, $s5, 1
	addi	$s0, $s0, 1
	j	dplend


dec:	bne	$s6, 0, decpl
	bne	$s3, 0, decpl
	bne	$s4, 0, decpl
	bgt	$t3, 0, dpos
	abs	$t3, $t3
	li	$t4, 0
	addi	$t4, $t4, '-'
	sb	$t4, 0($t2)
	addi	$t2, $t2, 1
	li	$t4, 0
dpos:	addi	$sp,$sp,-4
	sw	$ra,0($sp)
	jal	decstr
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	j	decend

decstr:	addi	$sp,$sp,-8
	sw	$ra,0($sp)
	remu	$t4,$t3,10	# $t0 <- $a0 % 10
	addi	$t4,$t4,'0'	# $t0 += '0' ($t0 is now a digit character)
	divu	$t3,$t3,10	# $a0 /= 10
	beqz	$t3,oned		# if( $a0 != 0 ) { 
	sw	$t4,4($sp)	#   save $t0 on our stack
	jal	decstr		#   putint() (putint will deliberately use and modify $a0)
	lw	$t4,4($sp)	#   restore $t0
	                        # } 
oned:	sb	$t4, 0($t2)
	add	$s0, $s0, 1
	addi	$t2, $t2, 1	# output the digit character $t0
	lw	$ra,0($sp)	# restore return address
	addi	$sp,$sp, 8	# restore stack
	jr	$ra
	
decend: addi	$t0, $t0, 2 #lol
	j 	loop

	
end: 	add	$t7, $t7, '\0'
	addi	$s0, $s0, 1
	sb	$t7, 1($t2)
	move	$v0, $s0
	
	jr	$ra		#this sprintf implementation rocks!

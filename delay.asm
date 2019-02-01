
.macro	PUSH (%reg)
	addi	$sp,$sp,-4
	sw	%reg,0($sp)
.end_macro

.macro	POP (%reg)
	lw	%reg,0($sp)
	addi	$sp,$sp,4
.end_macro
.data 
.align 2

ms: .word 0x1000 # the delay that can be alterd
delayfor: .word 0x47 # the for loop delay

.text


delmain: 		# the call main / will be removed for the time app.
	la $a0, ms		# saves the adress for the while delay
	la $a1, delayfor	# save the adress for the for delay
	lw $s0, 0($a0)
	lw $s1,	0($a1)
	jal while
	nop
 j stop
while: 			#while loop
	PUSH($ra)
	nop
loop:	
	beq   $s0,$0, whileStop
	nop
	sub $s0, $s0,1
	and $t1,$0,$0
	jal for
	nop
	j loop
	nop
whileStop:
	POP($ra)
	nop
	jr $ra
	nop

for:			#for loop
	beq $t1, $s1 forend
	nop
	addi $t1, $t1,1
	j for
	nop
forend:
	jr $ra
	nop
	
stop:
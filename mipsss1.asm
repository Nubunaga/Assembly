.data
.align 2
factlst: .space 32


.text
jal main
stop: j stop

.macro PUSH (%reg)
addi $sp,$sp,-4
sw %reg,0($sp)
.end_macro

.macro POP (%reg)
lw %reg,0($sp)
addi $sp,$sp,4
.end_macro

# $sa0 = n, 4v0 = r
# då vi inte kallar på ett annat sub register så kommer ra aldrig att användas. 
fact: addi $v0, $0,1
factloop: ble $a0, $0,donefact
mul $v0, $v0, $a0
addi $a0, $a0,-1
j factloop
donefact: jr $ra

makelist: PUSH ($ra) ## detta måste pushas för det kommer att förstöras om ni inte sparar denna adress.
	PUSH ($s0)
	PUSH ($s1)
	PUSH ($s2)
	PUSH ($s3)
move $s0, $a0 # so = start
move $s1, $a1	# s1 = length 
addi $s2,$0,0	# s2 = i
la $s3,factlst	# tar adressen från s3 och sätter den som factlist
makeloop: 
slt $t0,$s2, $s1 # svaret blir den som är minst.
beq $t0 $0, makeend
move $a0, $s0
jal fact

sll $t0, $s0, 2 # x 4 .
add $t1, $s3, $t0
sw $v0, 0($t1)

addi $s0, $s0,1
addi $s2,$s2,1
j makeloop
makeend:
POP ($s3)
POP ($s2)		#s register är callie save. 
POP ($s1)
POP ($s0)
POP ($ra)
jr $ra

main :
PUSH ($ra)
addi $a0, $0,3
addi $a1,$0,8
jal makelist
POP($ra)
jr $ra
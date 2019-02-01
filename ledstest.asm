# 0xbf886110
loop:

lui $t0, 0xbf88
lw $t1, 0x60d0($t0)
srl $t1,$t1,8
andi $t1,$t1 0xf
mul $t1,$t1,$t1
sw $t1,0x6110($t0)
j loop

.globl led_test
 
led_test:

lui $t0, 0xbf88	# laddar de 4 övre bytes till bf88
ori $t0,$t0,0x6110 # laddar de 4 nedre bytes till 6110 genom att or: a (+)
sw $a0,0($t0)	# detta laddar in register från argument a0 till $t0 med en offsett noll. 
jr $ra

.data
.align 2
msg: .space 8
.text
main: la $t1, msg
addi $t2,$zero,0x27
sb $t2,0($t1)
addi $t2,$zero,0x18
sb $t2,1($t1)
li $t2,0x4b544800
sw $t2,4($t1)
stop: j stop
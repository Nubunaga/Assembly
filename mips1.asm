.data
.align 2
# Test buffers
src: .ascii "0123456789abcdef"
.space 16
dst1: .space 32
dst2: .space 32
.text
main:
# TEST 1
# Copy from an aligned position to an aligned position,
# using an aligned number of bytes.
la $a0,src
la $a1,dst1
li $a2,14 # copy 14 bytes
jal memcpy
# TEST 2
# Copy from as well as to unaligned positions.
la $a0,src
addi $a0,$a0,5 # make the destination address unaligned
la $a1,dst2
li $a2,7 # copy 7 bytes
jal memcpy
stop: j stop

memcpy:
loop:
beq $a2,$zero,done # branch if done
lb $t0,0($a0) # load byte
sb $t0,0($a1) # store byte
addi $a0,$a0,1 # increment src pointer
addi $a1,$a1,1 # increment dst pointer
addi $a2,$a2,-1 # decrement counter
j loop
done:
jr $ra

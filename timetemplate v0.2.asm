  # timetemplate.asm
  # Written 2015 by F Lundevall
  # Copyright abandonded - this file is in the public domain.

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
mytime:	.word 0x5957
timstr:	.ascii "I am a clock, tick tack \0"
ms : .word 0x10
delayfor: .word 0x3 # the for loop delay
	.text
main:
	# print timstr
	la	$a0,timstr
	li	$v0,4
	syscall
	nop
	# wait a little
	li	$a0,2
	jal	delay
	nop
	# call tick
	la	$a0,mytime
	jal	tick
	nop
	# call your function time2string
	la	$a0,timstr
	la	$t0,mytime
	lw	$a1,0($t0)
	jal	time2string
	nop
	# print a newline
	li	$a0,10
	li	$v0,11
	syscall
	nop
	# go back and do it all again
	j	main
	nop
# tick: update time pointed to by $a0
tick:	lw	$t0,0($a0)	# get time
	addiu	$t0,$t0,1	# increase
	andi	$t1,$t0,0xf	# check lowest digit
	sltiu	$t2,$t1,0xa	# if digit < a, okay
	bnez	$t2,tiend
	nop
	addiu	$t0,$t0,0x6	# adjust lowest digit
	andi	$t1,$t0,0xf0	# check next digit
	sltiu	$t2,$t1,0x60	# if digit < 6, okay
	bnez	$t2,tiend
	nop
	addiu	$t0,$t0,0xa0	# adjust digit
	andi	$t1,$t0,0xf00	# check minute digit
	sltiu	$t2,$t1,0xa00	# if digit < a, okay
	bnez	$t2,tiend
	nop
	addiu	$t0,$t0,0x600	# adjust digit
	andi	$t1,$t0,0xf000	# check last digit
	sltiu	$t2,$t1,0x6000	# if digit < 6, okay
	bnez	$t2,tiend
	nop
	addiu	$t0,$t0,0xa000	# adjust last digits
tiend:	sw	$t0,0($a0)	# save updated result
	jr	$ra		# return
	nop

  # you can write your code for subroutine "hexasc" below this line
  #andi $a0, $a0, 0xf
 hexacs:
 	andi $a3, $a3, 0xf	# maskar bort de bits vi inte är intresserade av
	ble $a3, 0x9,number	# kontrollerar om det är en siffra eller en bokstav som skall printas
	nop
	number:
	addi $v0, $a3, 0x30	# hex till ASCII-decoding, stoppas i function return-registret
	jr $ra			#return
	nop
	
delay:		
	PUSH ($ra)
	PUSH ($a0)
	lw $a0, ms 	# the call main / will be removed for the time app.
	lw $s1,	delayfor	#while loop
loop:	
	beq   $a0,$0, whileStop		#kontrollerar om "ms" är lika med 0;
	nop
	sub $a0, $a0,1		# decremera med 1.
	and $s0,$0,$0		#declarera i = 0 
	jal for			## vanlig branch går bra med		# hoppar och länkar sitt register till for loopen.
	nop
	j loop			# loopar om.
	nop
whileStop:
	POP ($a0)
	POP ($ra)
	jr $ra
	nop
for:					
	beq $s0, $s1, forend
	nop
	addi $s0, $s0,1
	j for
	nop
forend:
	jr $ra
	nop
	
time2string:			# $a1 innehåller "tiden" ($t0) är adressen till den minnesplats vars värde skrivs ut.
	PUSH ($ra)
	PUSH ($s1)
	PUSH ($s0)
	nop		# sparar minnesadressen på hoppen mellan rad 38 main till denna. Då vi kallar på hexasc i denna subrutin vill vi inte tappa bort vart vi ska tillbaka.
	srl $a3,$a1,12		# För att komma åt MINUT1 (5) i det hexadecimala talet 0x00005958 (4 nibble) utförs en logisk skift
	jal hexacs		# detta värde skickas till hexsacs för att kunna bli omvandlad till hexa för ascii nr 5.
	nop			# delay för att spara klockfrekvensen.
	sb $v0,0($a0)		# sparar värdet (vår ascii-kod för MINUT1 i den första byten i minnesplatsen adresserad i $t0
		
	srl $a3,$a1,8		# För att komma åt MINUT2 i värdet skiftar vi nu 8 bits. Vi behöver inte ta hänsyn till bits på högre index, det tar hexasc hand om.
	jal hexacs		
	nop	
	sb $v0,1($a0)		# sparar värdet (vår ascii-kod för MINUT2 i den andra byten i minnesplatsen adresserad i $t0

	addi $a3, $0, 0x3a	# lägger in ASCII-koden för ":" (0x3a) i $a3
	sb $a3,2($a0)		# sparar värdet (vår ascii-kod för ":" i den tredje byten i minnesplatsen adresserad i $t0
	
        srl $a3,$a1,4		# bitshiftar för att komma åt SEKUND1
	jal hexacs
	nop	
	sb $v0,3($a0)		# ASCII-koden för SEKUND1 sparas till minnet
		
	srl $a3,$a1,0		# SEKUND2-byten ligger redan på rätt plats i word så ingen shift behöver utföras (kanske kan använda en annan operator än srl?)
	jal hexacs
	nop
	sb $v0,4($a0)		# ASCII-koden för SEKUND2 sparas till minnet
	
	andi $s0, $a3, 0x1	# Den sista biten extraheras, den kan användas för att kolla om talet är jämt eller udda.
	bne $s0, $0, odd
		# branchar till "odd:" om den sista bitten inte matchar
	nop
	addi $s1, $0, 0x45 	# ASCII-koden för E
	sb $s1, 5($a0)		# Lägger till bokstaven E i slutet av strängen eftersom att sekunden är jämn
	sb $0,6($a0)		# null-char spars till sist bland de bytes som utgör vår teckensträng (string)
	POP ($s0)			# POP för att vi ska korrekt återvändra till rad 38.
	POP ($s1)			# Återställer värdet på $s1
	POP  ($ra)			# Återställer värdet på $s0
	jr $ra
	nop

	odd:
		addi $s1, $0, 0x44 	# ASCII-koden för D
		sb $s1, 5($a0)		# Lägger till "D" i slutet av strängen eftersom att den är udda.
		sb $0,6($a0)		# null-char spars till sist bland de bytes som utgör vår teckensträng (string)
		POP ($s0)			# POP för att vi ska korrekt återvändra till rad 38.
		POP ($s1)			# Återställer värdet på $s1
		POP  ($ra)			# Återställer $s0
		jr $ra			# return 2 call
		nop

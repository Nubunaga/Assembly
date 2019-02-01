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
 	andi $a3, $a3, 0xf	# maskar bort de bits vi inte �r intresserade av
	ble $a3, 0x9,number	# kontrollerar om det �r en siffra eller en bokstav som skall printas
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
	beq   $a0,$0, whileStop		#kontrollerar om "ms" �r lika med 0;
	nop
	sub $a0, $a0,1		# decremera med 1.
	and $s0,$0,$0		#declarera i = 0 
	jal for			## vanlig branch g�r bra med		# hoppar och l�nkar sitt register till for loopen.
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
	
time2string:			# $a1 inneh�ller "tiden" ($t0) �r adressen till den minnesplats vars v�rde skrivs ut.
	PUSH ($ra)
	PUSH ($s1)
	PUSH ($s0)
	nop		# sparar minnesadressen p� hoppen mellan rad 38 main till denna. D� vi kallar p� hexasc i denna subrutin vill vi inte tappa bort vart vi ska tillbaka.
	srl $a3,$a1,12		# F�r att komma �t MINUT1 (5) i det hexadecimala talet 0x00005958 (4 nibble) utf�rs en logisk skift
	jal hexacs		# detta v�rde skickas till hexsacs f�r att kunna bli omvandlad till hexa f�r ascii nr 5.
	nop			# delay f�r att spara klockfrekvensen.
	sb $v0,0($a0)		# sparar v�rdet (v�r ascii-kod f�r MINUT1 i den f�rsta byten i minnesplatsen adresserad i $t0
		
	srl $a3,$a1,8		# F�r att komma �t MINUT2 i v�rdet skiftar vi nu 8 bits. Vi beh�ver inte ta h�nsyn till bits p� h�gre index, det tar hexasc hand om.
	jal hexacs		
	nop	
	sb $v0,1($a0)		# sparar v�rdet (v�r ascii-kod f�r MINUT2 i den andra byten i minnesplatsen adresserad i $t0

	addi $a3, $0, 0x3a	# l�gger in ASCII-koden f�r ":" (0x3a) i $a3
	sb $a3,2($a0)		# sparar v�rdet (v�r ascii-kod f�r ":" i den tredje byten i minnesplatsen adresserad i $t0
	
        srl $a3,$a1,4		# bitshiftar f�r att komma �t SEKUND1
	jal hexacs
	nop	
	sb $v0,3($a0)		# ASCII-koden f�r SEKUND1 sparas till minnet
		
	srl $a3,$a1,0		# SEKUND2-byten ligger redan p� r�tt plats i word s� ingen shift beh�ver utf�ras (kanske kan anv�nda en annan operator �n srl?)
	jal hexacs
	nop
	sb $v0,4($a0)		# ASCII-koden f�r SEKUND2 sparas till minnet
	
	andi $s0, $a3, 0x1	# Den sista biten extraheras, den kan anv�ndas f�r att kolla om talet �r j�mt eller udda.
	bne $s0, $0, odd
		# branchar till "odd:" om den sista bitten inte matchar
	nop
	addi $s1, $0, 0x45 	# ASCII-koden f�r E
	sb $s1, 5($a0)		# L�gger till bokstaven E i slutet av str�ngen eftersom att sekunden �r j�mn
	sb $0,6($a0)		# null-char spars till sist bland de bytes som utg�r v�r teckenstr�ng (string)
	POP ($s0)			# POP f�r att vi ska korrekt �terv�ndra till rad 38.
	POP ($s1)			# �terst�ller v�rdet p� $s1
	POP  ($ra)			# �terst�ller v�rdet p� $s0
	jr $ra
	nop

	odd:
		addi $s1, $0, 0x44 	# ASCII-koden f�r D
		sb $s1, 5($a0)		# L�gger till "D" i slutet av str�ngen eftersom att den �r udda.
		sb $0,6($a0)		# null-char spars till sist bland de bytes som utg�r v�r teckenstr�ng (string)
		POP ($s0)			# POP f�r att vi ska korrekt �terv�ndra till rad 38.
		POP ($s1)			# �terst�ller v�rdet p� $s1
		POP  ($ra)			# �terst�ller $s0
		jr $ra			# return 2 call
		nop

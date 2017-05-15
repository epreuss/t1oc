####### Main #######

.data
	buffer: .asciiz "The quick brown fox jumps over the lazy dog."

.text

# Write to file just opened
#li   $v0, 15       # system call for write to file
#move $a0, $s6      # file descriptor 
#la   $a1, buffer   # address of buffer from which to write
#li   $a2, 44       # hardcoded buffer length
#syscall            # write to file

jal decodificaHex
#jal desenhaArquivo

# Termina main
li $v0, 17
syscall

####### Métodos #######

.macro printStr (%string)
.data
	myStr: .asciiz %string
.text
	li $v0, 4
	la $a0, myStr
	syscall
.end_macro

.macro printA0
	li $v0, 4
	syscall
.end_macro

.macro printInt (%int)
	li $v0, 1
	add $a0, $zero, %int
	syscall
.end_macro

####### Decodificar hexadecimal #######

.data
	null: .asciiz "null"
	sll0: .asciiz "sll"
	srl1: .asciiz "srl"
	tableR: .word sll0, null, srl1
.text

# $s0 deve possuir o hex
decodificaHex:
	#la $t0, tableR
	#lw $t1, 4($t0)
	#li $v0, 4
	#add $a0, $t1, $zero
	#syscall
		
	# 0000 0000 0000 0101 0011 0000 0100 0000 = sll $a2, $a1, 1 = 0x00053040 = 3400032
	# 1000 1100 1010 0110 1111 1111 1111 1111 = lw $a1, $a2 = 0x8ca6ffff = 2359754751
	li $s0, 2359754751
	srl $t0, $s0, 26 # Opcode em $t0
	beq $t0, $zero, tipoR
tipoI:
	#la $t2, tableR	
	#lw $a0, 0($t2)
	#printA0()
	#printStr(" ")
	sll $t0, $s0, 6
	srl $t0, $t0, 27 # rs	
	printStr("$")
	printInt($t0)
	printStr(", ")
	sll $t0, $s0, 11
	srl $t0, $t0, 27 # rt
	printStr("$")
	printInt($t0)
	printStr(", ")
	sll $t0, $s0, 16
	srl $t0, $t0, 16 # Adress
	printStr("A[")
	printInt($t0)
	printStr("].")
	j hexEnd
tipoR:
	sll $t0, $s0, 26
	srl $t0, $t0, 26 # Funct
	printStr("F[")
	printInt($t0)
	printStr("]: ")
	la $t2, tableR	
	lw $a0, 0($t2)
	printA0()
	printStr(" ")
	sll $t0, $s0, 6
	srl $t0, $t0, 27 # rs	
	printStr("$")
	printInt($t0)
	printStr(", ")
	sll $t0, $s0, 11
	srl $t0, $t0, 27 # rt
	printStr("$")
	printInt($t0)
	printStr(", ")
	sll $t0, $s0, 16
	srl $t0, $t0, 27 # rd
	printStr("$")
	printInt($t0)
	printStr(",")
	sll $t0, $s0, 21
	srl $t0, $t0, 27 # shamt
	printStr(" S[")
	printInt($t0)
	printStr("].")

hexEnd:
	jr $ra

####### Desenhar arquivo #######

.data
	file:   .asciiz "projeto_01_codigo.bin"
	reader: .asciiz ""

.text

desenhaArquivo:
	# Abre
	li   $v0, 13       # Abrir arquivo
	la   $a0, file     # Passa nome do arquivo
	li   $a1, 0        # 0: ler, 1: escrever
	li   $a2, 0        # Ignorado
	syscall            # Retorna arquivo em $v0
	move $s4, $v0      # Salva o arquivo
	# Lê
	li   $v0, 14       # Ler arquivo
	move $a0, $s4      # Referência do arquivo
#	sub $sp, $sp, 4
#	addiu $a1, $sp, 4
	la   $a1, reader   # Buffer de leitura
	li   $a2, 500      # Quantidade de caracteres
	syscall            # Retorna em $v0 quantos foram lidos
	# Fecha 
	li   $v0, 16       # Fechar arquivo
	move $a0, $s4      # Passa referência do arquivo
	syscall            # Fechado
	li   $v0, 4
	# Desenha
	li   $v0, 4 	   # Desenhar string
	move   $a0, $a1   # Passa o buffer
	syscall            # Desenha
	# Acaba método
	jr   $ra           # Volta para main
	
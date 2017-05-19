####### Main #######

# $t0 - auxiliar principal
# $s0 - hexacimal atual sendo decodificado
# $s1 - salva $ra
# $s7 - endere�o de todos hexadecimais do arquivo bin�rio

.text

main:

jal leBinario

decodificaTodosHex:
	jal decodificaHex
	add $s7, $s7, 4 # avanca hex

	lw $t0, 0($s7)
	bne $t0, 0, decodificaTodosHex

#jal desenhaArquivo

end: # Termina programa
li $v0, 17
syscall

####### M�todos #######

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
	n: .asciiz "???"
	sll0: .asciiz "sll"
	jr8: .asciiz "jr"
	syscall12: .asciiz "syscall"
	add32: .asciiz "add"
	addu33: .asciiz "addu"
	slt42: .asciiz "slt"
	tableR: .word sll0, n,n,n,n,n,n,n, jr8, n,n,n, syscall12, n,n,n,n,n,n,n,n,n,n,n,n,n,n,n,n,n,n,n, add32, addu33, n,n,n,n,n,n,n,n, slt42, n
	Rtypes: .word 2,    0,0,0,0,0,0,0, 3,   0,0,0,         4, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,     1,      1, 0,0,0,0,0,0,0,0,     1, 0
	
	beq0: .asciiz "beq" 
	bne0: .asciiz "bne" 
	blez0: .asciiz "blez" 
	bgtz0: .asciiz "bgtz" 
	addi0: .asciiz "addi" 
	addiu0: .asciiz "addiu" 
	slti0: .asciiz "slti" 
	sltiu0: .asciiz "sltiu"  
	andi0: .asciiz "andi" 
	ori0: .asciiz "ori" 
	xori0: .asciiz "xori" 
	lui0: .asciiz "lui"    
	
	tableI: .word beq0, bne0, blez0, bgtz0
	
.text

# $s0 deve possuir o hex
	la $t0, tableR
	lw $t1, 0($t0)
	li $v0, 4
	add $a0, $t1, $zero
	syscall
decodificaHex:
	la $s1, 0($ra)
	printStr("\n")
		
				
	# 0000 0000 0000 0101 0011 0000 0100 0000 = sll $a2, $a1, 1 = 0x00053040 = 3400032
	# 1000 1100 1010 0110 1111 1111 1111 1111 = lw $a1, $a2 = 0x8ca6ffff = 2359754751
	li $s0, 5897
	lw $s0, 0($s7) #2359754751
	add $a0, $zero $s0
	#li $v0, 34
	#syscall
	#printStr("\n")
	srl $t0, $s0, 26 # Opcode em $t0
	beq $t0, $zero, tipoR
tipoI:
	j hexEnd
	printStr("tipo I - ")
	#la $t2, tableR	
	#lw $a0, 0($t2)
	#printA0()
	#printStr(" ")
	printStr("OP[")
	printInt($t0)
	printStr("]: ")
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
	printStr("tipo R - ")
	sll $t0, $s0, 26
	srl $t0, $t0, 26 # Funct
	printStr("F[")
	printInt($t0)
	printStr("]: ")

	# Acessa mnemonico da tabela
	la $t2, tableR
	mul $t0, $t0, 4
	add $t2, $t2, $t0
	lw $a0, 0($t2)
	printA0()
	printStr(" ")
	# rs
	sll $t0, $s0, 6
	srl $t0, $t0, 27
	printStr("$")
	add $a3, $t0, $zero
	jal printRegister
	printStr(", ")
	# rt
	sll $t0, $s0, 11
	srl $t0, $t0, 27
	printStr("$")
	add $a3, $t0, $zero
	jal printRegister
	printStr(", ")
	# rd
	sll $t0, $s0, 16
	srl $t0, $t0, 27
	printStr("$")
	add $a3, $t0, $zero
	jal printRegister
	printStr(",")
	#sll $t0, $s0, 21
	#srl $t0, $t0, 27 # shamt
	#printStr(" S[")
	#printInt($t0)
	#printStr("].")
hexEnd:
	jr $s1
	
	
###### Recebe um inteiro de 0-31 em $a3 e printa a string certa ########

.data
	r0: .asciiz "zero"
	r1: .asciiz "at"
	r2: .asciiz "v0"
	r3: .asciiz "v1"
	r4: .asciiz "a0"
	r5: .asciiz "a1"
	r6: .asciiz "a2"
	r7: .asciiz "a3"
	r8: .asciiz "t0"
	r9: .asciiz "t1"
	r10: .asciiz "t2"
	r11: .asciiz "t3"
	r12: .asciiz "t4"
	r13: .asciiz "t5"
	r14: .asciiz "t6"
	r15: .asciiz "t7"
	r16: .asciiz "s0"
	r17: .asciiz "s1"
	r18: .asciiz "s2"
	r19: .asciiz "s3"
	r20: .asciiz "s4"
	r21: .asciiz "s5"
	r22: .asciiz "s6"
	r23: .asciiz "s7"
	r24: .asciiz "t8"
	r25: .asciiz "t9"
	r26: .asciiz "k0"
	r27: .asciiz "k1"
	r28: .asciiz "gp"
	r29: .asciiz "sp"
	r30: .asciiz "fp"
	r31: .asciiz "ra"

	tableRegisters: .word r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14, r15, r16, r17, r18, r19, r20,
		r21, r22, r23, r24, r25, r26, r27, r28, r29, r30, r31
	
.text

printRegister:
	la $t0, tableRegisters # Carrega endereco
	mul $t1, $a3, 4        # Posiciona endereco
	add $t0, $t0, $t1      # Atualiza vetor
	lw $a0, 0($t0)         # Acessa valor
	li $v0, 4	       # Printar valor
	syscall
	jr $ra
	
###### L� o arquivo bin�rio e coloca todos hexadecimais no vetor $s7 #######
	
leBinario:		
            sub   $sp, $sp, 16  # alocamos na pilha espaço para as variáveis
            la    $s4, 0($sp)  # s4 = acesso fixado
           	la    $s7, 12($sp)	
            # abertura do arquivo de leitura
            la    $a0, arquivoEntrada # $a0 <- endereço da string com o nome do arquivo
            li    $a1, 0 # flags: 0  - leitura
            li	  $a2, 0 # modo - atualmente é ignorado pelo serviço
            #chamamos o serviço 13 para a abertura do arquivo
            li    $v0, 13	
            syscall   
            sw    $v0, 0($s4)   # gravamos o descritor do arquivo
            slt   $t0, $v0, $zero # verificamos se houve um erro na abertura do arquivo
            bne   $t0, $zero, erroAberturaArquivoLeitura
            #  fazemos um contador igual a 8
            li    $t0, 8
            sw    $t0, 8($s4)
            # enquanto não chegamos no final do arquivo executamos o laço lacoLeiaPalavra
            j     verificaFinalArquivo            
lacoLeiaPalavra:
            # imprimimos a palavra se a leitura foi correta
            lw    $a0, 4($s4)   # tomamos a palavra do buffer
            #li    $v0, 34       # serviço 34: imprime um inteiro em hexadecimal
            #syscall
            #j decrementaContador
            # Guarda o hexadecimal em um vetor.            
            sw    $a0, 0($s7)
            sub   $sp, $sp, 4
            add   $s7, $s7, 4
            # contador de bytes
            add   $t6, $t6, 4
                     
decrementaContador:
            # decrementamos o contador
            lw    $t0, 8($s4)
            addiu $t0, $t0, -1
            sw    $t0, 8($s4)
            # se contador=0 (imprimimos 8 palavras) gera uma nova linha
            bne   $t0, $zero, imprimeEspaco
            # faz contador igual a 8
            li    $t0, 8
            sw    $t0, 8($s4)
            #li    $a0, '\n'
            #li    $v0, 11
            #syscall
            j     verificaFinalArquivo
imprimeEspaco:
            # imprimimos um espaço
            #li    $a0,' '
            #li    $v0, 11
            #syscall
verificaFinalArquivo:
            # lemos uma palavra do arquivo
            lw    $a0, 0($s4)   # $a0 <- descritor do arquivo
            addiu $a1, $s4, 4   # $a1 <- endereço do buffer de entrada 
            li    $a2, 4        # $a2 <- número de caracteres lidos
            li    $v0, 14
            syscall
            # verificamos se foram lidos 4 bytes
            slti  $t0, $v0, 4
            beq   $t0, $zero, lacoLeiaPalavra
            # acabou de ler, reset pilha e endereco dos hexadecimais            
            addi $sp, $sp, 16
	    add $sp, $sp, $t6
	    sub $s7, $s7, $t6
            jr $ra # volta para main
            	    
erroAberturaArquivoLeitura:
            la    $a0, mensagemErroAberturaArquivo # $a0 <- endereço da string com mensagem de erro
            li    $v0, 4  #serviço 4: impressão de string
            syscall	  #fazemos uma chamada ao sistema: fazemos a impressão da string, indicando o erro.
            li    $a0, 1  # valor diferente de 0: o programa terminou com erros
            li    $v0, 17 # serviço exit2 - termina o programa
	    syscall 
	                            
.data
arquivoEntrada: .asciiz "projeto_01_codigo.bin" 
mensagemErroAberturaArquivo: .asciiz "Erro na abertura do arquivo de entrada\n"

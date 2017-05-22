
####### Macros #######

.macro printStr (%string)
.data
	myStr: .asciiz %string
.text
	li $v0, 4
	la $a0, myStr
	syscall
.end_macro

.macro printA0
	saveStr($a0)
	li $v0, 4
	syscall
.end_macro

.macro printInt (%int)
	li $v0, 1
	add $a0, $zero, %int
	syscall
.end_macro

.macro printHexS4 ()
	li $v0, 34
	add $a0, $s4, $zero
	syscall
	printStr("\n")	
.end_macro

.macro saveStr (%str)
.data
	line: .asciiz "\n"
.text
	sw %str, 0($s4)
	sub $sp, $sp, $s6
	add $s4, $s4, $s6	
	add $s5, $s5, 1
.end_macro


####### Registradores principais #######

# $s0 - hexacimal atual sendo decodificado
# $s4 - vetor de strings para gerar arquivo de saida
# $s5 - quantidade de strings
# $s6 - espaco para cada string do vetor $s4
# $s7 - endereço de todos hexadecimais do arquivo binário

####### Main #######

.data 

test: .asciiz "eagegegagaeg"
table: .word test

.text

main:

# Inicializa registrador $s7 com hexadecimais
#jal leBinario

# Inicializa registrador $s6
li $s6, 8
# Inicializa registrador $s4
sub $sp, $sp, $s6
la $s4, 0($sp)

printHexS4()

	la $t1, table # Carrega endereco
	#add $t1, $t1, 0 # Atualiza endereco
	lw $t2, 0($t1)
	la $t2, test
	sw $t2, 0($s4)
	sub $sp, $sp, $s6
	add $s4, $s4, $s6	
	add $s5, $s5, 1
	
# Decodifica hexadecimais
decodificaTodosHex:
	#jal decodificaHex
	printStr("\n")
	add $s7, $s7, 4 # avanca hex

	#lw $t0, 0($s7)
	#bne $t0, 0, decodificaTodosHex

printStr("\n")
jal desenhaSaida

jal fazArquivoOutput

# Termina programa
end:
	li $v0, 17
	syscall

####### Desenha o arquivo de saída ########

desenhaSaida:
	li $v0, 4
	mul $t1, $s5, $s6
	sub $s4, $s4, $t1
	printHexS4()
	lw $t0, 0($s4)
desenhaLoop:
	add $a0, $t0, $zero
	syscall
	printStr("\n")
	add $s4, $s4, $s6
	lw $t0, 0($s4)
	bne $t0, 0, desenhaLoop
	jr $ra


####### Cria arquivo de saida ########

.data

arquivoSaida: "output.txt"

.text

fazArquivoOutput:     
	mul $t1, $s5, $s6
	sub $s4, $s4, $t1      
	printHexS4()
        # abertura do arquivo de saida
        la    $a0, arquivoSaida # endereco arquivo
        li    $a1, 1	# flags: 1  - escrita
        li    $a2, 0 	# modo - atualmente é ignorado pelo serviço
        li    $v0, 13	# abertura
        syscall  
        beq   $v0, -1, end
        # escreve no arquivo
        move  $a0, $v0      # save the file descriptor 
	la    $a1, 0($s4)   # address of buffer from which to write
	mul   $t0, $s5, $s6 # $t0 = qtd * tamanho
	add   $a2, $zero, 10
        li    $v0, 15       # system call for write to file
	syscall             # write to file    
	li $v0, 1
	add $a0, $t0, $zero
	syscall         
	# fecha arquivo
	li   $v0, 16  
	syscall       
	jr $ra

####### Decodificar hexadecimal #######

.data
	n: .asciiz "???"
	jr8: .asciiz "jr"
	syscall12: .asciiz "syscall"
	add32: .asciiz "add"
	addu33: .asciiz "addu"
	slt42: .asciiz "slt"
	tableR: .word n,n,n,n,n,n,n,n, jr8, n,n,n, syscall12, n,n,n,n,n,n,n,n,n,n,n,n,n,n,n,n,n,n,n, add32, addu33, n,n,n,n,n,n,n,n, slt42, n
	Rtypes: .word 0,0,0,0,0,0,0,0,   2, 0,0,0,         3, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,     1,      1, 0,0,0,0,0,0,0,0,     1, 0
	
	j2: .asciiz "j"
	jal3: .asciiz "jal"
	beq4: .asciiz "beq" 
	bne5: .asciiz "bne" 
	addi8: .asciiz "addi" 
	addiu9: .asciiz "addiu" 
	ori13: .asciiz "ori" 
	lui15: .asciiz "lui"    
	lw35: .asciiz "lw" 
	sw43: .asciiz "sw"  
	
	tableI: .word n,n, j2, jal3, beq4, bne5, n,n, addi8, addiu9, n,n,n, ori13, n, lui15, n,n,n,n,n,n,n,n,n,n,n,n,n,n,n,n,n,n,n, lw35, n,n,n,n,n,n,n, sw43
	Itypes: .word 0,0,  1,    1,    1,    2, 0,0,     3,      3, 0,0,0,     3, 0,     4, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,    5, 0,0,0,0,0,0,0,    5 
	
.text

decodificaHex:
	# Guarda endereco de retorno - $s1
	la $s1, 0($ra)
	# Carrega o hex do vetor em $s7 para $s0		
	#lw $s0, 0($s7)
	li $s0, 8519688
	li $v0, 34
	add $a0, $s0, $zero
	syscall
	srl $t0, $s0, 26 # Opcode em $t0
	beq $t0, $zero, tipoR # Se for 0, o tipo é R. Caso contrário, I.
tipoI:
	printStr("; tipo I - ")
	add $t7, $t0, $zero # opcode em $t7
	
	# Printa mnemonico da tabela
	la $t1, tableI # Carrega endereco
	mul $t7, $t7, 4 # Posiciona endereco de acordo com opcode
	add $t1, $t1, $t7 # Atualiza endereco
	lw $a0, 0($t1)
	printA0()
	printStr(" ")
	
	# Verifica o tipo do R
	la $t1, Itypes  # Carrega endereco
	add $t1 $t1, $t7 # Atualiza endereco (já posicionado)
	lw $t0, 0($t1) # Carrega valor 
	beq $t0, 1, Itype1
	beq $t0, 2, Itype2
	beq $t0, 3, Itype3
	beq $t0, 4, Itype4
	beq $t0, 5, Itype5
	
	# Caso não for um tipo implementado
	printStr("???")
	j hexEnd
Itype1:
	# op, adress
	# bits: 6 26
	# name label
	
	# adress - $t9 
	sll $t9, $s0, 6
	srl $t9, $t9, 6
	
	# print adress
	add $a3, $t9, $zero
	jal printLabel
	j hexEnd
Itype2:
	# op, rs, rt, deslocamento
	# bits: 6 5 5 16
	# name rs, rt, label
	
	# rs - $t7
	sll $t7, $s0, 6
	srl $t7, $t7, 27
	# rt - $t8
	sll $t8, $s0, 11
	srl $t8, $t8, 27
	# deslocamento - $t9
	sll $t9, $s0, 16
	srl $t9, $t9, 16
	
	# print rs
	printStr("$")
	add $a3, $t7, $zero
	jal printRegister
	printStr(", ")	
	# print rt
	printStr("$")
	add $a3, $t8, $zero
	jal printRegister
	# print deslocamento
	printStr(", ")	
	add $a3, $t9, $zero
	jal printLabel
	j hexEnd
Itype3:
	# op, rs, rt, imediato
	# bits: 6 5 5 16
	# name rt, rs, imediato
	
	# rt - $t7
	sll $t7, $s0, 11
	srl $t7, $t7, 27
	# rs - $t8
	sll $t8, $s0, 6
	srl $t8, $t8, 27
	# imediato - $t9
	sll $t9, $s0, 16
	srl $t9, $t9, 16
	
	# print rt
	printStr("$")
	add $a3, $t7, $zero
	jal printRegister
	printStr(", ")	
	# print rs
	printStr("$")
	add $a3, $t8, $zero
	jal printRegister
	# print imediato
	printStr(", ")	
	printInt($t9)
	j hexEnd
Itype4:
	# op, 0, rt, imediato
	# bits: 6 5 5 16
	# name rt, imediato
	
	# rt - $t8
	sll $t8, $s0, 11
	srl $t8, $t8, 27
	# imediato - $t9
	sll $t9, $s0, 16
	srl $t9, $t9, 16
	
	# print rt
	printStr("$")
	add $a3, $t8, $zero
	jal printRegister
	# print imediato
	printStr(", ")	
	printInt($t9)
	j hexEnd
Itype5:
	# op, rs, rt, deslocamento
	# bits: 6 5 5 16
	# name rt, adress
	
	# rt - $t7
	sll $t7, $s0, 11
	srl $t7, $t7, 27
	# rs - $t8
	sll $t8, $s0, 6
	srl $t8, $t8, 27
	# deslocamento - $t9
	sll $t9, $s0, 16
	srl $t9, $t9, 16
	
	# print rt
	printStr("$")
	add $a3, $t7, $zero
	jal printRegister
	printStr(", ")	
	# print deslocamento
	printInt($t9)
	printStr("(")
	# print rs
	printStr("$")
	add $a3, $t8, $zero
	jal printRegister
	printStr(")")
	j hexEnd	

tipoR:
	printStr("tipo R - ")
	
	# Funct - $t7
	sll $t7, $s0, 26
	srl $t7, $t7, 26 
	#printStr("F[")
	#printInt($t7)
	#printStr("]")
	
	# Printa mnemonico da tabela
	la $t1, tableR # Carrega endereco
	mul $t7, $t7, 4 # Posiciona endereco de acordo com funct
	add $t1, $t1, $t7
	lw $a0, 0($t1)
	printA0()
	printStr(" ")
	
	# Verifica o tipo do R
	la $t1, Rtypes  # Carrega endereco
	add $t1 $t1, $t7 # Atualiza endereco (já posicionado)
	lw $t0, 0($t1) # Carrega valor 
	beq $t0, 1, Rtype1
	beq $t0, 2, Rtype2
	beq $t0, 3, Rtype3
	
	# Caso não for um tipo implementado
	printStr("???")
	j hexEnd
Rtype1:
	# op, rs, rt, rd, shamt, func
	# bits: 6 5 5 5 6
	# name rd, rs, rt
	
	# rd - $t7
	sll $t7, $s0, 16
	srl $t7, $t7, 27
	# rs - $t8
	sll $t8, $s0, 6
	srl $t8, $t8, 27
	# rt - $t8
	sll $t9, $s0, 11
	srl $t9, $t9, 27
	
	# print rd
	printStr("$")
	add $a3, $t7, $zero
	jal printRegister
	printStr(", ")	
	# print rs
	printStr("$")
	add $a3, $t8, $zero
	jal printRegister
	printStr(", ")	
	# print rt
	printStr("$")
	add $a3, $t9, $zero
	jal printRegister
	j hexEnd
Rtype2:
	# op, rs, imediate, func
	# bits: 6 5 15 6
	# name rs
	
	# rs - $t9
	sll $t9, $s0, 6
	srl $t9, $t9, 27
	printStr("$")
	add $a3, $t9, $zero
	jal printRegister	
	j hexEnd
Rtype3:
	# op, imediate, func
	# bits: 6 20 6
	# name
	j hexEnd
hexEnd:
	jr $s1
	
###### Recebe um inteiro de 32 bits em $a3 e printa em hexadecimal #######

printLabel:
	li $v0, 34
	add $a0, $a3, $zero
	#add $a0, $a0, 4194304 # Este número é o endereco 0x00400000
	syscall
	jr $ra

###### Recebe um inteiro de valor 0-31 em $a3 e printa a string certa ########

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
	
###### Lê o arquivo binário e coloca todos hexadecimais no vetor $s7 #######
	
leBinario:		
            sub   $sp, $sp, 16  # alocamos na pilha espaÃ§o para as variÃ¡veis
            la    $s4, 0($sp)  # s4 = acesso fixado
            la    $s7, 12($sp)	
            # abertura do arquivo de leitura
            la    $a0, arquivoEntrada # $a0 <- endereÃ§o da string com o nome do arquivo
            li    $a1, 0 # flags: 0  - leitura
            li	  $a2, 0 # modo - atualmente Ã© ignorado pelo serviÃ§o
            #chamamos o serviÃ§o 13 para a abertura do arquivo
            li    $v0, 13	
            syscall   
            sw    $v0, 0($s4)   # gravamos o descritor do arquivo
            slt   $t0, $v0, $zero # verificamos se houve um erro na abertura do arquivo
            bne   $t0, $zero, erroAberturaArquivoLeitura
            #  fazemos um contador igual a 8
            li    $t0, 8
            sw    $t0, 8($s4)
            # enquanto nÃ£o chegamos no final do arquivo executamos o laÃ§o lacoLeiaPalavra
            j     verificaFinalArquivo            
lacoLeiaPalavra:
            # imprimimos a palavra se a leitura foi correta
            lw    $a0, 4($s4)   # tomamos a palavra do buffer
            #li    $v0, 34       # serviÃ§o 34: imprime um inteiro em hexadecimal
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
            # imprimimos um espaÃ§o
            #li    $a0,' '
            #li    $v0, 11
            #syscall
verificaFinalArquivo:
            # lemos uma palavra do arquivo
            lw    $a0, 0($s4)   # $a0 <- descritor do arquivo
            addiu $a1, $s4, 4   # $a1 <- endereÃ§o do buffer de entrada 
            li    $a2, 4        # $a2 <- nÃºmero de caracteres lidos
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
            la    $a0, mensagemErroAberturaArquivo # $a0 <- endereÃ§o da string com mensagem de erro
            li    $v0, 4  #serviÃ§o 4: impressÃ£o de string
            syscall	  #fazemos uma chamada ao sistema: fazemos a impressÃ£o da string, indicando o erro.
            li    $a0, 1  # valor diferente de 0: o programa terminou com erros
            li    $v0, 17 # serviÃ§o exit2 - termina o programa
	    syscall 
	                            
.data
arquivoEntrada: .asciiz "projeto_01_codigo.bin" 
mensagemErroAberturaArquivo: .asciiz "Erro na abertura do arquivo de entrada\n"

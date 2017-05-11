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

jal desenhaArquivo

# Termina main
li $v0, 17
syscall

####### Métodos #######

.data
	file:   .asciiz "projeto_01_codigo.txt"
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
	sub $sp, $sp, 4
	addiu $a1, $sp, 0
	#la   $a1, reader   # Buffer de leitura
	li   $a2, 500      # Quantidade de caracteres
	syscall            # Retorna em $v0 quantos foram lidos
	# Fecha 
	li   $v0, 16       # Fechar arquivo
	move $a0, $s4      # Passa referência do arquivo
	syscall            # Fechado
	li   $v0, 4
	# Desenha
	li   $v0, 4 	   # Desenhar string
	lw   $a0, 0($sp)   # Passa o buffer
	syscall            # Desenha
	# Acaba método
	jr   $ra           # Volta para main

#*******************************************************************************
# exercicio057.s               Copyright (C) 2017 Giovani Baratto
# This program is free software under GNU GPL V3 or later version
# see http://www.gnu.org/licences
#
# Autor: Giovani Baratto (GBTO) - UFSM - CT - DELC
# e-mail: giovani.baratto@ufsm.br
# versão: 0.1
# Descrição: Leitura de palavras (grupo de 4 bytes) de um aquivo e escrita do
#            corespondente valor hexadecimal no console. Em uma linha escrevemos
#            8 palavras.
#
# Documentação:
# Assembler: MARS
# Revisões:
# Rev #  Data           Nome   Comentários
# 0.1    08.05.2017     GBTO   versão inicial 
#*******************************************************************************
#        1         2         3         4         5         6         7         8
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#           M     O             #
.text
.globl      main
main:		
            addiu $sp, $sp, 12  # alocamos na pilha espaço para as variáveis
            # abertura do arquivo de leitura
            la    $a0, arquivoEntrada # $a0 <- endereço da string com o nome do arquivo
            li    $a1, 0 # flags: 0  - leitura
            li	  $a2, 0 # modo - atualmente é ignorado pelo serviço
            #chamamos o serviço 13 para a abertura do arquivo
            li    $v0, 13	
            syscall   
            sw    $v0, 0($sp)   # gravamos o descritor do arquivo
            slt   $t0, $v0, $zero # verificamos se houve um erro na abertura do arquivo
            bne   $t0, $zero, erroAberturaArquivoLeitura
            #  fazemos um contador igual a 8
            li    $t0, 8
            sw    $t0, 8($sp)
            # enquanto não chegamos no final do arquivo executamos o laço lacoLeiaPalavra
            j     verificaFinalArquivo            
lacoLeiaPalavra:
            # imprimimos a palavra se a leitura foi correta
            lw    $a0, 4($sp)   # tomamos a palavra do buffer
            li    $v0, 34       # serviço 34: imprime um inteiro em hexadecimal
            syscall
decrementaContador:
            # decrementamos o contador
            lw    $t0, 8($sp)
            addiu $t0, $t0, -1
            sw    $t0, 8($sp)
            # se contador=0 (imprimimos 8 palavras) gera uma nova linha
            bne   $t0, $zero, imprimeEspaco
            # faz contador igual a 8
            li    $t0, 8
            sw    $t0, 8($sp)
            li    $a0, '\n'
            li    $v0, 11
            syscall
            j     verificaFinalArquivo
imprimeEspaco:
            # imprimimos um espaço
            li    $a0,' '
            li    $v0, 11
            syscall
verificaFinalArquivo:
            # lemos uma palavra do arquivo
            lw    $a0, 0($sp)   # $a0 <- descritor do arquivo
            addiu $a1, $sp, 4   # $a1 <- endereço do buffer de entrada 
            li    $a2, 4        # $a2 <- número de caracteres lidos
            li    $v0, 14
            syscall
            # verificamos se foram lidos 4 bytes
            slti  $t0, $v0, 4
            beq   $t0, $zero, lacoLeiaPalavra
            # terminamos o programa
            li    $a0, 0 # 0 <- programa terminou de forma normal
            li    $v0, 17 # serviço exit2 - termina o programa
	    syscall
	    
erroAberturaArquivoLeitura:
            la    $a0, mensagemErroAberturaArquivo # $a0 <- endereço da string com mensagem de erro
            li    $v0, 4	    # serviço 4: impressão de string
            syscall	            # fazemos uma chamada ao sistema: fazemos a impressão da string, indicando o erro.
            li    $a0, 1 # valor diferente de 0: o programa terminou com erros
            li    $v0, 17 #serviço exit2 - termina o programa	
            syscall
                            
                            
.data
arquivoEntrada: # nome do arquivo de entrada
.asciiz           "projeto_01_codigo.bin" 
mensagemErroAberturaArquivo: # mensagem de erro se o arquivo não pode ser aberto
.asciiz           "Erro na abertura do arquivo de entrada\n"



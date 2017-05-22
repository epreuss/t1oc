
.macro printHexS4 ()
	li $v0, 34
	add $a0, $s4, $zero
	syscall
	printStr("\n")	
.end_macro


.macro printStr (%string)
.data
	myStr: .asciiz %string
.text
	li $v0, 4
	la $a0, myStr
	syscall
.end_macro

.data 

test: .asciiz "test"
table: .word test

.text

main:

li $s6, 8 # space for each string in $s4
sub $sp, $sp, $s6 # create space for $s4
la $s4, 0($sp) # loads adress
printHexS4()
la $t1, table # load table
#lw $t2, 0($t1)
la $t2, test # load a word
sw $t2, 0($s4) # store in vector
sub $sp, $sp, $s6 # add space for future needs
add $s4, $s4, $s6 # update index	 
add $s5, $s5, 1 # update quantity
	
jal printVectorS4
jal doOutput

end:
	li $v0, 17
	syscall
	
printVectorS4:
	li $v0, 4
	mul $t1, $s5, $s6 # $t1 = quantity * size
	sub $s4, $s4, $t1 # update adress position to 0
	printHexS4()
	lw $t0, 0($s4)
loop:
	add $a0, $t0, $zero
	syscall # prints a string
	printStr("\n")
	add $s4, $s4, $s6 # increments index
	lw $t0, 0($s4) # load next word
	bne $t0, 0, loop
	jr $ra

.data

file: "output.txt"

.text

doOutput:     
	mul $t1, $s5, $s6 # $t1 = quantity * size
	sub $s4, $s4, $t1 # update adress position to 0    
	printHexS4()
        # open
        la    $a0, file 
        li    $a1, 1 # open to write
        li    $a2, 0 
        li    $v0, 13
        syscall  
        beq   $v0, -1, end
        # write
        move  $a0, $v0      # save the file descriptor 
	la    $a1, 0($s4)   # address of buffer from which to write
	mul   $t0, $s5, $s6 # $t0 = quantity * size
	add   $a2, $zero, $t0 # $a2 = total characters to write
        li    $v0, 15       # system call for write to file
	syscall             # write to file    
	li $v0, 1
	add $a0, $t0, $zero
	syscall         
	# close
	li   $v0, 16  
	syscall       
	jr $ra

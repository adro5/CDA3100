# Program to test if a palindrome function works properly or not
# Written by Xiuwen Liu for CDA 3100 - Homework #3, problem #2
# Register usage
# $s7 - save $ra
# $s2 - current address of the string to be tested
# $s3 - the next of the last string to be tested 
# $a0 - for function parameter / syscall parameter
# $v0 - syscall number / function return value
					
	.text
	.globl main
main:
	addu     $s7, $ra, $zero, # Save the ra
	la	$s2,  test_str    # Load the starting address of the array
	la	$s3, is_pali_msg, # the next of last address
pali_test_loop:	
	lw	$a0, 0($s2)	  # $a0 is the address of the string
	li      $v0, 4		  # system call to print a string
	syscall			  # print string
	li      $v0, 4		  # print a new line
        la      $a0, newline
	li      $v0, 4 
	syscall
	lw	$a0, 0($s2)	  # $a0 is the address of the string
	jal	palindrome	  # call palindrome
	beq	$v0, $zero, pali_no #if $v0 is 0, it is not a palindrome
	li      $v0, 4		#it is a palindrome
        la      $a0, is_pali_msg
	syscall
	j	pali_test_end
palindrome:
	li $t2, 0
	li $t5, 0
	li $s5, 0
	li $s6, 0
	addi $sp, $sp, -4
	sw $ra, 4($sp)
	jal converter
	sub $a0, $a0, $s6
	lw $ra, 4($sp)
	addi $sp, $sp, 4
	add $t0, $zero, $a0
loop:
    	lb $t4, 0($t0)                      #load byte from beginning of the string
	beq $t4, $zero, continue         #when character value is 0 we have 
    	addi $t0, $t0, 1                   #shift pointer to string one space right
    	addi $t5, $t5, 1                   #increment return value by one
	j loop
continue:	
	addi $t6, $t5, -1
	li $t7, 0	#int i = 0
	add $t8, $t5, -1
for:
	slt $t9, $t7, $t8
	beq $t9, $zero, exit
	add $s1, $t7, $a0
	lb $s1, 0($s1)
	add $s4, $t6, $a0
	lb $s4, 0($s4)
	bne $s1, $s4, falseexit
	addi $t6, $t6, -1
	addi $t7, $t7, 1
	j for
up2low:
	slti $t2, $s5, 65 
	bne $t2, $zero, converter         #when character value is 0 we have
 	addi $s5, $s5, 32
	addi $a0, $a0, -1
	sb $s5, 0($a0)
	addi $a0, $a0, 1
converter:
    	lb $s5, 0($a0)                      #load byte from beginning of the string
	beq $s5, $zero, done
    	addi $a0, $a0, 1                   #shift pointer to string one space right
	addi $s6, $s6, 1
	slti $t3, $s5, 91
	bne $t3, $zero, up2low
	j converter
done:
	jr $ra
exit:
	li $v0, 1 
	jr $ra

falseexit:
	li $v0, 0
	jr $ra
pali_no:			#it is not a palindrome
	li      $v0, 4 
        la      $a0, not_pali_msg	 
	syscall
pali_test_end:
	li      $v0, 4 
        la      $a0, newline
	syscall
	addiu	$s2, $s2, 4
	lw	$a0, 0($s2)
	beq	$a0, $s3, pali_done
	j	pali_test_loop

pali_done:
	li	$v0, 10
	syscall
	addu    $ra, $zero, $s7  #restore $ra since the function calles
		#another function
	jr      $ra
	add	$zero, $zero, $zero
	add	$zero, $zero, $zero
########## End of main function #########
	.data
#The following examples were copied from 
#	http://en.wikipedia.org/wiki/Palindrome
pali1:	
	.asciiz "aba" #Brazilian Portuguese: A valid palindrome
pali2:	
	.asciiz	"NolesELon" #A valid palindrome
pali3:	
	.asciiz "Stressed  Desserts"  # A valid palindrome
pali4:
	.asciiz	"palindromes"	# Not a palindrome
pali5:	
	.asciiz "tattarRATTAT"	# A valid palindrome
is_pali_msg: 
	.asciiz "    The string is a palindrome."
not_pali_msg: 
	.asciiz "    The string is not a palindrome."
newline:	
	.asciiz "\n"	
test_str:
	.word  pali1, pali2, pali3, pali4, pali5, is_pali_msg
	

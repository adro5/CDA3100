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
	#clearing all values from previous iterations#
	li $t2, 0
	li $t5, 0
	li $s5, 0
	li $s6, 0
	addi $sp, $sp, -4 	# create space on the stack
	sw $ra, 4($sp)		# add the return address to the stack
	jal converter		#jump to the upper2lower converter function and link new $ra
	sub $a0, $a0, $s6	#return pointer to initial location after iteration in conversion function
	lw $ra, 4($sp)		#restore previous $ra
	addi $sp, $sp, 4	#pop the stack
	add $t0, $zero, $a0	#copy pointer to array to temp register
	
#String length loop
loop:
    	lb $t4, 0($t0)                      #load byte from the string
	beq $t4, $zero, continue         #when character value is 0 we quit the stringlength loop 
    	addi $t0, $t0, 1                   #increment string pointer by 1
    	addi $t5, $t5, 1                   #increment string length value by 1
	j loop
continue:	
	addi $t6, $t5, -1		#length of string - 1 (ignoring the null character)
	li $t7, 0			#int i = 0
	add $t8, $t5, -1		#length of string - 1 (copy for decrementing)
for:
	slt $t9, $t7, $t8		#if i < stringlength - 1...continue for loop...
	beq $t9, $zero, exit		#else exit
	add $s1, $t7, $a0		#$s1 = AddressOf(stringArr[i])
	lb $s1, 0($s1)			#get value of s1 and put it back in s1
	add $s4, $t6, $a0		#$s4 = AddressOf(stringArr[j])
	lb $s4, 0($s4)			#$s4 = stringArr[j]
	bne $s1, $s4, falseexit		#if characters are unequal, short-circuit and return 0 after exit
	addi $t6, $t6, -1		#j--
	addi $t7, $t7, 1		#i++
	j for				
up2low:
	slti $t2, $s5, 65 		#if ASCII code is not a capital letter (between 65 and 91), set $t2 to 1
	bne $t2, $zero, converter         #when character value is 0 we continue. if not a capital letter, move on in loop
 	addi $s5, $s5, 32		#make character in $s5 lowercase
	addi $a0, $a0, -1		#decrementing string pointer to store $s5 at that location
	sb $s5, 0($a0)			#store new lowercase letter
	addi $a0, $a0, 1		#restore previous pointer location
converter:
    	lb $s5, 0($a0)                      #load byte from string
	beq $s5, $zero, done		#if null character, go back to palindrome function 
    	addi $a0, $a0, 1                #shift pointer to string one space right
	addi $s6, $s6, 1		#incremement counter to keep track of pointer location
	slti $t3, $s5, 91		#finds out if value of byte is below ASCII 91 (the letter Z or below)
	bne $t3, $zero, up2low		#if it isn't below 91 we continue. if it is below 91, go to the up2low function
	j converter			#loop again
done:
	jr $ra				#go back to palindrome function
exit:
	li $v0, 1 			#set $v0 (return 1) to true
	jr $ra				#return to the test program
falseexit:
	li $v0, 0			#set $v0 to false
	jr $ra				#return to test program
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
	

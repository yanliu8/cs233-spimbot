# Various helper functions for printing things

# Syscall constants
PRINT_INT = 1
PRINT_STRING = 4
PRINT_CHAR = 11

.text
# print int and space ##################################################
#
# argument $a0: number to print
# returns       nothing

.globl print_int_and_space
print_int_and_space:
	li	$v0, PRINT_INT	# load the syscall option for printing ints
	syscall			# print the number

	li   	$a0, ' '       	# print a black space
	li	$v0, PRINT_CHAR	# load the syscall option for printing chars
	syscall			# print the char
	
	jr	$ra		# return to the calling procedure

# print char and space #################################################
#
# argument $a0: character to print
# returns       nothing

.globl print_char_and_space
print_char_and_space:
	li	$v0, PRINT_CHAR	# load the syscall option for printing chars
	syscall			# print the number

	li   	$a0, ' '       	# print a black space
	li	$v0, PRINT_CHAR	# load the syscall option for printing chars
	syscall			# print the char
	
	jr	$ra		# return to the calling procedure

# print string #########################################################
#
# argument $a0: string to print
# returns       nothing

.globl print_string
print_string:
	li	$v0, PRINT_STRING	# print string command
	syscall	     			# string is in $a0
	jr	$ra

# print newline ########################################################
#
# no arguments
# returns       nothing

.globl print_newline
print_newline:
	li   	$a0, '\n'      	# print a newline
	li	$v0, PRINT_CHAR	# load the syscall option for printing chars
	syscall			# print the char
	jr	$ra

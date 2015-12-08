# syscall constants
PRINT_STRING  = 4

# spimbot constants
VELOCITY      = 0xffff0010
ANGLE         = 0xffff0014
ANGLE_CONTROL = 0xffff0018
BOT_X         = 0xffff0020
BOT_Y         = 0xffff0024
PRINT_INT     = 0xffff0080
OTHER_BOT_X   = 0xffff00a0
OTHER_BOT_Y   = 0xffff00a4

BONK_MASK     = 0x1000
BONK_ACK      = 0xffff0060

SCAN_X        = 0xffff0050
SCAN_Y        = 0xffff0054
SCAN_RADIUS   = 0xffff0058
SCAN_ADDRESS  = 0xffff005c
SCAN_MASK     = 0x2000
SCAN_ACK      = 0xffff0064

TIMER         = 0xffff001c
TIMER_MASK    = 0x8000
TIMER_ACK     = 0xffff006c
# fruit constants
FRUIT_SCAN	= 0xffff005c
FRUIT_SMASH	= 0xffff0068

SMOOSHED_MASK	= 0x2000
SMOOSHED_ACK	= 0xffff0064
# puzzle constants
REQUEST_PUZZLE  = 0xffff00d0
REQUEST_PUZZLE_MASK  = 0x800
REQUEST_PUZZLE_ACK = 0xffff00d8
SUBMIT_SOLUTION = 0xffff00d4
REQUEST_WORD    = 0xffff00dc

GET_ENERGY     =  0xffff00c8

.data
.globl smooshed
.align 2
requested_puzzle: .word 0
.align 2
smooshed: .space 4
.align 2
fruit_data: .space 260
node_memory: .space 4096
.globl puzzle_word
puzzle_word: .space 128
puzzle_grid: .space 8200 # rows + cols + puzzle gird so 8192 + 8
# Stores the address for the next node to allocate
.globl new_node_address
.align 2
new_node_address: .word node_memory
.align 2
cherry_calculation: .space 4
.globl num_rows
.globl num_cols
.align 2
num_cols: .space 4
.align 2
num_rows: .space 4
# Don't put anything below this just in case they malloc more than 4096




.text
main:
	# go wild
	# the world is your oyster
	li $t0 BONK_MASK
	or $t0 TIMER_MASK
	or $t0 SMOOSHED_MASK
	or $t0 REQUEST_PUZZLE_MASK
	or $t0 1
	mtc0 $t0 $12
initial_position:
	lw $t0 BOT_Y
	ble $t0 270 initial_down  # the initial height of the bot, can be set higher
	bge $t0 280 intial_up
	j begin
initial_down:
	li $t0 90
	j set_angle
intial_up:
	li $t0 -90
set_angle:
	sw $t0 ANGLE
	li $t0 1
	sw $t0 ANGLE_CONTROL
	li $t0 10
	sw $t0 VELOCITY
	j initial_position


begin:
	lw $t0 smooshed
	blt $t0 2 not_smash
go_bot:
	lw $t0 smooshed
	beq $t0 $zero not_smash
	li $t0 90
	sw $t0 ANGLE
	li $t0 1
	sw $t0 ANGLE_CONTROL
	li $t0 10
	sw $t0 VELOCITY
	j go_bot
not_smash:
	la $t0 fruit_data
	sw $t0 FRUIT_SCAN
	lw $t4 0($t0)
	beq $t4 $0 not_smash
	lw $t4 4($t0)
	lw $t1 8($t0)
	lw $t2 BOT_X  # $t2 = bot_x
	sub $t2 $t1 $t2  # $t2 = distance = fruit - bot
left_or_right:
	ble $t2 $0 move_left
	j move_right
move_left:
	li $t3 180
	sw $t3 ANGLE
	li $t3 1
	sw $t3 ANGLE_CONTROL
	ble $t2 2 set10
	j up
move_right:
	li $t3 0
	sw $t3 ANGLE
	li $t3 1
	sw $t3 ANGLE_CONTROL
	bge $t2 2 set10
	j up
up:
	li $t3 -90
	sw $t3 ANGLE
	li $t3 1
	sw $t3 ANGLE_CONTROL
set10:
	li $t3 10
	j set
set:
	sw $t3 VELOCITY
	j energy

energy:
	lw $t3 GET_ENERGY
	bgt $t3 30 begin
	lw $t3 requested_puzzle
	beq $zero $t3 puzzle
	j begin

puzzle:
	la $t0 puzzle_grid
	sw $t0 REQUEST_PUZZLE
	li $t0 1
	sw $t0 requested_puzzle
	j begin





.kdata				# interrupt handler data (separated just for readability)
chunkIH:	.space 16	# space for two registers
non_intrpt_str:	.asciiz "Non-interrupt exception\n"
unhandled_str:	.asciiz "Unhandled interrupt type\n"


.ktext 0x80000180
interrupt_handler:
.set noat
	move	$k1, $at		# Save $at
.set at
	la	$k0, chunkIH
	sw	$a0, 0($k0)		# Get some free registers
	sw	$a1, 4($k0)		# by storing them to a global variable
	sw  $a2, 8($k0)
	sw  $a3, 12($k0)

	mfc0	$k0, $13		# Get Cause register
	srl	$a0, $k0, 2
	and	$a0, $a0, 0xf		# ExcCode field
	bne	$a0, 0, non_intrpt

interrupt_dispatch:			# Interrupt:
	mfc0	$k0, $13		# Get Cause register, again
	beq	$k0, 0, done		# handled all outstanding interrupts

	and	$a0, $k0, BONK_MASK	# is there a bonk interrupt?
	bne	$a0, 0, bonk_interrupt

	and	$a0, $k0, TIMER_MASK	# is there a timer interrupt?
	bne	$a0, 0, timer_interrupt

	and $a0 $k0 SMOOSHED_MASK
	bne $a0 0 fruit_smooshed_interrupt

	and $a0 $k0 REQUEST_PUZZLE_MASK
	bne $a0 0 request_puzzle_interrupt

	# add dispatch for other interrupt types here.

	li	$v0, PRINT_STRING	# Unhandled interrupt types
	la	$a0, unhandled_str
	syscall
	j	done

request_puzzle_interrupt:
	li $a0 10
	sw $a0 VELOCITY
	li $a0 90
	sw $a0 ANGLE
	li $a0 1
	sw $a0 ANGLE_CONTROL
	la $a0 puzzle_word
	sw $a0 REQUEST_WORD
	la $k0 puzzle_grid
	lw $a1 0($k0)
	sw $a1 num_rows
	lw $a1 4($k0)
	sw $a1 num_cols
	add $a0 $k0 8
	la $a1 puzzle_word
	la $k0 solve_puzzle
	li $a2 0
	li $a3 0
	jalr $k0
	sw $v0 SUBMIT_SOLUTION
	li $a0 0
	sw $a0 requested_puzzle
	la $a0 node_memory
	sw $a0 new_node_address
	sw $a0 REQUEST_PUZZLE_ACK
	j interrupt_dispatch



fruit_smooshed_interrupt:
	lw $a0 smooshed
	add $a0 $a0 1
	sw $a0 smooshed
adjust_position:
	lw $a0 BOT_Y
	ble $a0 270 adjust_down  # the initial height of the bot, can be set higher
	bge $a0 280 adjust_up
	j finish
adjust_down:
	li $a0 90
	j set_angle1
adjust_up:
	li $a0 -90
set_angle1:
	sw $a0 ANGLE
	li $a0 1
	sw $a0 ANGLE_CONTROL
	li $a0 10
	sw $a0 VELOCITY
	j adjust_position
finish:
	sw $a0 SMOOSHED_ACK
	j interrupt_dispatch


bonk_interrupt:
	lw $a0 BOT_Y
	blt $a0 290 no_smash
smash:
	lw $a0 smooshed
	beq $a0 $zero no_smash
	sw $a0 FRUIT_SMASH
	add $a0 $a0 -1
	sw $a0 smooshed
	j smash
no_smash:
	li $a0 10
	sw $a0 VELOCITY
	li $a0 270
	sw $a0 ANGLE
	li $a0 1
	sw $a0 ANGLE_CONTROL
	lw $s1 BOT_Y
	ble $s1 280 return_smash
	j no_smash
return_smash:
	sw	$a1, BONK_ACK		# acknowledge interrupt
	sw	$zero, VELOCITY		# ???
	j	interrupt_dispatch		# see if other interrupts are waiting

timer_interrupt:
	sw	$a1, TIMER_ACK		# acknowledge interrupt

	li  $a1, 1
	sw	$a1, cherry_calculation

	j	interrupt_dispatch	# see if other interrupts are waiting

non_intrpt:				# was some non-interrupt
	li	$v0, PRINT_STRING
	la	$a0, non_intrpt_str
	syscall				# print out an error message
	# fall through to done

done:
	la	$k0, chunkIH
	lw	$a0, 0($k0)		# Restore saved registers
	lw	$a1, 4($k0)
	lw  $a2, 8($k0)
	lw  $a3, 12($k0)
.set noat
	move	$at, $k1		# Restore $at
.set at
	eret

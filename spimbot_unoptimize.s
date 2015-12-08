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
smooshed: .space 4
requested_puzzle: .word 0
.align 2
fruit_data: .space 260
node_memory: .space 4096
.globl puzzle_word
puzzle_word: .space 128

puzzle_grid: .space 8200 # rows + cols + puzzle gird so 8192 + 8
# Stores the address for the next node to allocate
.globl new_node_address
new_node_address: .word node_memory
cherry_calculation: .space 4
.globl num_rows
.globl num_cols
num_cols: .space 4
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
	ble $t0 240 initial_down  # the initial height of the bot, can be set higher
	bge $t0 260 intial_up
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
	blt $t0 5 not_smash
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
	lw $t3 0($t0) # t3 = target.id
	lw $t4 4($t0) # t4 = target.points
	move $t5 $t0 # $t5 = target.add
find_target:
	lw $t1 4($t0)  # $t1 = points
	lw $t2 0($t0)  # $t2 = id
  #blt $t1 9 next
	#beq $t1 4 dont_change_target
  #beq $t1 2 dont_change_target
  #beq $t1 1 dont_change_target
  #beq $t1 10 dont_change_target
  #ble $t1 $t4 dont_change_target
	beq $t4 4 dont_change_target
	beq $t4 10 change_target
	beq $t1 10 dont_change_target
	beq $t1 2 dont_change_target
	ble $t1 $t4 dont_change_target
	change_target:
	move $t3 $t2
	move $t4 $t1
	move $t5 $t0
  next:
dont_change_target:
	add $t0 $t0 16
	lw $t1 0($t0)
	bne $t1 $0 find_target
	move $t0 $t5
decide_type:
	lw $t1 4($t0)
	move $a0 $t0
  sw $t1 PRINT_INT

	beq $t1 10 chase_cherry
	beq $t1 6 cahse_loquat
	beq $t1 4 chase_guava
	beq $t1 2 chase_mango
	beq $t1 1 chase_lemon
chase_cherry:
	jal guava_and_cherry
	j energy
chase_mango:
	jal lemon_mango
	j energy
chase_guava:
	jal guava_and_cherry
	j energy
chase_lemon:
	jal lemon_mango
	j energy
cahse_loquat:
	jal lemon_mango
	j energy
energy:
	lw $t3 GET_ENERGY
	bgt $t3 50 initial_position
	lw $t3 requested_puzzle
	beq $zero $t3 puzzle
	j initial_position

puzzle:
	la $t0 puzzle_grid
	sw $t0 REQUEST_PUZZLE
	li $t0 1
	sw $t0 requested_puzzle
	j initial_position


# a0: the address of the target fruit
lemon_mango:
	sub $sp $sp 20
	sw $ra 0($sp)
  sw $s0 4($sp)
  sw $s1 8($sp)
  sw $s2 12($sp)
  sw $s3 16($sp)
lemon:
	lw $s1 8($a0)
	lw $s0 BOT_X  # $t2 = bot_x
	sub $s2 $s1 $s0  # $t2 = distance = fruit - bot
	bne $s2 0 left_or_right
	#blt $s2 -1 left_or_right
	li $s3 10
	sw $s3 VELOCITY
	li $s3 -90
	sw $s3 ANGLE
	li $s3 1
	sw $s3 ANGLE_CONTROL
	lw $s3 BOT_Y
	ble $s3 250 stop
	li $s3 10
	j set
left_or_right:
	ble $s1 $s0 move_left
	j move_right
move_left:
	li $s3 180
	sw $s3 ANGLE
	li $s3 1
	sw $s3 ANGLE_CONTROL
	ble $s2 -20 set10
	ble $s2 -5 set5
	ble $s2 -3 set2
	j set1
move_right:
	li $s3 0
	sw $s3 ANGLE
	li $s3 1
	sw $s3 ANGLE_CONTROL
	bge $s2 20 set10
	bge $s2 5 set5
	bge $s2 3 set2
	j set1
stop:
	li $s3 0
	j set
set1:
	li $s3 1
	j set
set2:
	li $s3 2
	j set
set5:
	li $s3 5
	j set
set10:
	li $s3 10
	j set
set:
	sw $s3 VELOCITY
	jal get_position
	beq $v0 $0 return_lemon
	lw $s0 12($v0)
	lw $s1 BOT_Y
	bgt $s0 $s1 return_lemon
	move $a0 $v0
	j lemon
return_lemon:
	lw $ra 0($sp)
  lw $s0 4($sp)
  lw $s1 8($sp)
  lw $s2 12($sp)
  lw $s3 16($sp)
  add $sp $sp 20
  jr $ra


guava_and_cherry:
	sub $sp $sp 32
	sw $ra 0($sp)
	sw $s0 4($sp)
	sw $s1 8($sp)
	sw $s2 12($sp)
	sw $s3 16($sp)
	sw $s4 20($sp)
	sw $s5 24($sp)
	sw $s6 28($sp)
	lw $s0 8($a0) #s0 = x;
	lw $s1 12($a0) #s1 = y;
calculate_speed:
	sw $0 cherry_calculation
	lw $s2 TIMER
	add $s2 $s2 20
	sw $s2 TIMER
loop:
	lw $s2 cherry_calculation
	bne $s2 $0 continue
	j loop
continue:
	sw $0 cherry_calculation
	jal get_position
	beq $v0 $0 return_cherry
	move $a0 $v0
	lw $s2 8($a0) #s2 = new_x;
	lw $s3 12($a0) #s3 = new_y;
	lw $s4 BOT_Y
	bgt $s3 $s4 return_cherry
	sub $s5 $s4 $s3
	sub $s6 $s2 $s0
	mul $s5 $s5 $s6
	sub $s6 $s3 $s1
	div $s5 $s6
	mfhi $s5
	add $s5 $s5 $s0
	bgt $s5 300 if1 #s5 = target_x
	blt $s5 0 if2
	j cherry_left_or_right
if1:
	sub $s5 $s5 300
	j cherry_left_or_right
if2:
	add $s5 $s5 300
	j cherry_left_or_right
cherry_left_or_right:
	bge $s5 295 return_cherry
	ble $s5 5 return_cherry
	lw $s2 BOT_X
	sub $s2 $s5 $s2 #s2 = botx - target_x
	bge $s2 1 cherry_right
	blt $s2 -1 cherry_left
	j cherry_wait
cherry_left:
	li $s3 180
	sw $s3 ANGLE
	li $s3 1
	sw $s3 ANGLE_CONTROL
	ble $s2 -20 cherry_set10
	ble $s2 -5 cherry_set5
	ble $s2 -3 cherry_set2
	j cherry_set1
cherry_right:
	li $s3 0
	sw $s3 ANGLE
	li $s3 1
	sw $s3 ANGLE_CONTROL
	bge $s2 20 cherry_set10
	bge $s2 5 cherry_set5
	bge $s2 3 cherry_set2
	j cherry_set1
cherry_set1:
	li $s3 1
	j cherry_set
cherry_set2:
	li $s3 2
	j cherry_set
cherry_set5:
	li $s3 5
	j cherry_set
cherry_set10:
	li $s3 10
	j cherry_set
cherry_set:
	sw $s3 VELOCITY
	j calculate_speed
cherry_wait:
	li $s3 0
	sw $s3 VELOCITY
	jal get_position
	move $a0 $v0
	beq $v0 $0 return_cherry
	lw $s2 BOT_Y
	lw $s3 12($v0)
	bgt $s3 $s2 return_cherry
	j cherry_wait
return_cherry:
	lw $ra 0($sp)
	lw $s0 4($sp)
	lw $s1 8($sp)
	lw $s2 12($sp)
	lw $s3 16($sp)
	lw $s4 20($sp)
	lw $s5 24($sp)
	lw $s6 28($sp)
	add $sp $sp 32
	jr $ra




# a0: old address of the target fruit
# v0: new address of the target fruit, null if does not exist.
get_position:
	sub $sp $sp 16
	sw $ra 0($sp)
	sw $s0 4($sp)
	sw $s1 8($sp)
	sw $s2 12($sp)
	lw $s0 0($a0)
	la $s1 fruit_data
	sw $s1 FRUIT_SCAN
get_id:
	lw $s2 0($s1)
	beq $s2 $0 return_false
	beq $s2 $s0 return_position
	add $s1 $s1 16
	j get_id
return_position:
	move $v0 $s1
	lw $ra 0($sp)
	lw $s0 4($sp)
	lw $s1 8($sp)
	lw $s2 12($sp)
	add $sp $sp 16
#	sw $v0 PRINT_INT
	jr $ra
return_false:
	move $v0 $0
	lw $ra 0($sp)
	lw $s0 4($sp)
	lw $s1 8($sp)
	lw $s2 12($sp)
	add $sp $sp 16
#	sw $v0 PRINT_INT
	jr $ra



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
	ble $s1 250 return_smash
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

.data

# Syscall constants
PRINT_INT = 1
PRINT_STRING = 4
PRINT_CHAR = 11

node1: .word 0 1 node2
node2: .word 2 3 node3
node3: .word 4 5 0

# Global variables (those things you are never supposed to use)

.globl num_rows
num_rows: .word 16
.globl num_cols
num_cols: .word 16


# Puzzles

.align 2
puzzle_0:
	.ascii "XDTUOHTIWEZGCDHN"
	.ascii "DLANGUAGEDUWCPQG"
	.ascii "EOADHSILGNERWNQH"
	.ascii "ILJFNHORIZONTALA"
	.ascii "NHDAKJBSELFIETGD"
	.ascii "ACPCBDGEHELLONGV"
	.ascii "PROCVKZBDLROWHTB"
	.ascii "MASOXSHYBMOLLEHE"
	.ascii "OETMTKGMOIXFROMD"
	.ascii "CSIPRNXEIJACEUWA"
	.ascii "CENAEASIKFGHKMCM"
	.ascii "ARGHNHEFFDMYYYQX"
	.ascii "OTBGDTGLLGOJBVIZ"
	.ascii "AKBEXEAEVQGTDQMR"
	.ascii "LJODSHPSHTQEVRIL"
	.ascii "GHEIWUGUANROSAGH"

# Constants

puzzle_word: .asciiz "LANGUAGE"
word_1: .asciiz "HELLOWORLD"
word_inv: .asciiz "RILHGAR"

# Strings for printing purposes

intro_str1: .asciiz "Finding word LANGUAGE\n"
intro_str2: .asciiz "\nFinding word HELLOWORLD\n"
intro_str3: .asciiz "\nFinding word RILHGAR\n"

pll_no_word_str: .asciiz "No word in linked list\n"

# Node stuff

NODE_SIZE = 12

# Stores the address for the next node to allocate
new_node_address: .word node_memory
# Don't put anything below this just in case they malloc more than 4096
node_memory: .space 4096


.text




main:
	sub	$sp, $sp, 8
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)

# word_0 search_neighbors
	la	$a0, intro_str1
	jal	print_string

	li	$v0, 0			# Set $v0 to 0 to confirm actually returned non-zero
	la	$a0, puzzle_0
	la	$a1, puzzle_word
	li	$a2, 0
	li	$a3, 0
	jal	solve_puzzle

	la	$a0, puzzle_0
	move	$a1, $v0
	jal	print_linked_list


find_inv_end:
	lw	$ra, 0($sp)
	lw	$s0, 4($sp)
	add	$sp, $sp, 8
	jr	$ra

.data

## Node *
## search_neighbors(char *puzzle, const char *word, int row, int col) {
##     if (word == NULL) {
##         return NULL;
##     }
##     for (int i = 0; i < 4; i++) {
##         int next_row = row + directions[i][0];
##         int next_col = col + directions[i][1];
##         // boundary check
##         if ((next_row > -1) && (next_row < num_rows) && (next_col > -1) &&
##             (next_col < num_cols)) {
##             if (puzzle[next_row * num_cols + next_col] == *word) {
##                 if (*(word + 1) == '\0') {
##                     return set_node(next_row, next_col, NULL);
##                 }
##                 // mark the spot on puzzle as visited
##                 puzzle[next_row * num_cols + next_col] = '*';
##                 // search for next char in the word
##                 Node *next_node =
##                     search_neighbors(puzzle, word + 1, next_row, next_col);
##                 // unmark
##                 puzzle[next_row * num_cols + next_col] = *word;
##                 // if there is a valid neighbor, return the linked list
##                 if (next_node) {
##                     return set_node(next_row, next_col, next_node);
##                 }
##             }
##         }
##     }
##     return NULL;
## }
intro_str1: .asciiz "Finding word LANGUAGE\n"
intro_str2: .asciiz "\nFinding word HELLOWORLD\n"
intro_str3: .asciiz "\nFinding word RILHGAR\n"

pll_no_word_str: .asciiz "No word in linked list\n"

.globl directions
directions:
    .word -1  0
    .word  0  1
    .word  1  0
    .word  0 -1

PRINT_INT = 1
PRINT_STRING = 4
PRINT_CHAR = 11

.text
.globl solve_puzzle
solve_puzzle:
    sub $sp $sp 20
    sw $ra 0($sp)
    sw $s0 4($sp)
    sw $s1 8($sp)
    sw $s2 12($sp)
    sw $s3 16($sp)
    lb $s1 0($a1)
    move $s2 $a2
    move $s3 $a3
    move $a1 $a2
    move $a2 $a3
    la $s0 get_char
    jalr $s0
    bne $s1 $v0 not_target
    move $a3 $s3
    add $a3 $a3 -1
    move $a2 $s2
    la $a1 puzzle_word
    jal search_neighbors
    bne $v0 $0 return_puzzle
not_target:
    add $a3 $s3 1
    move $a2 $s2
    lw $s0 num_cols
    bne $a3 $s0 no_increase_row
    li $a3 0
    add $a2 $a2 1
    lw $s0 num_rows
    blt $a2 $s0 no_increase_row
    move $v0 $0
    j return_puzzle
no_increase_row:
    la $a1 puzzle_word
    jal solve_puzzle
return_puzzle:
    lw $ra 0($sp)
    lw $s0 4($sp)
    lw $s1 8($sp)
    lw $s2 12($sp)
    lw $s3 16($sp)
    add $sp $sp 20
    jr $ra




.globl search_neighbors
search_neighbors:
	# Your code goes here :)
    bne $a1 $zero endif1
    jr $ra
endif1:
    sub $sp $sp 40
    sw $ra 0($sp)
    sw $s0 4($sp)
    sw $s1 8($sp)
    sw $s2 12($sp)
    sw $s3 16($sp)
    sw $s4 20($sp)
    sw $s5 24($sp)
    sw $s6 28($sp)
    sw $s7 32($sp)
    sw $s8 36($sp)
    li $s0 0  #$s0 = i
    move $s5 $a0
    move $s6 $a1
    move $s8 $a2
    move $s7 $a3
loop:
    bge $s0 4 endloop
    la $s1 directions
    mul $s2 $s0 8
    add $s2 $s1 $s2
    lw $s1 0($s2)  # $s1 = next_row
    add $s1 $s8 $s1
    lw $s2 4($s2)
    add $s2 $s2 $s7 # $s2 = next_col
    lw $s3 num_rows # $s3 = num_rows
    lw $s4 num_cols  # $s4 = num_cols
    bgt $s1 -1 if1
    add $s1 $s3 -1
if1:
    bgt $s2 -1 if2
    add $s2 $s4 -1
if2:
    blt $s1 $s3 if3
    li $s1 0
if3:
    blt $s2 $s4 if4
    li $s2 0
if4:
    move $a0 $s5
    move $a1 $s1
    move $a2 $s2
    jal get_char
    lb $s3 0($s6) # $s3 = *word
    bne $s3 $v0 endif
    lb $s3 1($s6) # $s3 = *(word + 1)
    bne $s3 $zero endif3
    move $a0 $s1
    move $a1 $s2
    move $a2 $zero
    jal set_node
    j return
endif3:
    move $a0 $s5
    move $a1 $s1
    move $a2 $s2
    li $a3 '*'
    jal set_char
    move $a0 $s5
    add $a1 $s6 1
    move $a2 $s1
    move $a3 $s2
    jal search_neighbors
    move $s3 $v0  # $s3 = next_node
    move $a0 $s5
    move $a1 $s1
    move $a2 $s2
    lb $a3 0($s6)
    jal set_char
    beq $s3 $zero endif
    move $a0 $s1
    move $a1 $s2
    move $a2 $s3
    jal set_node
    j return
endif:
    add $s0 1
    j loop
endloop:
    move $v0 $zero
return:
    lw $ra 0($sp)
    lw $s0 4($sp)
    lw $s1 8($sp)
    lw $s2 12($sp)
    lw $s3 16($sp)
    lw $s4 20($sp)
    lw $s5 24($sp)
    lw $s6 28($sp)
    lw $s7 32($sp)
    lw $s8 36($sp)
    add $sp $sp 40
    jr $ra

# Prints an array of chars out. Uses num_rows and num_cols. Feel free to use
# for debugging.
# Arguments:
#   $a0: pointer to beginning of array
# Returns: nothing
.globl print_array
print_array:
    sub $sp, $sp, 16
    sw  $ra, 0($sp)
    sw  $s0, 4($sp)     # $s0 = array
    sw  $s1, 8($sp)     # $s1 = row
    sw  $s2, 12($sp)        # $s2 = col
    move    $s0, $a0

    li  $s1, 0
pa_row_loop:
    lw  $t0, num_rows
    bge $s1, $t0, pa_row_loop_end

    li  $s2, 0
pa_col_loop:
    lw  $t0, num_cols
    bge $s2, $t0, pa_col_loop_end

    mul $a0, $s1, $t0       # $t1 = row * num_cols
    add $a0, $a0, $s2       # $t1 = row * num_cols + col
    add $a0, $s0, $a0       # $a0 = &array[row * num_cols + col]

    lb  $a0, 0($a0)     # $a0 = array[row * num_cols + col]
    jal print_char_and_space

    add $s2, $s2, 1
    j   pa_col_loop

pa_col_loop_end:
    jal print_newline
    add $s1, $s1, 1
    j   pa_row_loop

pa_row_loop_end:
    jal print_newline
    lw  $ra, 0($sp)
    lw  $s0, 4($sp)
    lw  $s1, 8($sp)
    lw  $s2, 12($sp)
    add $sp, $sp, 16
    jr  $ra

# Prints the strings that was stored in the linked list. Feel free to use for
# debugging.
# Arguments:
#   $a0: pointer to beginning of puzzle
#   $a1: pointer to head of linked list
# Returns: nothing
.globl print_linked_list
print_linked_list:
    bne $a1, 0, pll_start
    la  $a0, pll_no_word_str
    j   print_string

pll_start:
    move    $t0, $a0        # $t0 = $a0 = puzzle

pll_loop:
    beq $a1, 0, pll_return

    lw  $t1, 0($a1)     # $t1 = curr->row
    lw  $t2, 4($a1)     # $t2 = curr->col
    lw  $a0, num_cols       # $a0 = num_cols
    mul $a0, $t1, $a0       # $a0 = curr->row * num_cols
    add $a0, $a0, $t2       # $a0 = curr->row * num_cols + curr->col
    add $a0, $a0, $t0       # $a0 = &puzzle[curr->row * num_cols + curr->col]

    lb  $a0, 0($a0)     # $a0 = puzzle[curr->row * num_cols + curr->col]
    li  $v0, PRINT_CHAR
    syscall
    li  $a0, ' '
    syscall
    li  $a0, '('
    syscall
    move    $a0, $t1
    li  $v0, PRINT_INT
    syscall
    li  $a0, ','
    li  $v0, PRINT_CHAR
    syscall
    move    $a0, $t2
    li  $v0, PRINT_INT
    syscall
    li  $a0, ')'
    li  $v0, PRINT_CHAR
    syscall
    li  $a0, '\n'
    syscall

    lw  $a1, 8($a1)
    j   pll_loop

pll_return:
    jr  $ra



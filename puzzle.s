.text

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
    ble $s1 -1 endif
    bge $s1 $s3 endif
    ble $s2 -1 endif
    bge $s2 $s4 endif
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


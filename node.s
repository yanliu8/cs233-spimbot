.data
NODE_SIZE = 12
.text
# Allocates "memory" for a new node using the space in node_memory.
# Arguments: none
# Returns: pointer to new node
.globl allocate_new_node
allocate_new_node:
    lw  $v0, new_node_address
    add $t0, $v0, NODE_SIZE
    sw  $t0, new_node_address
    jr  $ra

# Gets char from a 2D array
# Arguments:
#   $a0: pointer to beginning of 2D array
#   $a1: row
#   $a2: col
# Returns: char at that location
.globl get_char
get_char:
    lw  $v0, num_cols
    mul $v0, $a1, $v0   # row * num_cols
    add $v0, $v0, $a2   # row * num_cols + col
    add $v0, $a0, $v0   # &array[row * num_cols + col]
    lb  $v0, 0($v0) # array[row * num_cols + col]
    jr  $ra

# Sets a char in a 2D array
# Arguments:
#   $a0: pointer to beginning of 2D array
#   $a1: row
#   $a2: col
#   $a3: char to store into array
# Returns: nothing
.globl set_char
set_char:
    lw  $v0, num_cols
    mul $v0, $a1, $v0   # row * num_cols
    add $v0, $v0, $a2   # row * num_cols + col
    add $v0, $a0, $v0   # &array[row * num_cols + col]
    sb  $a3, 0($v0) # array[row * num_cols + col] = c
    jr  $ra

## Node *
## set_node(int row, int col, Node *next) {
##     // Call allocate_new_node() instead (see node_main.s)
##     Node *node = new Node();
##     node->row = row;
##     node->col = col;
##     node->next = next;
##     return node;
## }

.globl set_node
set_node:
	# Your code goes here :)
    sub $sp $sp 4
    sw $ra 0($sp)
    jal allocate_new_node
    lw $ra 0($sp)
    add $sp $sp 4
    sw $a0 0($v0)
    sw $a1 4($v0)
    sw $a2 8($v0)
    			# Don't forget to replace this!
	jr	$ra

## void
## remove_node(Node **head, int row, int col) {
##     for (Node **curr = head; *curr != NULL;) {
##         Node *entry = *curr;
##         if (entry->row == row && entry->col == col) {
##             *curr = entry->next;
##             return;
##         }
##         curr = &entry->next;
##     }
## }

.globl remove_node
remove_node:
	# Your code goes here :)
    move $t0 $a0
loop1:
    lw $t1 0($t0)
    beq $t1 $zero end_loop1

    lw $t2 0($t1)
    lw $t3 4($t1)
    bne $t3 $a2 end_if
    bne $t2 $a1 end_if
    lw $t4 8($t1)
    sw $t4 0($t0)
    jr $ra
end_if:
    add $t0 $t1 8
    j loop1
end_loop1:
	jr	$ra

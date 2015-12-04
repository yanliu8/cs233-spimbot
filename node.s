.text

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

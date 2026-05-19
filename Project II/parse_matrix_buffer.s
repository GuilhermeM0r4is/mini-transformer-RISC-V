# Assumes the matrix is stored in the buffer as space-separated integers.
# Assumes columns are separated by 1 space (' '), and rows by 1 newline ('\n').
# Assumes only signed integers are provided.
# (in/out) a0: address of the matrix to fill (int*)
# (out)    a1: number of rows in the matrix (int)
# (in)     a1: address of the buffer containing the matrix data (char*)

parse_matrix_buffer: 
    
    mv t0, a1 # Store the address of the destination buffer
    mv t1, a0 # Store the address of the buffer containing the matrix data
    
    li t3, 0 # Row counter
    li t4, 0 # Number accumulator
    li t6, 1 # "Is negative number" flag (1 = false, -1 = true)

parsing_loop:
    
    lbu t2, 0(t1) # Extract the character's ASCII value
    addi t1, t1, 1 # Move to the next character to parse (byte by byte)
    
    beqz t2, end_parsing # If character is EOF (=0), all file content has been read
    
    li t5, 32 # Space ASCII value
    beq t5, t2, acc_number # If character is a space
    
    li t5, 10 # Newline ASCII value
    beq t5, t2, next_line # If character is a newline
    
    li t5, 45 # If character is a hyphen (minus sign)
    beq t5, t2, negative_flag
    
    # If none of the previous branches were triggered, then the character is a digit
    
    addi t2, t2, -48 # Subtract character "0" from the digit to obtain the int value
    
    li t5, 10 
    mul t4, t4, t5 # Make space for the new digit (lowest base,since read right > left)
    add t4, t4, t2 # Add new digit to the rest of the number
    
    j parsing_loop

next_line:
    
    addi t3, t3, 1 # Moving to next row, so increment row counter by one
    
    # Falling into the acc_number label is intentional, so as to not repeat code
    
acc_number:
    
    mul t4, t4, t6 # Negate value if flag is true, does nothing otherwise
    li t6, 1 # Reset the "negative number" flag
    
    sw t4, 0(t0) # Store the number that's been formed in destination buffer
    addi t0, t0, 4 # Move pointer to the next word in destination buffer
    
    li t4, 0 # Reset the number accumulator
    j parsing_loop
    
negative_flag:
    
    li t6, -1 # Set "negative number" flag as true
    j parsing_loop
    
end_parsing:
    
    mv a1, t3 # Store the number of rows in the matrix inside a1
    ret

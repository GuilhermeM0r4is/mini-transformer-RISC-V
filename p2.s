###########################################################################
# UPPER BOUND CONSTANTS FOR STATIC MEMORY RESERVATION
###########################################################################
.equ CONST_DIMENSION 4
.equ CONST_BUFFER_SIZE 1024
.equ CONST_MAX_VOCAB_TOKENS 100
.equ CONST_MAX_INPUT_TOKENS 10

###########################################################################
# SYSTEM CALL CONSTANTS
###########################################################################
.equ CONST_SYSCALL_PRINT_INT 1
.equ CONST_SYSCALL_PRINT_STRING 4
.equ CONST_SYSCALL_PRINT_CHAR 11
.equ CONST_SYSCALL_EXIT 10
.equ CONST_SYSCALL_EXIT2 93
.equ CONST_SYSCALL_OPEN 1024
.equ CONST_SYSCALL_CLOSE 57
.equ CONST_SYSCALL_READ 63
.equ CONST_SYSCALL_WRITE 64

###########################################################################
# ASCII CHARACTHER CONSTANTS
###########################################################################
.equ CONST_CHAR_EOF 0
.equ CONST_CHAR_SPACE 32
.equ CONST_CHAR_NEWLINE 10
.equ CONST_CHAR_HYPHEN 45
.equ CONST_CHAR_ZERO 48

###########################################################################
# DATA sECTION WITH STATIC MEMORY RESERVATIONS.
###########################################################################
.data
VOCABULARY_FILENAME:     .string "vocab.txt"
EMBEDDINGS_FILENAME:     .string "embeddings.txt"
INPUT_FILENAME:          .string "input.txt"

W_Q_FILENAME:            .string "W_Q.txt"
W_K_FILENAME:            .string "W_K.txt"
W_V_FILENAME:            .string "W_V.txt"

VOCAB_BUFFER:            .zero CONST_BUFFER_SIZE                              # Contents of the vocabulary file
INPUT_BUFFER:            .zero CONST_BUFFER_SIZE                              # Contents of the input file
MATRIX_BUFFER:           .zero CONST_BUFFER_SIZE                              # Contents of a matrix file (used for W_Q, W_K, W_V, and embeddings)

INPUT_INDICES_VECTOR:    .zero (CONST_MAX_INPUT_TOKENS * 4)                   # Vector of input token indices (#inputs x 4 bytes)
SCORES_VECTOR:           .zero (CONST_MAX_INPUT_TOKENS * 4)                   # Vector of scores (#tokens x 4 bytes)

INPUT_TOTAL_TOKENS:      .word 0                                              # Number of tokens in the input
VOCAB_TOTAL_TOKENS:      .word 0                                              # Number of tokens in the vocabulary

VOCAB_EMBEDDINGS_MATRIX: .zero (CONST_MAX_VOCAB_TOKENS * CONST_DIMENSION * 4) # Embedding matrix (#tokens x dimension x 4 bytes)
INPUT_EMBEDDINGS_MATRIX: .zero (CONST_MAX_INPUT_TOKENS * CONST_DIMENSION * 4) # Embedding matrix (#tokens x dimension x 4 bytes)
W_Q_MATRIX:              .zero (CONST_DIMENSION * CONST_DIMENSION * 4)        # W_Q matrix (dimension x dimension x 4 bytes)
W_K_MATRIX:              .zero (CONST_DIMENSION * CONST_DIMENSION * 4)        # W_K matrix (dimension x dimension x 4 bytes)
W_V_MATRIX:              .zero (CONST_DIMENSION * CONST_DIMENSION * 4)        # W_V matrix (dimension x dimension x 4 bytes)
Q_MATRIX:                .zero (CONST_MAX_INPUT_TOKENS * CONST_DIMENSION * 4) # Q matrix (#tokens x dimension x 4 bytes)
K_MATRIX:                .zero (CONST_MAX_INPUT_TOKENS * CONST_DIMENSION * 4) # K matrix (#tokens x dimension x 4 bytes)
V_MATRIX:                .zero (CONST_MAX_INPUT_TOKENS * CONST_DIMENSION * 4) # V matrix (#tokens x dimension x 4 bytes)

.text
main:
    ###########################################################################
    # Read vocabulary
    ###########################################################################
    la a0, VOCABULARY_FILENAME
    la a1, VOCAB_BUFFER
    li a2, CONST_BUFFER_SIZE
    jal ra, read_file
    
    ###########################################################################
    # Read input
    ###########################################################################
    la a0, INPUT_FILENAME
    la a1, INPUT_BUFFER
    li a2, CONST_BUFFER_SIZE ### In case corruption occurs in a2, removable line(s)
    jal ra, read_file

    ###########################################################################
    # Read W_Q matrix
    ###########################################################################
    la a0, W_Q_FILENAME
    la a1, MATRIX_BUFFER
    li a2, CONST_BUFFER_SIZE ###
    jal ra, read_file

    ###########################################################################
    # Parse W_Q matrix from buffer
    ###########################################################################
    la a0, W_Q_MATRIX
    la a1, MATRIX_BUFFER ## In case corruption occured in a1, removable as well
    jal ra, parse_matrix_buffer

    ###########################################################################
    # Read W_K matrix
    ###########################################################################
    la a0, W_K_FILENAME
    la a1, MATRIX_BUFFER ##
    li a2, CONST_BUFFER_SIZE ###
    jal ra, read_file

    ###########################################################################
    # Parse W_K matrix from buffer
    ###########################################################################
    la a0, W_K_MATRIX
    la a1, MATRIX_BUFFER ##
    jal ra, parse_matrix_buffer

    ###########################################################################
    # Read W_V matrix
    ###########################################################################
    la a0, W_V_FILENAME
    la a1, MATRIX_BUFFER ##
    li a2, CONST_BUFFER_SIZE ###
    jal ra, read_file

    ###########################################################################
    # Parse W_V matrix from buffer
    ###########################################################################
    la a0, W_V_MATRIX
    la a1, MATRIX_BUFFER ##
    jal ra, parse_matrix_buffer

    ###########################################################################
    # Read embeddings matrix
    ###########################################################################
    la a0, EMBEDDINGS_FILENAME
    la a1, MATRIX_BUFFER ##
    li a2, CONST_BUFFER_SIZE ###
    jal ra, read_file

    ###########################################################################
    # Parse vocabulary embeddings matrix from buffer
    ###########################################################################
    la a0, VOCAB_EMBEDDINGS_MATRIX
    la a1, MATRIX_BUFFER ##
    jal ra, parse_matrix_buffer

    ###########################################################################
    # Convert input tokens to indices
    ###########################################################################
    la a0, INPUT_INDICES_VECTOR
    la a2, INPUT_BUFFER
    la a3, VOCAB_BUFFER
    jal ra, tokens_to_indices
    
    ###########################################################################
    # Build input embeddings matrix
    ###########################################################################
    # TODO

    ###########################################################################
    # Build matrix Q
    ###########################################################################
    # TODO

    ###########################################################################
    # Build matrix K
    ###########################################################################
    # TODO

    ###########################################################################
    # Build matrix V
    ###########################################################################
    # TODO

    # Compute scores for the last input token
    la a0, SCORES_VECTOR
    la a1, Q_MATRIX
    la a2, K_MATRIX
    la a3, INPUT_TOTAL_TOKENS
    lw a3, 0(a3)               # Loads the value from the address
    li a4, CONST_DIMENSION
    addi a5, a3, -1            # Remove one to use it for a5
    jal ra, compute_scores

    # Get the highest score index using argmax
    la a1, SCORES_VECTOR       # Loads the updated vector
    la a2, INPUT_TOTAL_TOKENS  
    lw a2, 0(a2)               # Gets the value from the memory of size of vector
    jal ra, argmax
    bnez a0, exit_with_code    # If a0 != 0, then argmax failed and exits
    
    # Select chosen vector in V using the index from argmax
    mv a4, a1                  # Moves the value from argmax to a4
    la a1, V_MATRIX
    la a2, INPUT_TOTAL_TOKENS  # Reloads the values for a2, as to follow the
    lw a2, 0(a2)               # calling-convention of RISC-V even tho it might not
    li a3, CONST_DIMENSION     # be totally needed as argmax doesn't change its value
    jal ra, select_vector_in_matrix

    # Pick the next token in the vocabulary with the highest score
    beqz a0, exit_with_code    # If a0 = 0 here, then it means the select_vector fucnt
                               # got an error with the first conditions
    la a1, VOCAB_EMBEDDINGS_MATRIX
    la a2, VOCAB_TOTAL_TOKENS  # As vocab_total_tokens isn't a constant but
    lw a2, 0(a2)               # rather a stored variable in the RAM 
    jal ra, decide_next_token
    beqz a0, exit_with_code
    jal ra, print_predicted_token # Prints the decided token and ends
´
    # Terminate program successfully
    li a0, 0
    j exit_with_code                                # Exit with code 0

###########################################################################
# HERE WE HAVE THE LIST OF ALL THE AUXILIARY FUNCTIONS USED FOR MAIN
###########################################################################

# Read from a text file into a buffer.
# (in)     a0: filename address (char*)
# (in/out) a1: destination buffer
# (in)     a2: maximum number of bytes to read
read_file:
    mv t1, a1          # Store the destination buffer for future use
    li a1, 0           # No special flags value for Open system call
    li a7, 1024        # Open syscall
    ecall              #a0= file descriptor
    mv t0, a0          # Store the file descriptor for future use (next ecall would destroy it)
    li a7, 63          # Read system call
    mv a1, t1          # Restore the destination buffer value to a1 for Read syscall
    ecall              # a0= number of bytes read
    mv a0, t0          # Restore the file descriptor to a0 for Close system call
    li a7, 57          # Close system call
    ecall              # a0 is unchanged after this operation
    jr ra              # Return to the caller

# Assumes the matrix is stored in the buffer as space-separated integers.
# Assumes columns are separated by 1 space (' '), and rows by 1 newline ('\n').
# Assumes only signed integers are provided.
# (in/out) a0: address of the matrix to fill (int*)
# (out)    a1: number of rows in the matrix (int)
# (in)     a1: address of the buffer containing the matrix data (char*)
parse_matrix_buffer: 
    mv t0, a0          # Store the address of the destination buffer
    mv t1, a1          # Store the address of the buffer containing the matrix data
    li t3, 0           # Row counter
    li t4, 0           # Number accumulator
    li t6, 1           # "Is negative number" flag (1 = false, -1 = true)
parsing_loop:
    lbu t2, 0(t1)      # Extract the character's ASCII value
    addi t1, t1, 1     # Move to the next character to parse (byte by byte)
    beqz t2, end_parsing # If character is EOF (=0), all file content has been read
    li t5, 32          # Space ASCII value
    beq t5, t2, acc_number # If character is a space
    li t5, 10          # Newline ASCII value
    beq t5, t2, next_line # If character is a newline
    li t5, 45          # If character is a hyphen (minus sign)
    beq t5, t2, negative_flag
    # If none of the previous branches were triggered, then the character is a digit
    addi t2, t2, -48   # Subtract character "0" from the digit to obtain the int value
    li t5, 10 
    mul t4, t4, t5     # Make space for the new digit (lowest base,since read right > left)
    add t4, t4, t2     # Add new digit to the rest of the number
    j parsing_loop
next_line:
    addi t3, t3, 1     # Moving to next row, so increment row counter by one
    # Falling into the acc_number label is intentional, so as to not repeat code
acc_number:
    mul t4, t4, t6     # Negate value if flag is true, does nothing otherwise
    li t6, 1           # Reset the "negative number" flag
    sw t4, 0(t0)       # Store the number that's been formed in destination buffer
    addi t0, t0, 4     # Move pointer to the next word in destination buffer
    li t4, 0           # Reset the number accumulator
    j parsing_loop
negative_flag:
    li t6, -1          # Set "negative number" flag as true
    j parsing_loop
end_parsing:
    mv a1, t3          # Store the number of rows in the matrix inside a1
    ret

# Converts the input tokens into their corresponding indices in the vocabulary.
# (in/out) a0: address of input indices vector to fill (int*)
# (out)    a1: size of input indices vector (number of tokens in input)
# (in)     a2: address to input buffer
# (in)     a3: address to vocabulary buffer
tokens_to_indices:
    # TODO

# (in/out) a0: address of the output matrix to fill (int*)
# (in)     a1: address of the vocabulary embeddings matrix (int*)
# (in)     a2: address of the input indices array (int*)
# (in)     a3: number of tokens in the input (int)
build_input_embeddings_matrix:
    li t0,0    # loop index variable (i=0)
build_input_loop:
    # Checks if all tokens(words) have been processed.
    beq t0, a3, end_build_input_loop
    # Lets say a2 is the array of "words" the memory sees it has numbers,
    # so they work like "word IDS" -> lets say the point of the function is:
    # Read de words Ids array(a2); For each word, we look into our vocabulary 
    # matrix(a1), obtain the row corresponding and then paste it into the final matrix.
    slli t1, t0, 2       # t1 = i4 bytes (offset in the input array)
    add t2, a2, t1       # t2 = base address (a2) + offset (t1)
    lw t3, 0(t2)         # t3 = value of input_indices[i](word ids)
    slli t4,t3,4         # a row has 4x4 bytes (16)
    add t4,a1,t4         # t4 now has the adress containing the wanted row
    slli t5,t0,4         # t5 = i16 bytes
    add t5,a0,t5         # "pointer" to an exact coordenate in the matrix
    lw t6,0(t4)       
    sw t6,0(t5)       
    lw t6,4(t4)       
    sw t6,4(t5)          # Paste row into final matrix:
    lw t6,8(t4)          # obtains the values inside the row
    sw t6,8(t5)          # stores the value inside the output matrix
    lw t6,12(t4)      
    sw t6,12(t5)      
    # When the program runs the only relevant values are the values inside a0, 
    # which are now changed due to the temporary variables.
    addi t0,t0,1         # repeat loop
    j build_input_loop
end_build_input_loop:
    jr ra                #returns to the called function

# (in/out) a0: address of the output matrix to fill (int*)
# (in)     a1: address of the first matrix (int*)
# (in)     a2: #rows of the first matrix (int)
# (in)     a3: #columns of the first matrix (int)
# (in)     a4: address of the second matrix (int*)
# (in)     a5: #rows of the second matrix (int)
# (in)     a6: #columns of the second matrix (int)
matrix_multiply:
    # a_loop is responsible for picking the row of A matrix
    # b_loop picks the collumn of B, b_loop is inside a loop, so once all collumns
    # have been picked and worked on, we go into the next row and repeat the process.
    # main_loop is the loop that does the math for each coordenate of the matrix
    li t0, 0             # i = 0, current row in A
    slli t3, a6, 2       # value refering to move to the next line of B
a_loop:
    beq t0, a2, end_matrix_multiply    # if i == rows of A, every row is done
    mul t4, t0, a3       # here we use this logic to get to know where does the
    slli t4, t4, 2       # A matrix new line start to use it A[i][0]
    add t4, a1, t4
    li t1, 0             # j = 0, current column of B
b_loop:
    beq t1, a6, b_loop_end
    slli t5, t1, 2       # the same way we looked for the new line of A
    add t5, a4, t5       # before, now we look for B[0][j]
    li t2, 0             # main loop index
    li t6, 0             # t6 will store the values -> acumulator
main_loop:       # multiplys the values for that speccific coordenate
    bge t2, a3, end_main_loop
    lw a5, 0(t4)         # pointer for the A, using a5 because its not needed
                         # as it has the same value as a3!
    lw a7, 0(t5)         # pointer for B
    mul a5, a5, a7    
    add t6, t6, a5       # acumulator variable for the multiply
    addi t4, t4, 4       # moves the A pointer to next element
    add t5, t5, t3       # moves the B pointer to the next line
    addi t2, t2, 1       # keeps the cycle going on
    j main_loop
end_main_loop:
    mul t4, t0, a6
    add t4, t4, t1
    slli t4, t4, 2
    add t4, a0, t4
    sw t6, 0(t4)        # C[i][j]=value accumulator
    addi t1, t1, 1      # advances a collumn in the same row
    j b_loop            # repeats b_loop
b_loop_end:
    addi t0,t0,1        # all collumns of the A row have been completed
    j a_loop
end_matrix_multiply:
    jr ra

# (in/out) a0: address of the output scores vector to fill (int*)
# (in)     a1: address of Q matrix (int*)
# (in)     a2: address of K matrix (int*)
# (in)     a3: #rows of Q and K (int)
# (in)     a4: #columns of Q and K (int)
# (in)     a5: target token index for which we want to compute the score (int)
compute_scores:
    addi sp, sp, -32    # Add free space positions to the stock
    sw s0, 0(sp)        # Stores the different s0-s6 into the stock to not lose them
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw s5, 20(sp)
    sw ra, 24(sp)
    mv s0, a0           # Moves the respective values to the s0-s6, to not have
    mv s1, a1           # them being overwritten in the dot call
    mv s2, a2
    mv s3, a3
    mv s4, a4
    mv s5, a5
    mul t0, s4, s5      # Lines * Collumns to get the value for the adress
    slli t0, t0, 2      # Get the fixed line address -> fixed Q adress
    add s1, s1, t0      # Move the value for the adress to use it
    li t0, 0            # j value to be used for the K matrix adress
compute_scores_loop:
    beq t0, s3, compute_scores_success  # Assures the cycle only runs until it reaches,
                                      # the total number of lines (s3)
    mul t1, s4, t0      # Collumns * J
    slli t1, t1, 2      # Moves to get the address using shift left imm
    add t2, s2, t1      # Adds the value to get the right position
    mv a1, s1        
    mv a2, t2           # Uses a1-a3 on dot auxiliar function by moving the values
    mv a3, s4    
    jal ra, dot         # Jumps to dot with a caller to come back here after finishing
    bnez a0, compute_scores_end  # If != 0, then we have error overflow, and ends
    slli t3, t0, 2      # Moves the 4 bytes for each j value we have to use it for the index
                        # as we can't have the "0" in sw changing
    add t3, t3, s0      # Adds the t3 to the output scores vector index adress
    sw a1, 0(t3)        # Stores the value into the scores vector
    addi t0, t0, 1      # Continues the cycle j++
    j compute_scores_loop
compute_scores_success:
    li a0, 0            # Assures the return code is 0
compute_scores_end:
    lw s0, 0(sp)        # Loads back all the values stores in the stock and
    lw s1, 4(sp)        # uses them to be stored and not lost
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw s5, 20(sp)
    lw ra, 24(sp)       # With the return address back on, we can call ret 
    addi sp, sp, 32     # and clear the pile/stock clearing the memory
    ret

# (out) a0: address of the selected vector (int*)
# (in)  a1: address of matrix (int*)
# (in)  a2: #rows (int)
# (in)  a3: #cols (int)
# (in)  a4: target row
select_vector_in_matrix:
    # This function is like a List[i][j] in python -> pretty simple
    # We just need to assure the a4 conditions before starting the adress change
    bltz a4, select_vector_error     # Assures target row => 0
    bge a4, a2, select_vector_error  # if a4 > a2, then it's out of range that's why
                                     # we need the a2 here to check it
    mul t0, a4, a3      # Gets the target row from argmax and multiplies by collumns
    slli t0, t0, 2      # Mults by the *4 to convert to bytes needed
    add a0, a1, t0      # The adress + displacement to return
    ret
select_vector_error:
    li a0, 0
    ret

# (out) a0: index of the predicted token in the vocabulary (int)
# (in)  a0: address of target vector (int*)
# (in)  a1: vocabulary embeddings address (int*)
# (in)  a2: number of tokens in vocabulary (int)
decide_next_token:
    addi sp, sp, -32    # Add positions to the stock
    sw s0, 0(sp)        # Stores the different s0-s2 and ra into the stock to not
    sw s1, 4(sp)        # lose them and follow RISC-V convention call
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw s5, 20(sp)
    sw ra, 24(sp)
    mv s0, a0           # Moves the respective values to the s0-s6, to not have
    mv s1, a1           # them being overwritten in the dot call
    mv s2, a2
    li a3, CONST_DIMENSION # Setting it in the beginning as dot won't change its value
    li s3, 0            # Value to increment -> j
    li s4, 0x80000000   # The lowest score  
    li s5, 0            # Adress value stored
    # Lowest int number possible, by starting like this we'll be able to not do the
    # cycle one time in the beggining and save up memory and space even tho it has the
    # same speed as the other option
    # Checked this one with AI to see what would be best to implement
decide_next_token_loop:
    beq s3, s2, decide_next_end # Ends the loop when j = number of tokens in vocab
    mv a1, s0           # Assures dot has the needed values to work correctly
    mv a2, s1
    jal ra, dot         # Calls dot to check dot product
    bnez a0, decide_next_error # dot function failed
    ble a1, s4, decide_next_token_next
    mv s4, a1           # New biggest value = dot given value
    mv s5, s1           # Saves the current address as the biggest one
decide_next_token_next:
    addi s3, s3, 1      # Increments for next loop
    addi s1, s1, 16     # Moves to next line of matrix and reloops
    j decide_next_token_loop
decide_next_error:
    li s5, 0
decide_next_end:
    mv a0, s5
    lw s0, 0(sp)        # Loads back all the values stores in the stock and
    lw s1, 4(sp)        # uses them to be stored and not lost
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw s5, 20(sp)
    lw ra, 24(sp)       # With the return address back on, we can call ret 
    addi sp, sp, 32     # and clear the pile/stock clearing the memory
    ret

#############################################################################################################
# DOT AND ARGMAX AUXILIARY FUNCTIONS
#############################################################################################################

# (in)  a1: address of first vector (int*)
# (in)  a2: address of second vector (int*)
# (in)  a3: length of the vectors (int)
# (out) a0: status code (0 for success, non-zero for error)
# (out) a1: dot product result (int)
dot:
    addi sp, sp, -4
    sw ra, 0(sp)                                    # Save return address on the stack
    # Initialize the result and the loop index.
    mv t0, zero                                     # t0 will hold the result (dot product)
    mv t1, zero                                     # t1 will be our loop index
    # Let's see first if SIZE < 1, and jump to dot_end if that's the case.
    slti t2, a3, 1                                  # t2 = (SIZE < 1)
    beq t2, zero, dot_loop                          # If SIZE >= 1, we can proceed to the loop
    li a0, 50                                       # Set a0 to 50 to indicate an error (invalid size)
    j dot_end                                       # If SIZE < 1, jump to dot_end
dot_loop:
    beq t1, a3, dot_end_loop                        # If t1 == SIZE, we are done
    lw t2, 0(a1)                                    # Load A[t1] into t2
    lw t3, 0(a2)                                    # Load B[t1] into t3
    mul t4, t2, t3                                  # t4 = A[t1] * B[t1]
    # Check if the multiplication of A[t1] and B[t1] overflows
    mulh t5, t2, t3                                 # t5 = high 32 bits of A[t1] * B[t1] (signed)
    srai t6, t4, 31                                 # t6 = sign extension of low 32 bits (0 or -1)
    bne t5, t6, overflow                            # Overflow if high bits != sign extension of low bits
    mv t6, t0                                       # Store the current result in t6 for overflow checking
    add t0, t0, t4                                  # t0 += A[t1] * B[t1]
    # Check if the previous addition caused an overflow
    # Careful: adding negative numbers will correctly result in a negative number, so we need to check for overflow in both directions.
    bgt t6, zero, check_positive_overflow           # If previous result was positive, check for positive overflow
    blt t6, zero, check_negative_overflow           # If previous result was negative, check for negative overflow
    j dot_continue_loop
check_positive_overflow:
    blt t4, zero, dot_continue_loop                 # If we added a negative number, we can't have a positive overflow
    blt t0, zero, overflow                          # If t0 < 0 after adding a positive number, we have an overflow
    j dot_continue_loop
check_negative_overflow:
    bgt t4, zero, dot_continue_loop                 # If we added a positive number, we can't have a negative overflow
    bgt t0, zero, overflow                          # If t0 > 0 after adding a negative number, we have an overflow
    j dot_continue_loop
dot_continue_loop:
    addi a1, a1, 4                                  # Move to the next element in A
    addi a2, a2, 4                                  # Move to the next element in B
    addi t1, t1, 1                                  # t1++
    j dot_loop                                      # Repeat the loop
dot_end_loop:
    li a0, 0                                        # Set a0 to 0 to indicate success
    mv a1, t0                                       # Move the result into a1 for return
    j dot_end                                       # Jump to the end of the function
overflow:
    li a0, 200                                      # Set a0 to 200 to indicate an overflow error
    j dot_end                                       # Jump to the end of the function
dot_end:
    lw ra, 0(sp)                                    # Restore return address
    addi sp, sp, 4                                  # Deallocate stack space
    ret                                             # Return to the caller

# (in)  a1: pointer to int array
# (in)  a2: array length
# (out) a0: status code
# (out) a1: index of the largest element
argmax:
    # Get the index of the maximum value in A, which is of size SIZE.
    # The result will be stored in a0.
    # If here's a draw, return the smallest index among the maximum values.
    addi sp, sp, -4
    sw ra, 0(sp)                                    # Save return address on the stack
    # Initialize the max value and the index of the max value.
    lw t0, 0(a1)                                    # t0 will hold the max value
    mv t1, zero                                     # t1 will hold the index of the max value
    mv t2, zero                                     # t2 will be our loop index
    # Error checking first: if SIZE < 1, we should return 50 to indicate an error.
    slti t3, a2, 1                                  # t3 = (SIZE < 1)
    beq t3, zero, argmax_loop                       # if SIZE >= 1, we can proceed to the loop
    li a0, 50                                       # set a0 to 50 to indicate an error (invalid size)
    j argmax_end                                    # if SIZE < 1, jump to argmax_end
argmax_loop:
    # The actual loop logic.
    beq t2, a2, argmax_end_loop                     # if t2 == SIZE, we are done
    lw t3, 0(a1)                                    # load A[t2] into t3
    ble t3, t0, argmax_next                         # if A[t2] <= max_value, skip to next
    mv t0, t3                                       # max_value = A[t2]
    mv t1, t2                                       # index_of_max = t2
argmax_next:
    addi a1, a1, 4                                  # move to the next element in A
    addi t2, t2, 1                                  # t2++
    j argmax_loop                                   # repeat the loop
argmax_end_loop:
    mv a1, t1                                       # move the index of the max value into a1 for return
    li a0, 0                                        # set a0 to 0 to indicate success
argmax_end:
    lw ra, 0(sp)                                    # Restore return address
    addi sp, sp, 4                                  # Deallocate stack space
    ret                                             # return to the caller
    
exit_with_code:
    li a7, CONST_SYSCALL_EXIT2
    ecall

#############################################################################################################
# HELPER FUNCTIONS FOR PRINTING AND DEBUGGING
#############################################################################################################
.data
PRINT_HEADER_VOCABULARY:    .string "=== Vocabulary ==="
PRINT_HEADER_INPUT:         .string "=== Input ==="
PRINT_HEADER_INPUT_INDICES: .string "=== Input Indices ==="
PRINT_HEADER_MATRIX:        .string "=== Matrix ==="
PRINT_HEADER_SCORES:        .string "=== Scores ==="
PRINT_HEADER_NEXT_TOKEN:    .string "=== Decision ==="
PRINT_VECTOR_LB:            .string "[ "
PRINT_VECTOR_RB:            .string "]"

.text
# Prints a null-terminated string followed by a newline.
# (in) a0: buffer to print (char*)
println:
    li a7, CONST_SYSCALL_PRINT_STRING
    ecall
    li a0, CONST_CHAR_NEWLINE
    li a7, CONST_SYSCALL_PRINT_CHAR
    ecall
    ret

# Prints the vocabulary buffer.
# (in) a0: address of the vocabulary buffer (char*)
print_vocabulary:
    addi sp, sp, -8
    sw ra, 0(sp)
    sw s0, 4(sp)
    mv s0, a0
    la a0, PRINT_HEADER_VOCABULARY
    jal println
    mv a0, s0
    jal println
    lw ra, 0(sp)
    lw s0, 4(sp)
    addi sp, sp, 8
    ret

# Prints the input buffer as a string.
# (in) a0: address of the input buffer (char*)
print_input:
    addi sp, sp, -8
    sw ra, 0(sp)
    sw s0, 4(sp)
    mv s0, a0
    la a0, PRINT_HEADER_INPUT
    jal println
    mv a0, s0
    jal println
    lw ra, 0(sp)
    lw s0, 4(sp)
    addi sp, sp, 8
    ret

# Prints the input indices vector.
# (in) a0: address of the input indices vector (int*)
# (in) a1: size of the input indices vector (int)
print_indices:
    addi sp, sp, -12
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    mv s0, a0
    mv s1, a1
    la a0, PRINT_HEADER_INPUT_INDICES
    jal println
    mv a0, s0
    mv a1, s1
    jal print_vector
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    addi sp, sp, 12
    ret
print_scores:
    addi sp, sp, -4
    sw ra, 0(sp)
    la a0, PRINT_HEADER_SCORES
    jal println
    la a0, SCORES_VECTOR
    lw a1, INPUT_TOTAL_TOKENS
    jal print_vector
    lw ra, 0(sp)
    addi sp, sp, 4
    ret

# a0: address of matrix to print (int*)
# a1: number of rows
# a2: number of columns
print_matrix:
    addi sp, sp, -24
    sw ra, 0(sp)                                    # return address
    sw s0, 4(sp)                                    # matrix pointer
    sw s1, 8(sp)                                    # row index
    sw s2, 12(sp)                                   # col index
    sw s3, 16(sp)                                   # number of rows
    sw s4, 20(sp)                                   # number of columns
    mv s0, a0                                       # s0 = pointer to matrix
    mv s3, a1                                       # s3 = number of rows
    mv s4, a2                                       # s4 = number of columns
    li s1, 0                                        # s1 = current row index
    la a0, PRINT_HEADER_MATRIX
    jal println
print_matrix_row_loop:
    beq s1, s3, print_matrix_done
    li s2, 0
print_matrix_col_loop:
    beq s2, s4, print_matrix_next_row
    lw a0, 0(s0)
    li a7, CONST_SYSCALL_PRINT_INT
    ecall
    addi s0, s0, 4
    addi s2, s2, 1
    li a0, CONST_CHAR_SPACE
    li a7, CONST_SYSCALL_PRINT_CHAR
    ecall
    j print_matrix_col_loop
print_matrix_next_row:
    li a0, CONST_CHAR_NEWLINE
    li a7, CONST_SYSCALL_PRINT_CHAR
    ecall
    addi s1, s1, 1
    j print_matrix_row_loop
print_matrix_done:
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    addi sp, sp, 24
    ret

# a0: address of vector to print (int*)
# a1: number of elements (int)
print_vector:
    addi sp, sp, -8
    sw s0, 0(sp)
    sw s1, 4(sp)
    mv s0, a0                                       # s0 = pointer to vector
    mv s1, a1                                       # s1 = number of elements
    la a0, PRINT_VECTOR_LB                          # Print "[ "
    li a7, CONST_SYSCALL_PRINT_STRING
    ecall
print_vector_loop:
    beq s1, zero, print_vector_done
    lw a0, 0(s0)
    li a7, CONST_SYSCALL_PRINT_INT
    ecall
    li a0, CONST_CHAR_SPACE
    li a7, CONST_SYSCALL_PRINT_CHAR
    ecall
    addi s0, s0, 4
    addi s1, s1, -1
    j print_vector_loop
print_vector_done:
    la a0, PRINT_VECTOR_RB                          # Print "]"
    li a7, CONST_SYSCALL_PRINT_STRING
    ecall
    li a0, CONST_CHAR_NEWLINE
    li a7, CONST_SYSCALL_PRINT_CHAR
    ecall
    lw s0, 0(sp)
    lw s1, 4(sp)
    addi sp, sp, 8
    ret

# (in) a0: address of the predicted token (char*)
print_predicted_token:
    addi sp, sp, -8
    sw ra, 0(sp)
    sw s0, 4(sp)
    mv s0, a0
    la a0, PRINT_HEADER_NEXT_TOKEN
    jal println
    # s0 = start of target token, print it char by char until newline or null
print_predicted_token_char:
    lb t0, 0(s0)
    beq t0, zero, print_predicted_token_nl          # null terminator
    li t1, CONST_CHAR_NEWLINE
    beq t0, t1, print_predicted_token_nl            # newline terminator
    mv a0, t0
    li a7, CONST_SYSCALL_PRINT_CHAR
    ecall
    addi s0, s0, 1
    j print_predicted_token_char
print_predicted_token_nl:
    li a0, CONST_CHAR_NEWLINE
    li a7, CONST_SYSCALL_PRINT_CHAR
    ecall
    lw ra, 0(sp)
    lw s0, 4(sp)
    addi sp, sp, 8
    ret

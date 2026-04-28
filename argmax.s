# You can change these values to test your solution.
.data
ARRAY: .word -6 -1 6 1
SIZE:  .word 4

.text
main:
  la a1, ARRAY        # a1 = pointer to array
  lw a2, SIZE         # a2 = number of elements in the array
  jal ra, argmax      # call argmax function
exit:
  li a7, 10           # exit syscall code
  ecall               # terminate the program

# ==========================================================================
# FUNCTION: argmax
#   Takes an array of integers and returns the index of the largest element.
#   If there are multiple elements with the same maximum value, 
#   it should return the smallest index among them.
# Arguments:
#   a1 = pointer to int array
#   a2 = array length
# Returns:
#   a0 = status code
#   a1 = index of the largest element
# ===========================================================================
argmax:
    blez a2, error   # Case where the number of elements is 0 or less (invalid)
    lw t0, 0(a1)   # Register containing the maximum value
    li t1, 0   # Register containing the index of the maximum value
    li t2, 1   # Register containing the loop counter's value
    
looping:
    beq t2, a2, looped   # If true, all elements have already been tested
    slli t3, t2, 2   # Calculate the offset to reach the next element (mult by 4)
    add t4, t3, a1   # Adds the offset to the pointer's initial position
    lw t5, 0(t4)   # Places the new element to compare inside t5
    ble t5,t0, reloop   # If new element is inferior or equal to current maximum, stop this loop
    mv t0, t5   # Updates the maximum value to the one contained in t5 (new maximum)
    mv t1, t2   # Updates the contained index to that of the current maximum
    
reloop:
    addi t2, t2, 1   # Increment the loop counter by 1
    j looping   # Start a new cicle to test the next element
    
looped:
    mv a1, t1   # Updates the return value to maximum's index
    li a0, 0   # Success code
    ret

error:
    li a0, 50   # Invalid argument code
    ret

argmax_end:
  jr ra               # return to the caller

# You can change these values to test your solution.
.data
A:    .word 6, 1, 3, 9, 12, 4, 13, 153
B:    .word 6, 1, 3, 9, 12, 4, 13, 153
SIZE: .word 8

.text
main:
  la a1, A          # a1 = pointer to array A
  la a2, B          # a2 = pointer to array B
  lw a3, SIZE       # a3 = number of elements in each array
  jal ra, dot       # call dot function
exit:
  li a7, 10         # exit syscall code
  ecall             # terminate the program


# ==========================================================================
# FUNCTION: dot
#   This function computes the dot product of two integer arrays.
# Arguments:
#   a1 = pointer to first array
#   a2 = pointer to second array
#   a3 = array length
# Returns:
#   a0 = status code
#   a1 = dot product result
# ===========================================================================
dot:
    li t0, 1
    blt a3, t0, invalid_size    # invalid size a3 < 1
    li t0, 0    # sums of all the values, used to sum up different mults

    slli t1, a3, 2    # mover os 4 bits necessários para ver o último valor
    add t1, t1, a1    # limite total que podemos ter
    
dot_cicle:
    lw t2, 0(a1)    # loads the first value of the first vector
    lw t3, 0(a2)    # loads the first value of the second vector
    
    mulh t4, t2, t3      # since mul consists on a 64 bit value, when you use mulh
    bnez t4, overflow    # it gets the value to 32 highest bits and 32 lowest bits
                         # if the highest bits are different than 0, then there was
                         # an overflow, as values can only store up to 32 bits      
    
    mul t4, t2, t3    # t6 = t2 * t3
    add t0, t0, t4    # t0 += t2 * t3
    
    addi a1, a1, 4    # moves to the next value in the vector
    addi a2, a2, 4    # moves to the next value in the vector
    
    bne a1, t1, dot_cicle    # if not the same, the cicle repeats
    j dot_end    # returns to the end when the cicle ends

invalid_size:
    li a0, 50    # invalid size < 1
    ret
    
overflow:
    li a0, 200    # bytes overflow
    ret

dot_end:
  li a0, 0    # all succeded until here
  mv a1, t0    # gives a1 the dot product result
  jr ra               # return to the caller

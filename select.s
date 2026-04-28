# You can change these values to test your solution.
.data
ARRAY: .word -6 -1 6 1
SIZE:  .word 4
INDEX: .word 2

.text
main:
  la a1, ARRAY      # a1 = pointer to array
  lw a2, SIZE       # a2 = array length
  lw a3, INDEX      # a3 = element index
  jal ra, select    # call select function
exit:
  li a7, 10         # exit syscall code
  ecall             # terminate the program

# ==========================================================================
# FUNCTION: select
#   This function selects an element from an integer array.
# Arguments:
#   a1 = pointer to int array
#   a2 = array length
#   a3 = element index
# Returns:
#   a0 = status code
#   a1 = value of the selected element
# ===========================================================================
select:
    li x5, 1
    blt a2, x5, invalid_arg    # if size <1 jumps to error code
    
    li x5, 0
    blt a3, x5, idx_out_of_range    # if negative index
                                    # OR
    bge a3, a2, idx_out_of_range    # if a3 >= a2
    
    slli x5, a3, 2   # x5 = a3 * 4, multiplies by 4 bytes
    add a1, a1, x5    # adds to the return to get the exact position
    lw a1, 0(a1)    # loads the local value of that index
    
    li a0, 0    # succeded -> code 0
    ret
    
invalid_arg:    # garante que se tamanho < 1 temos um erro
    li a0, 50    # code 50
    ret
    
idx_out_of_range:    # makes sure the index is not out of bounds
    li a0, 100    # code 100
    ret

select_end:
    jr ra    # return to the caller
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

#==========================================================================
#FUNCTION: select
  #This function selects an element from an integer array.
Arguments:
  #a1 = pointer to int array
  #a2 = array length
  #a3 = element index
Returns:
  #a0 = status code
  #a1 = value of the selected element
#===========================================================================
select:
    li t0, 1    # Loads value 1 to t0
    blt a2, t0, erro50    # if a2 < t0 function erro50 is called

    blt a3, x0, erro100    # if a < 0 function erro100 is called
    bge a3, a2, erro100    # the index cant be >= than the array size

    # an int occupies 4 bytes, therefore, in order to change position,
    # it is required to multiply the index by 4
    
    slli t1, a3, 2    # t1 = a3 × 4
    add  t1, a1, t1    # t1 = a1 + skipped bytes -> adress of the index element
    lw   a1, 0(t1)    # loads the value stored in that adress to a1
    li   a0, 0    # sucess

    ret

erro50:
    li a0,50    # Loads 50 value to a0
    ret 

erro100:
    li a0,100
    ret

select_end:
  jr ra               # return to the caller

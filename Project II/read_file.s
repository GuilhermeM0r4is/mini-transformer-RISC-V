# Read from a text file into a buffer.
# (in)     a0: filename address (char*)
# (in/out) a1: destination buffer
# (in)     a2: maximum number of bytes to read
read_file:
    
    mv t1, a1 # Store the destination buffer for future use
    li a1, 0 # No special flags value for Open system call
    
    li a7, 1024 # Open syscall
    ecall       #a0= file descriptor
    
    mv t0, a0 # Store the file descriptor for future use (next ecall would destroy it)
    li a7, 63 # Read system call
    mv a1, t1 # Restore the destination buffer value to a1 for Read syscall
    ecall     # a0= number of bytes read
    
    mv a0, t0 # Restore the file descriptor to a0 for Close system call
    
    li a7, 57 # Close system call
    ecall     # a0 is unchanged after this operation
    jr ra     # Return to the caller

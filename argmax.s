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
    blez a2, error #Caso em que o vetor tem 0 elementos (invalido)
    lw t0, 0(a1) #Registo que contem o maior elemento
    li t1, 0 #Registo que contem o indice do maior elemento
    li t2, 1 #Registo que contem o valor do contador
    
looping:
    beq t2, a2, looped #Se verdadeiro, todos os elementos ja foram avaliados
    slli t3, t2, 2 #Calcula o offset para atingir o proximo elemento (mult por 4)
    add t4, t3, a1 #Adiciona o offset a posicao inicial do ponteiro
    lw t5, 0(t4) #Coloca o novo elemento a avaliar dentro de t5
    ble t5,t0, reloop #Se o novo elemento é inferior ou igual ao maior, termina este loop
    mv t0, t5 #Atualiza o elemento maior para o valor contido em t5
    mv t1, t2 #Atualiza o indice para aquele do maior elemento no vetor
    
reloop:
    addi t2, t2, 1 #Incrementa o contador de ciclos por 1
    j looping #Inicia um novo ciclo para avaliar o proximo elemento
    
looped:
    mv a1, t1 #Atualiza o valor de retorno para o indice do maior elemento
    li a0, 0 #Codigo de sucesso
    ret

error:
    li a0, 50 #Codigo de argumento invalido
    ret

argmax_end:
  jr ra               # return to the caller

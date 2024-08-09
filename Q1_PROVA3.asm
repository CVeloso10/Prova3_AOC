.data
    mem: .word 0x13579bcd, 0x00000000, 0x10fedcba, 0x00000010, 0xbb000000, 0x00000000, 0x01224459, 0xa25f4400, 0x0000fe00, 0xff0c0eee, 0xaa71bbf0, 0x01ac1b00

.text
.globl main

main:
    # Carrega o endere�o base da mem�ria em $s0
    lui $s0, 0x1001	      # : 
    ori $s0, $s0, 0x0000      # : 
    
    # Contador da mem�ria: N�mero de valores restantes para chamar a fun��o na mem�ria
    addi $s1, $s1, 12         # : 
    
loop:
    # Verifica se ainda h� valores restantes para chamar a fun��o na mem�ria 
    beq $s1, $zero, end_loop  # : Se $s1 for zero, terminar loop
    
    # Salva o valor atual como argumento da fun��o Fibonacci
    lw $a0, 0($s0)            # : Carregar valor da mem�ria em $a0
    
    # Verifica se o valor atual � menor ou igual a zero, nesse caso n�o chama a fun��o, e sim o tratamento de exce��o case_zero
    addi $t0, $0, 1	      # : define $t0 como 1
    slt $t1, $a0, $t0	      # : verifica se o $a0 � menor que $t0, ou seja, menor ou igual a zero 
    beq $t1, 1, case_zero     # : se $a0 <= 0, chama a exce��o case_zero
    
    # Chama a fun��o Fibonacci
    jal fibonacci             # : 
    
    # Avan�a para o pr�ximo endere�o
    addi $s0, $s0, 4          # :
    
    # Decrementa o contador de valores restantes na mem�ria
    subi $s1, $s1, 1          # : 
    
    # Loop
    j loop                    # : 

case_zero:        
    # Salva 0 na mem�ria (F(0))
    sw $zero, 0($s0)
    
    # Avan�a para o pr�ximo endere�o
    addi $s0, $s0, 4          # :
    
    # Decrementa o contador de valores restantes na mem�ria
    subi $s1, $s1, 1          # : 
    
    # Loop
    j loop                    # : 

end_loop:
    # Finaliza o programa 
    li $v0, 10   # Carrega o c�digo de servi�o 10 no registrador $v0
    syscall      # Executa a chamada de sistema, que finaliza o programa

fibonacci:
    
    # Preservando registradores que n�o podem ser modificados
    addi $sp, $sp, -8         # : Reservar espa�o na pilha
    sw $ra, 4($sp)            # : Salvar endere�o de retorno
    sw $a0, 0($sp)            # : Salvar argumento
    
    # Inicializando os primeiros valores de Fibonacci
    addi $t2, $zero, 0          # : F(0)
    addi $t3, $zero, 1          # : F(1)
    addi $t4, $zero, 2		      # : Contador
    
fib_loop:
    # Verifica se atingimos o termo desejado
    beq $t4, $a0, fib_end     # :
    
    # Calcula o pr�ximo n�mero da S�rie de Fibonacci
    addu $t5, $t2, $t3        # : F(n) = F(n-1) + F(n-2)
    
    # Prepara para a pr�xima itera��o
    add $t2, $zero, $t3       # : F(n-2) = F(n-1)
    add $t3, $zero, $t5        # : F(n-1) = F(n)
    
    # Incrementa o contador
    addi $t4, $t4, 1
    
    # Loop
    j fib_loop                # : 

fib_end:
    sw $t5, 0($s0)	      # : Armazena o resultado na mem�ria
    lw $a0, 0($sp)            # : Restaurar argumento
    lw $ra, 4($sp)            # : Restaurar endere�o de retorno
    addi $sp, $sp, 8          # : Restaurar pilha
    jr $ra                    # : Retornar para a fun��o de chamada

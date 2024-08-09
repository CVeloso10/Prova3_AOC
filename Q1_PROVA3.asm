.data
    mem: .word 0x13579bcd, 0x00000000, 0x10fedcba, 0x00000010, 0xbb000000, 0x00000000, 0x01224459, 0xa25f4400, 0x0000fe00, 0xff0c0eee, 0xaa71bbf0, 0x01ac1b00

.text
.globl main

main:
    # Carrega o endereço base da memória em $s0
    lui $s0, 0x1001	      # : 
    ori $s0, $s0, 0x0000      # : 
    
    # Contador da memória: Número de valores restantes para chamar a função na memória
    addi $s1, $s1, 12         # : 
    
loop:
    # Verifica se ainda há valores restantes para chamar a função na memória 
    beq $s1, $zero, end_loop  # : Se $s1 for zero, terminar loop
    
    # Salva o valor atual como argumento da função Fibonacci
    lw $a0, 0($s0)            # : Carregar valor da memória em $a0
    
    # Verifica se o valor atual é menor ou igual a zero, nesse caso não chama a função, e sim o tratamento de exceção case_zero
    addi $t0, $0, 1	      # : define $t0 como 1
    slt $t1, $a0, $t0	      # : verifica se o $a0 é menor que $t0, ou seja, menor ou igual a zero 
    beq $t1, 1, case_zero     # : se $a0 <= 0, chama a exceção case_zero
    
    # Chama a função Fibonacci
    jal fibonacci             # : 
    
    # Avança para o próximo endereço
    addi $s0, $s0, 4          # :
    
    # Decrementa o contador de valores restantes na memória
    subi $s1, $s1, 1          # : 
    
    # Loop
    j loop                    # : 

case_zero:        
    # Salva 0 na memória (F(0))
    sw $zero, 0($s0)
    
    # Avança para o próximo endereço
    addi $s0, $s0, 4          # :
    
    # Decrementa o contador de valores restantes na memória
    subi $s1, $s1, 1          # : 
    
    # Loop
    j loop                    # : 

end_loop:
    # Finaliza o programa 
    li $v0, 10   # Carrega o código de serviço 10 no registrador $v0
    syscall      # Executa a chamada de sistema, que finaliza o programa

fibonacci:
    
    # Preservando registradores que não podem ser modificados
    addi $sp, $sp, -8         # : Reservar espaço na pilha
    sw $ra, 4($sp)            # : Salvar endereço de retorno
    sw $a0, 0($sp)            # : Salvar argumento
    
    # Inicializando os primeiros valores de Fibonacci
    addi $t2, $zero, 0          # : F(0)
    addi $t3, $zero, 1          # : F(1)
    addi $t4, $zero, 2		      # : Contador
    
fib_loop:
    # Verifica se atingimos o termo desejado
    beq $t4, $a0, fib_end     # :
    
    # Calcula o próximo número da Série de Fibonacci
    addu $t5, $t2, $t3        # : F(n) = F(n-1) + F(n-2)
    
    # Prepara para a próxima iteração
    add $t2, $zero, $t3       # : F(n-2) = F(n-1)
    add $t3, $zero, $t5        # : F(n-1) = F(n)
    
    # Incrementa o contador
    addi $t4, $t4, 1
    
    # Loop
    j fib_loop                # : 

fib_end:
    sw $t5, 0($s0)	      # : Armazena o resultado na memória
    lw $a0, 0($sp)            # : Restaurar argumento
    lw $ra, 4($sp)            # : Restaurar endereço de retorno
    addi $sp, $sp, 8          # : Restaurar pilha
    jr $ra                    # : Retornar para a função de chamada

Ideias para implementar leitor de numeros

"-66532"

pega primeiro digito,
verifica se é - (2D) ou + (2B)
    se sim, armazena em na variavel de sinal e comeca leitura dos numeros a partir do segundo
    se nao, comeca a leitura dos numeros
    
inicializa eax com 0
para cada caractere lido
    verifica se está entre '0' e '9'
        se não, encerra loop
        se sim
            converte caractere para numero (subtrai 0x30)
            multiplica eax por 10
            adiciona o numero convertido a eax

se o sinal for negativo, multiplica eax por -1 (neg eax)

``` nasm

number_s resb 6

read_num:
xor esi, esi
xor ebx, ebx
xor eax, eax
xor ecx, ecx

; bl = 1 se negativo, bl = 0 se positivo

cmp BYTE [number_s], 0x2D
SETE bl ; se number_s[0] == '-' -> bl = 1

cmp BYTE [number_s], 0X2B
SETE cl ; se number_s[0] == '+' -> cl = 1

cmp cl, bl ; al = 1 se for caracter de sinal
jz read_char_loop ; Se ZF = 1 (al e bl forem iguals), pula para o loop sem incrementar o index
inc esi

read_char_loop:
    movzx ecx, BYTE [number_s+esi]
    cmp ecx, 0x30
    jb read_loop_end
    cmp ecx, 0x39
    ja read_loop_end
    sub ecx, 0x30
    mul eax, 10
    add eax, ecx
    inc esi
    jmp read_char_loop

read_loop_end:
    neg eax


```
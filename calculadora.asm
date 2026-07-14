; =============================================================
; calculadora.asm
;
; Convenção de chamadas:
;   - argumentos passados pela pilha;
;   - primeiro argumento em [EBP + 8];
;   - segundo argumento em [EBP + 12];
;   - retorno em EAX;
;   - o chamador remove os argumentos da pilha.
;
; Precisão:
;   0 = 16 bits
;   1 = 32 bits
;
; Interface esperada das operações
;
;   executar_soma(precisao)             -> EAX = resultado
;   executar_subtracao(precisao)        -> EAX = resultado
;   executar_multiplicacao(precisao)    -> EAX = resultado
;   executar_divisao(precisao)          -> EAX = resultado
;   executar_exponenciacao(precisao)    -> EAX = resultado
;   executar_mod(precisao)              -> EAX = resultado
;
; Cada operação deve:
;   1. chamar ler_primeiro_operando;
;   2. chamar ler_segundo_operando;
;   3. realizar a operação;
;   4. chamar mostrar_resultado;
;   5. retornar o resultado em EAX.
; =============================================================


; =============================================================
; Símbolos exportados
; =============================================================

global _start

global ler_primeiro_operando
global ler_segundo_operando
global mostrar_resultado

global mostrar_erro_divisao_zero
global mostrar_erro_expoente_negativo
global encerrar_overflow


; ============================================================
; Operações implementadas em outros arquivos
; ============================================================

extern executar_soma
extern executar_subtracao
extern executar_multiplicacao
extern executar_divisao
extern executar_exponenciacao
extern executar_mod

extern imprimir_string
extern ler_string

extern ler_numero16
extern ler_numero32

extern imprimir_numero16
extern imprimir_numero32


; ============================================================
; Constantes compartilhadas
; ============================================================

%include "constantes.inc"

; ============================================================
; Dados globais permitidos
; ============================================================

section .data

    msg_pedir_nome:
        db "Bem-vindo. Digite seu nome: "
    msg_pedir_nome_len equ $ - msg_pedir_nome

    msg_saudacao_inicio:
        db "Olá, "
    msg_saudacao_inicio_len equ $ - msg_saudacao_inicio

    msg_saudacao_fim:
        db ", bem-vindo ao programa de CALC IA-32", 10
    msg_saudacao_fim_len equ $ - msg_saudacao_fim

    msg_precisao:
        db "Vai trabalhar com 16 ou 32 bits?"
        db "(digite 0 para 16, e 1 para 32): "
    msg_precisao_len equ $ - msg_precisao

    msg_precisao_invalida:
        db "Precisão inválida. Digite 0 ou 1.", 10
    msg_precisao_invalida_len equ $ - msg_precisao_invalida

    msg_menu_0:
        db 10, "ESCOLHA UMA OPÇÃO:", 10
    msg_menu_0_len equ $ - msg_menu_0

    msg_menu_1:
        db "- 1: SOMA", 10
    msg_menu_1_len equ $ - msg_menu_1

    msg_menu_2:
        db "- 2: SUBTRAÇÃO", 10
    msg_menu_2_len equ $ - msg_menu_2

    msg_menu_3:
        db "- 3: MULTIPLICAÇÃO", 10
    msg_menu_3_len equ $ - msg_menu_3

    msg_menu_4:
        db "- 4: DIVISÃO", 10
    msg_menu_4_len equ $ - msg_menu_4

    msg_menu_5:
        db "- 5: EXPONENCIAÇÃO", 10
    msg_menu_5_len equ $ - msg_menu_5

    msg_menu_6:
        db "- 6: MOD", 10
    msg_menu_6_len equ $ - msg_menu_6

    msg_menu_7:
        db "- 7: SAIR", 10
    msg_menu_7_len equ $ - msg_menu_7

    msg_pedir_opcao:
        db "Opção: "
    msg_pedir_opcao_len equ $ - msg_pedir_opcao

    msg_opcao_invalida:
        db "Opção inválida. Digite um número entre 1 e 7.", 10
    msg_opcao_invalida_len equ $ - msg_opcao_invalida

    msg_primeiro_numero:
        db "Digite o primeiro número: "
    msg_primeiro_numero_len equ $ - msg_primeiro_numero

    msg_segundo_numero:
        db "Digite o segundo número: "
    msg_segundo_numero_len equ $ - msg_segundo_numero

    msg_resultado:
        db "Resultado: "
    msg_resultado_len equ $ - msg_resultado

    msg_overflow:
        db "OCORREU OVERFLOW.", 10
    msg_overflow_len equ $ - msg_overflow

    msg_divisao_zero:
        db "Não é possível dividir por zero.", 10
    msg_divisao_zero_len equ $ - msg_divisao_zero

    msg_expoente_negativo:
        db "O expoente deve ser maior ou igual a zero.", 10
    msg_expoente_negativo_len equ $ - msg_expoente_negativo

    msg_continuar:
        db "Pressione ENTER para continuar..."
    msg_continuar_len equ $ - msg_continuar

    nova_linha:
        db 10
    nova_linha_len equ $ - nova_linha


section .bss

    ; Variáveis globais

    nome_usuario:
        resb TAMANHO_NOME

    precisao:
        resd 1

    opcao:
        resd 1


section .text

_start:
    ; Executa o programa principal e recebe o status de saída em EAX.
    call    programa_principal

    ; Encerra o programa com o status retornado.
    push    eax
    call    encerrar_programa


; ============================================================
; programa_principal()
;
; A função principal somente chama outras funções e passa
; adiante os valores retornados por elas.
; ============================================================

programa_principal:
    ; Cria o stack frame da função. `enter` equivale a empilhar EBP,
    ; mover ESP para EBP e reservar espaço para variáveis locais.
    ; Como esta função não tem variáveis locais, o tamanho reservado é 0.
    enter   0, 0

    call    saudar_usuario

    call    obter_precisao

    ; Executa a calculadora com a precisão retornada por obter_precisao.
    push    eax
    call    executar_calculadora        ; executar_calculadora(precisao)
    add     esp, 4

    ; Retorna status 0 para o encerramento normal do programa.
    xor     eax, eax

    ; Desfaz o stack frame: ESP volta para a base da função e EBP
    ; recebe o valor anterior que foi empilhado no início.
    leave
    ret

; ============================================================
; saudar_usuario()
;
; Lê o nome do usuário e mostra a saudação.
; ============================================================

saudar_usuario:
    ; Cria o stack frame manualmente, mantendo a preferência
    ; por não usar `enter` nesta função.
    push    ebp
    mov     ebp, esp

    ; Variável local:
    ;   [EBP - 4] = tamanho do nome
    sub     esp, 4

    ; Imprime a mensagem pedindo o nome:
    ;   imprimir_string(msg_pedir_nome, msg_pedir_nome_len)
    push    dword   msg_pedir_nome_len
    push    dword   msg_pedir_nome
    call    imprimir_string
    add     esp, 8

    ; Lê o nome no buffer global `nome_usuario`.
    push    dword   TAMANHO_NOME
    push    dword   nome_usuario
    call    ler_string
    add     esp, 8

    ; Armazena na variável local o tamanho retornado por ler_string.
    mov     [ebp - 4], eax

    ; Imprime o prefixo da saudação: "Hola, ".
    push    dword   msg_saudacao_inicio_len
    push    dword   msg_saudacao_inicio
    call    imprimir_string
    add     esp, 8

    ; Imprime o nome lido, usando o tamanho retornado por ler_string.
    push    dword   [ebp - 4]
    push    dword   nome_usuario
    call    imprimir_string
    add     esp, 8

    ; Imprime o final da saudação: ", bem-vindo ...".
    push    dword   msg_saudacao_fim_len
    push    dword   msg_saudacao_fim
    call    imprimir_string
    add     esp, 8

    mov     esp, ebp
    pop     ebp
    ret


; ============================================================
; obter_precisao() -> EAX
;
; Retorno:
;   EAX = 0 para 16 bits
;   EAX = 1 para 32 bits
; ============================================================

obter_precisao:
    push    ebp
    mov     ebp, esp

.tentar:
    ; Solicita a precisão desejada.
    push    dword   msg_precisao_len
    push    dword   msg_precisao
    call    imprimir_string
    add     esp, 8

    ; Lê a opção numérica informada pelo usuário.
    call    ler_numero32

    ; Se a precisão for 16 bits, a entrada é válida.
    cmp     eax, PRECISAO_16
    je      .valida

    ; Se a precisão for 32 bits, a entrada também é válida.
    cmp     eax, PRECISAO_32
    je      .valida

    ; Caso contrário, informa o erro e pede outra entrada.
    push    dword   msg_precisao_invalida_len
    push    dword   msg_precisao_invalida
    call    imprimir_string
    add     esp, 8

    jmp     .tentar

.valida:
    ; Guarda globalmente a precisão válida, mantendo o retorno em EAX.
    mov     [precisao], eax

    mov     esp, ebp
    pop     ebp
    ret


; ============================================================
; executar_calculadora(precisao)
;
; [EBP + 8] = precisão
; ============================================================

executar_calculadora:
    push    ebp
    mov     ebp, esp

    ; Preserva EBX antes de usá-lo para guardar a precisão.
    push    ebx

    ; Copia o argumento `precisao` para EBX.
    mov     ebx, [ebp + 8]

.loop_menu:
    ; Mostra o menu e lê a opção escolhida.
    call    mostrar_menu
    call    ler_opcao                   ; ler_opcao() -> EAX

    ; Guarda a opção escolhida.
    mov     [opcao], eax

    ; Se a opção for SAIR, encerra o loop do menu.
    cmp     eax, OP_SAIR
    je      .fim

    ; Despacha a operação escolhida com a precisão atual.
    push    ebx
    push    eax
    call    despachar_operacao          ; despachar_operacao(opcao, precisao)
    add     esp, 8

    ; Aguarda ENTER antes de mostrar o menu novamente.
    call    esperar_enter

    jmp     .loop_menu

.fim:
    ; Retorna status 0 ao encerrar a calculadora.
    xor     eax, eax


    pop     ebx

    mov     esp, ebp
    pop     ebp
    ret


; ============================================================
; mostrar_menu()
; ============================================================

mostrar_menu:
    push    ebp
    mov     ebp, esp

    ; Imprime o título do menu.
    push    dword   msg_menu_0_len
    push    dword   msg_menu_0
    call    imprimir_string
    add     esp, 8

    ; Imprime a opção de soma.
    push    dword msg_menu_1_len
    push    dword msg_menu_1
    call    imprimir_string
    add     esp, 8

    ; Imprime a opção de subtração.
    push    dword msg_menu_2_len
    push    dword msg_menu_2
    call    imprimir_string
    add     esp, 8

    ; Imprime a opção de multiplicação.
    push    dword msg_menu_3_len
    push    dword msg_menu_3
    call    imprimir_string
    add     esp, 8

    ; Imprime a opção de divisão.
    push    dword msg_menu_4_len
    push    dword msg_menu_4
    call    imprimir_string
    add     esp, 8

    ; Imprime a opção de exponenciação.
    push    dword msg_menu_5_len
    push    dword msg_menu_5
    call    imprimir_string
    add     esp, 8

    ; Imprime a opção de módulo.
    push    dword msg_menu_6_len
    push    dword msg_menu_6
    call    imprimir_string
    add     esp, 8

    ; Imprime a opção de saída.
    push    dword msg_menu_7_len
    push    dword msg_menu_7
    call    imprimir_string
    add     esp, 8

    mov     esp, ebp
    pop     ebp
    ret


; ============================================================
; ler_opcao() -> EAX
;
; Retorna um número entre 1 e 7.
; ============================================================

ler_opcao:
    push    ebp
    mov     ebp, esp

.tentar:
    ; Solicita a opção do menu.
    push    dword   msg_pedir_opcao_len
    push    dword   msg_pedir_opcao
    call    imprimir_string
    add     esp, 8

    ; Lê a opção numérica informada pelo usuário.
    call    ler_numero32

    ; Se a opção for menor que 1, ela é inválida.
    cmp     eax, OP_SOMA
    jl      .invalida

    ; Se a opção for maior que 7, ela é inválida.
    cmp     eax, OP_SAIR
    jg      .invalida

    mov     esp, ebp
    pop     ebp
    ret

.invalida:
    ; Informa o erro e pede outra opção.
    push    dword   msg_opcao_invalida_len
    push    dword   msg_opcao_invalida
    call    imprimir_string
    add     esp, 8

    jmp     .tentar


; ============================================================
; despachar_operacao(opcao, precisao) -> EAX
;
; [EBP + 8]  = opção
; [EBP + 12] = precisão
; ============================================================

despachar_operacao:
    push    ebp
    mov     ebp, esp

    ; Carrega a opção para decidir qual operação será executada.
    mov     eax, [ebp + 8]

    ; Se a opção for OP_SOMA, chama executar_soma.
    cmp     eax, OP_SOMA
    je      .soma

    ; Se a opção for OP_SUBTRACAO, chama executar_subtracao.
    cmp     eax, OP_SUBTRACAO
    je      .subtracao

    ; Se a opção for OP_MULTIPLICACAO, chama executar_multiplicacao.
    cmp     eax, OP_MULTIPLICACAO
    je      .multiplicacao

    ; Se a opção for OP_DIVISAO, chama executar_divisao.
    cmp     eax, OP_DIVISAO
    je      .divisao

    ; Se a opção for OP_EXPONENCIACAO, chama executar_exponenciacao.
    cmp     eax, OP_EXPONENCIACAO
    je      .exponenciacao

    ; Se a opção for OP_MOD, chama executar_mod.
    cmp     eax, OP_MOD
    je      .mod

    ; Qualquer opção fora do intervalo conhecido retorna 0.
    xor     eax, eax
    jmp     .fim

.soma:
    push    dword   [ebp + 12]
    call    executar_soma               ; executar_soma(precisao)
    add     esp, 4
    jmp     .fim

.subtracao:
    push    dword [ebp + 12]
    call    executar_subtracao          ; executar_subtracao(precisao)
    add     esp, 4
    jmp     .fim

.multiplicacao:
    push    dword [ebp + 12]
    call    executar_multiplicacao      ; executar_multiplicacao(precisao)
    add     esp, 4
    jmp     .fim

.divisao:
    push    dword [ebp + 12]
    call    executar_divisao            ; executar_divisao(precisao)
    add     esp, 4
    jmp     .fim

.exponenciacao:
    push    dword [ebp + 12]
    call    executar_exponenciacao      ; executar_exponenciacao(precisao)
    add     esp, 4
    jmp     .fim

.mod:
    push    dword [ebp + 12]
    call    executar_mod                ; executar_mod(precisao)
    add     esp, 4

.fim:
    mov     esp, ebp
    pop     ebp
    ret


; ============================================================
; ler_primeiro_operando(precisao) -> EAX
;
; [EBP + 8] = precisão
; ============================================================

ler_primeiro_operando:
    push    ebp
    mov     ebp, esp

    ; Solicita o primeiro operando.
    push    dword   msg_primeiro_numero_len
    push    dword   msg_primeiro_numero
    call    imprimir_string
    add     esp, 8

    ; Se a precisão for 16 bits, usa a leitura com validação de 16 bits.
    cmp     dword [ebp + 8], PRECISAO_16
    je      .ler16

    ; Caso contrário, lê um inteiro de 32 bits.
    call    ler_numero32
    jmp     .fim

.ler16:
    call    ler_numero16

.fim:
    mov     esp, ebp
    pop     ebp
    ret


; ============================================================
; ler_segundo_operando(precisao) -> EAX
;
; [EBP + 8] = precisão
; ============================================================

ler_segundo_operando:
    push    ebp
    mov     ebp, esp

    ; Solicita o segundo operando.
    push    dword   msg_segundo_numero_len
    push    dword   msg_segundo_numero
    call    imprimir_string
    add     esp, 8

    ; Se a precisão for 16 bits, usa a leitura com validação de 16 bits.
    cmp     dword [ebp + 8], PRECISAO_16
    je      .ler16

    ; Caso contrário, lê um inteiro de 32 bits.
    call    ler_numero32
    jmp     .fim

.ler16:
    call    ler_numero16

.fim:
    mov     esp, ebp
    pop     ebp
    ret


; ============================================================
; mostrar_resultado(precisao, valor)
;
; [EBP + 8]  = precisão
; [EBP + 12] = resultado
; ============================================================

mostrar_resultado:
    push    ebp
    mov     ebp, esp

    ; Imprime o prefixo do resultado.
    push    dword   msg_resultado_len
    push    dword   msg_resultado
    call    imprimir_string
    add     esp, 8

    ; Escolhe a rotina de impressão conforme a precisão.
    cmp     dword [ebp + 8], PRECISAO_16
    je      .mostrar16

    push    dword   [ebp + 12]
    call    imprimir_numero32
    add     esp, 4
    jmp     .nova_linha

.mostrar16:
    push    dword   [ebp + 12]
    call    imprimir_numero16
    add     esp, 4

.nova_linha:
    ; Finaliza a linha do resultado.
    push    dword   nova_linha_len
    push    dword   nova_linha
    call    imprimir_string
    add     esp, 8

    mov     esp, ebp
    pop     ebp
    ret


; ============================================================
; esperar_enter()
; ============================================================

esperar_enter:
    push    ebp
    mov     ebp, esp

    ; Pequeno buffer local.
    sub     esp, 4

    ; Mostra a mensagem de pausa.
    push    dword   msg_continuar_len
    push    dword   msg_continuar
    call    imprimir_string
    add     esp, 8

    ; Lê até 1 caractere mais o terminador para consumir o ENTER.
    lea     eax, [ebp - 4]

    push    dword   2
    push    eax
    call    ler_string
    add     esp, 8

    mov     esp, ebp
    pop     ebp
    ret


; ============================================================
; mostrar_erro_divisao_zero()
; ============================================================

mostrar_erro_divisao_zero:
    push    ebp
    mov     ebp, esp

    ; Imprime a mensagem de erro de divisão por zero.
    push    dword   msg_divisao_zero_len
    push    dword   msg_divisao_zero
    call    imprimir_string
    add     esp, 8

    mov     esp, ebp
    pop     ebp
    ret


; ============================================================
; mostrar_erro_expoente_negativo()
; ============================================================

mostrar_erro_expoente_negativo:
    push    ebp
    mov     ebp, esp

    ; Imprime a mensagem de erro de expoente negativo.
    push    dword   msg_expoente_negativo_len
    push    dword   msg_expoente_negativo
    call    imprimir_string
    add     esp, 8

    mov     esp, ebp
    pop     ebp
    ret


; ============================================================
; encerrar_overflow()
;
; Mostra a mensagem de overflow e encerra o programa.
; ============================================================

encerrar_overflow:
    push    ebp
    mov     ebp, esp

    ; Imprime a mensagem de overflow.
    push    dword   msg_overflow_len
    push    dword   msg_overflow
    call    imprimir_string
    add     esp, 8

    ; Encerra o programa com status 1.
    push    dword   1
    call    encerrar_programa

    ; A execução nunca chega aqui.


; ============================================================
; encerrar_programa(status)
;
; [EBP + 8] = código de saída
; ============================================================

encerrar_programa:
    push    ebp
    mov     ebp, esp

    ; Executa SYS_EXIT com o código recebido por argumento.
    mov     ebx, [ebp + 8]
    mov     eax, SYS_EXIT
    int     80h

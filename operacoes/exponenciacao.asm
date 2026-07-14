BITS 32

; ============================================================
; exponenciacao.asm
;
; Função exportada:
;   executar_exponenciacao(precisao) -> EAX
;
; Parâmetro:
;   [EBP + 8] = precisão
;       0 -> 16 bits
;       1 -> 32 bits
;
; Operandos:
;   primeiro número = base
;   segundo número  = expoente
;
; Retorno:
;   EAX = base elevada ao expoente
;
; Restrições:
;   - o expoente deve ser maior ou igual a zero;
;   - overflow encerra o programa;
;   - qualquer número elevado a zero retorna 1;
;   - nesta implementação, 0 elevado a 0 retorna 1.
; ============================================================

global executar_exponenciacao

extern ler_primeiro_operando
extern ler_segundo_operando
extern mostrar_resultado
extern mostrar_erro_expoente_negativo
extern encerrar_overflow

; Constantes compartilhadas com o arquivo principal.
%include "constantes.inc"

section .text


; ============================================================
; executar_exponenciacao(precisao) -> EAX
;
; Variáveis locais:
;   [EBP - 4]  = base atual
;   [EBP - 8]  = expoente
;   [EBP - 12] = resultado acumulado
; ============================================================

executar_exponenciacao:
    push    ebp
    mov     ebp, esp

    sub     esp, 12

    ; Lê a base.
    push    dword   [ebp + 8]
    call    ler_primeiro_operando
    add     esp, 4

    mov     [ebp - 4], eax

    ; Lê o expoente.
    push    dword   [ebp + 8]
    call    ler_segundo_operando
    add     esp, 4

    mov     [ebp - 8], eax

    ; A calculadora trabalha somente com resultados inteiros.
    ; Expoentes negativos normalmente produziriam frações.
    cmp     dword [ebp - 8], 0
    jl      .expoente_negativo

    ; O elemento neutro da multiplicação é 1.
    mov     dword [ebp - 12], 1

    ; Seleciona a rotina conforme a precisão.
    cmp     dword [ebp + 8], PRECISAO_16
    je      .potencia16


; ============================================================
; Exponenciação de 32 bits por quadrados sucessivos
;
; Algoritmo:
;
;   resultado = 1
;
;   enquanto expoente > 0:
;       se expoente for ímpar:
;           resultado = resultado * base
;
;       expoente = expoente / 2
;
;       se expoente ainda for diferente de zero:
;           base = base * base
; ============================================================

.potencia32:
    ; ECX guarda o expoente restante.
    mov     ecx, [ebp - 8]

.loop32:
    test    ecx, ecx
    jz      .mostrar

    ; Se o bit menos significativo é 1, o expoente é ímpar.
    test    ecx, 1
    jz      .reduzir_expoente32

    ; resultado = resultado * base
    mov     eax, [ebp - 12]
    imul    dword [ebp - 4]
    jo      .overflow

    mov     [ebp - 12], eax

.reduzir_expoente32:
    shr     ecx, 1

    ; Se o expoente tornou-se zero, a base não será mais usada.
    ; Isso evita detectar overflow em uma multiplicação
    ; desnecessária.
    test    ecx, ecx
    jz      .mostrar

    ; base = base * base
    mov     eax, [ebp - 4]
    imul    dword [ebp - 4]
    jo      .overflow

    mov     [ebp - 4], eax

    jmp     .loop32


; ============================================================
; Exponenciação de 16 bits por quadrados sucessivos
;
; As multiplicações são realizadas em 16 bits:
;
;   DX:AX = AX * operando
;
; Se o resultado não couber em AX, OF será igual a 1.
; ============================================================

.potencia16:
    ; ECX guarda o expoente restante.
    mov     ecx, [ebp - 8]

.loop16:
    test    ecx, ecx
    jz      .mostrar

    ; Se o bit menos significativo é 1, o expoente é ímpar.
    test    ecx, 1
    jz      .reduzir_expoente16

    ; resultado = resultado * base
    mov     ax, word [ebp - 12]
    imul    word [ebp - 4]
    jo      .overflow

    ; Armazena a representação estendida com sinal.
    movsx   eax, ax
    mov     [ebp - 12], eax

.reduzir_expoente16:
    shr     ecx, 1

    ; Se o expoente tornou-se zero, a base não será mais usada.
    test    ecx, ecx
    jz      .mostrar

    ; base = base * base
    mov     ax, word [ebp - 4]
    imul    word [ebp - 4]
    jo      .overflow

    movsx   eax, ax
    mov     [ebp - 4], eax

    jmp     .loop16


; ============================================================
; Mostra e retorna o resultado.
; ============================================================

.mostrar:
    ; mostrar_resultado(precisao, resultado)
    push    dword   [ebp - 12]
    push    dword   [ebp + 8]
    call    mostrar_resultado
    add     esp, 8

    ; Retorna o resultado em EAX.
    mov     eax, [ebp - 12]

    mov     esp, ebp
    pop     ebp
    ret


; ============================================================
; Expoente negativo
; ============================================================

.expoente_negativo:
    call    mostrar_erro_expoente_negativo

    ; Não existe resultado inteiro geral para expoentes
    ; negativos. Retorna zero para indicar ausência de um
    ; resultado válido.
    xor     eax, eax

    mov     esp, ebp
    pop     ebp
    ret


; ============================================================
; Overflow
; ============================================================

.overflow:
    call    encerrar_overflow

    ; encerrar_overflow termina o processo.

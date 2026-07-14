BITS 32

; ============================================================
; multiplicacao.asm
;
; Função exportada:
;   executar_multiplicacao(precisao) -> EAX
;
; Parâmetro:
;   [EBP + 8] = precisão
;       0 -> operandos de 16 bits
;       1 -> operandos de 32 bits
;
; Retorno:
;   EAX = resultado da multiplicação
;
; Em caso de overflow:
;   mostra "OCORREU OVERFLOW." e encerra o programa.
; ============================================================

global executar_multiplicacao

extern ler_primeiro_operando
extern ler_segundo_operando
extern mostrar_resultado
extern encerrar_overflow

; Constantes compartilhadas com o arquivo principal.
%include "constantes.inc"

section .text


; ============================================================
; executar_multiplicacao(precisao) -> EAX
;
; Variáveis locais:
;   [EBP - 4]  = primeiro operando
;   [EBP - 8]  = segundo operando
;   [EBP - 12] = resultado
; ============================================================

executar_multiplicacao:
    push    ebp
    mov     ebp, esp

    ; Variáveis locais:
    ;   [EBP - 4]  = primeiro operando
    ;   [EBP - 8]  = segundo operando
    ;   [EBP - 12] = resultado
    sub     esp, 12

    ; Lê o primeiro operando.
    push    dword   [ebp + 8]
    call    ler_primeiro_operando
    add     esp, 4

    mov     [ebp - 4], eax

    ; Lê o segundo operando.
    push    dword   [ebp + 8]
    call    ler_segundo_operando
    add     esp, 4

    mov     [ebp - 8], eax

    ; Seleciona a operação de acordo com a precisão.
    cmp     dword [ebp + 8], PRECISAO_16
    je      .multiplicar16

    jmp     .multiplicar32


; ============================================================
; Multiplicação assinada de 32 bits
;
; IMUL r/m32:
;
;   EDX:EAX = EAX * operando
;
; OF = 1 quando o resultado não pode ser representado em
; um inteiro assinado de 32 bits.
; ============================================================

.multiplicar32:
    ; Carrega o primeiro operando em EAX para usar a forma de IMUL
    ; que grava o resultado completo em EDX:EAX.
    mov     eax, [ebp - 4]

    imul    dword [ebp - 8]
    jo      .overflow

    ; Se não houve overflow, EAX contém o resultado de 32 bits.
    mov     [ebp - 12], eax
    jmp     .mostrar_resultado


; ============================================================
; Multiplicação assinada de 16 bits
;
; IMUL r/m16:
;
;   DX:AX = AX * operando
;
; OF = 1 quando o resultado não pode ser representado em
; um inteiro assinado de 16 bits.
; ============================================================

.multiplicar16:
    ; Usa apenas a parte baixa de 16 bits dos operandos.
    mov     ax, [ebp - 4]

    imul    word [ebp - 8]
    jo      .overflow

    ; O resultado válido está em AX. Ele é estendido com sinal
    ; para EAX para seguir a convenção de retorno da aplicação.
    movsx   eax, ax
    mov     [ebp - 12], eax


; ============================================================
; Exibe e retorna o resultado.
; ============================================================

.mostrar_resultado:
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
; Tratamento de overflow
;
; encerrar_overflow não retorna, pois encerra o processo.
; ============================================================

.overflow:
    call    encerrar_overflow

    ; Esta instrução não deve ser alcançada.
    ; Evita que o fluxo continue caso encerrar_overflow seja
    ; alterada incorretamente no futuro.
    ud2

BITS 32

; ============================================================
; subtracao.asm
;
; Função exportada:
;   executar_subtracao(precisao) -> EAX
;
; Parâmetro:
;   [EBP + 8] = precisão
;       0 -> operandos de 16 bits
;       1 -> operandos de 32 bits
;
; Retorno:
;   EAX = resultado da subtração
;
; Em caso de overflow:
;   mostra "OCORREU OVERFLOW." e encerra o programa.
; ============================================================

global executar_subtracao

extern ler_primeiro_operando
extern ler_segundo_operando
extern mostrar_resultado
extern encerrar_overflow

; Constantes compartilhadas com o arquivo principal.
%include "constantes.inc"

section .text


; ============================================================
; executar_subtracao(precisao) -> EAX
;
; Variáveis locais:
;   [EBP - 4]  = primeiro operando
;   [EBP - 8]  = segundo operando
;   [EBP - 12] = resultado
; ============================================================

executar_subtracao:
    push    ebp
    mov     ebp, esp

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
    je      .subtrair16

    jmp     .subtrair32


; ============================================================
; Subtração assinada de 32 bits
;
; OF = 1 quando o resultado não pode ser representado em
; um inteiro assinado de 32 bits.
; ============================================================

.subtrair32:
    ; Calcula primeiro_operando - segundo_operando.
    mov     eax, [ebp - 4]
    sub     eax, [ebp - 8]
    jo      .overflow

    mov     [ebp - 12], eax
    jmp     .mostrar_resultado


; ============================================================
; Subtração assinada de 16 bits
;
; OF = 1 quando o resultado não pode ser representado em
; um inteiro assinado de 16 bits.
; ============================================================

.subtrair16:
    ; Calcula primeiro_operando - segundo_operando usando 16 bits.
    mov     ax, [ebp - 4]
    sub     ax, [ebp - 8]
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

BITS 32

; ============================================================
; mod.asm
;
; Função exportada:
;   executar_mod(precisao) -> EAX
;
; Parâmetro:
;   [EBP + 8] = precisão
;       0 -> 16 bits
;       1 -> 32 bits
;
; Retorno:
;   EAX = resto da divisão inteira com sinal
; ============================================================

global executar_mod

extern ler_primeiro_operando
extern ler_segundo_operando
extern mostrar_resultado
extern mostrar_erro_divisao_zero
extern encerrar_overflow

; Constantes compartilhadas com o arquivo principal.
%include "constantes.inc"

section .text


; ============================================================
; executar_mod(precisao) -> EAX
;
; Variáveis locais:
;   [EBP - 4]  = dividendo
;   [EBP - 8]  = divisor
;   [EBP - 12] = resto
; ============================================================

executar_mod:
    push    ebp
    mov     ebp, esp

    sub     esp, 12

    ; Lê o dividendo.
    push    dword   [ebp + 8]
    call    ler_primeiro_operando
    add     esp, 4

    mov     [ebp - 4], eax

    ; Lê o divisor.
    push    dword   [ebp + 8]
    call    ler_segundo_operando
    add     esp, 4

    mov     [ebp - 8], eax

    ; Divisão por zero é inválida também para módulo.
    cmp     dword [ebp - 8], 0
    je      .divisao_por_zero

    ; Seleciona a rotina conforme a precisão.
    cmp     dword [ebp + 8], PRECISAO_16
    je      .mod16


; ============================================================
; Módulo assinado de 32 bits
;
; Depois de IDIV:
;   EAX = quociente
;   EDX = resto
; ============================================================

.mod32:
    ; IDIV também gera exceção para INT32_MIN / -1, mesmo que
    ; o resto matemático fosse zero.
    cmp     dword [ebp - 4], 0x80000000
    jne     .executar_mod32

    cmp     dword [ebp - 8], -1
    je      .overflow

.executar_mod32:
    ; Estende o sinal de EAX para EDX:EAX antes de IDIV.
    mov     eax, [ebp - 4]
    cdq

    idiv    dword [ebp - 8]

    ; O resto da divisão de 32 bits fica em EDX.
    mov     eax, edx
    mov     [ebp - 12], eax

    jmp     .mostrar


; ============================================================
; Módulo assinado de 16 bits
;
; Depois de IDIV:
;   AX = quociente
;   DX = resto
; ============================================================

.mod16:
    ; IDIV gera exceção para -32768 / -1.
    cmp     dword [ebp - 4], -32768
    jne     .executar_mod16

    cmp     dword [ebp - 8], -1
    je      .overflow

.executar_mod16:
    ; Estende o sinal de AX para DX:AX antes de IDIV.
    mov     ax, word [ebp - 4]
    cwd

    idiv    word [ebp - 8]

    ; O resto está em DX. Ele é estendido com sinal para EAX.
    movsx   eax, dx
    mov     [ebp - 12], eax


; ============================================================
; Mostra e retorna o resultado.
; ============================================================

.mostrar:
    ; mostrar_resultado(precisao, resultado)
    push    dword   [ebp - 12]
    push    dword   [ebp + 8]
    call    mostrar_resultado
    add     esp, 8

    ; Retorna o resto em EAX.
    mov     eax, [ebp - 12]

    mov     esp, ebp
    pop     ebp
    ret


; ============================================================
; Divisão por zero
; ============================================================

.divisao_por_zero:
    call    mostrar_erro_divisao_zero

    ; Não há um resultado válido. Retorna zero apenas para
    ; manter a convenção de retorno da função.
    xor     eax, eax

    mov     esp, ebp
    pop     ebp
    ret


; ============================================================
; Overflow da divisão usada para calcular o módulo
; ============================================================

.overflow:
    call    encerrar_overflow

    ; encerrar_overflow não retorna.

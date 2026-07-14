BITS 32

; ============================================================
; divisao.asm
;
; Função exportada:
;   executar_divisao(precisao) -> EAX
;
; Parâmetro:
;   [EBP + 8] = precisão
;       0 -> 16 bits
;       1 -> 32 bits
;
; Retorno:
;   EAX = quociente da divisão inteira com sinal
; ============================================================

global executar_divisao

extern ler_primeiro_operando
extern ler_segundo_operando
extern mostrar_resultado
extern mostrar_erro_divisao_zero
extern encerrar_overflow

; Constantes compartilhadas com o arquivo principal.
%include "constantes.inc"

section .text


; ============================================================
; executar_divisao(precisao) -> EAX
;
; Variáveis locais:
;   [EBP - 4]  = dividendo
;   [EBP - 8]  = divisor
;   [EBP - 12] = quociente
; ============================================================

executar_divisao:
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

    ; Divisão por zero é inválida nas duas precisões.
    cmp     dword [ebp - 8], 0
    je      .divisao_por_zero

    ; Seleciona a rotina conforme a precisão.
    cmp     dword [ebp + 8], PRECISAO_16
    je      .dividir16


; ============================================================
; Divisão assinada de 32 bits
;
; Antes de IDIV:
;   EDX:EAX = dividendo de 64 bits
;
; Depois de IDIV:
;   EAX = quociente
;   EDX = resto
; ============================================================

.dividir32:
    ; O caso INT32_MIN / -1 produz 2147483648, que não cabe
    ; em um inteiro assinado de 32 bits. Se IDIV fosse
    ; executada, o processador geraria uma exceção.
    cmp     dword [ebp - 4], 0x80000000
    jne     .executar_divisao32

    cmp     dword [ebp - 8], -1
    je      .overflow

.executar_divisao32:
    mov     eax, [ebp - 4]

    ; Estende o sinal de EAX para EDX:EAX.
    cdq

    idiv    dword [ebp - 8]

    mov     [ebp - 12], eax
    jmp     .mostrar


; ============================================================
; Divisão assinada de 16 bits
;
; Antes de IDIV:
;   DX:AX = dividendo de 32 bits
;
; Depois de IDIV:
;   AX = quociente
;   DX = resto
; ============================================================

.dividir16:
    ; O caso -32768 / -1 produz 32768, que não cabe em um
    ; inteiro assinado de 16 bits.
    cmp     dword [ebp - 4], -32768
    jne     .executar_divisao16

    cmp     dword [ebp - 8], -1
    je      .overflow

.executar_divisao16:
    mov     ax, word [ebp - 4]

    ; Estende o sinal de AX para DX:AX.
    cwd

    idiv    word [ebp - 8]

    ; O retorno geral do programa é feito por EAX.
    ; Portanto, estende-se o quociente de AX para EAX.
    movsx   eax, ax
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

    ; Retorna o quociente em EAX.
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
; Overflow da divisão
; ============================================================

.overflow:
    call    encerrar_overflow

    ; encerrar_overflow termina o processo e não retorna.

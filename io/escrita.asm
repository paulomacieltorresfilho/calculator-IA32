BITS 32

; ============================================================
; escrita.asm
;
; Funções exportadas:
;   imprimir_string(endereco, tamanho)
;   imprimir_numero32(valor)
;   imprimir_numero16(valor)
; ============================================================

global imprimir_string
global imprimir_numero32
global imprimir_numero16

; Constantes compartilhadas com o arquivo principal.
%include "constantes.inc"


section .text


; ============================================================
; imprimir_string(endereco, tamanho)
;
; [EBP + 8]  = endereço da string
; [EBP + 12] = quantidade de bytes
;
; Esta é a única função que executa SYS_WRITE para strings.
; Não possui retorno semântico.
; ============================================================

imprimir_string:
    push    ebp
    mov     ebp, esp

    ; Preserva EBX porque ele será usado como argumento da syscall.
    push    ebx

    ; Executa SYS_WRITE para escrever a string em STDOUT.
    mov     eax, SYS_WRITE
    mov     ebx, STDOUT
    mov     ecx, [ebp + 8]
    mov     edx, [ebp + 12]
    int     80h

    pop     ebx

    mov     esp, ebp
    pop     ebp
    ret


; ============================================================
; imprimir_numero32(valor)
;
; [EBP + 8] = inteiro assinado de 32 bits
;
; Converte o número para texto usando um buffer local.
; ============================================================

imprimir_numero32:
    push    ebp
    mov     ebp, esp

    ; Buffer local de 16 bytes.
    sub     esp, 16

    ; Preserva os registradores usados pela conversão e impressão.
    push    ebx
    push    esi
    push    edi

    ; Carrega o valor a ser impresso.
    mov     eax, [ebp + 8]

    ; ESI = 1 quando o número é negativo.
    xor     esi, esi

    ; Se o número já é positivo, a magnitude está pronta.
    test    eax, eax
    jns     .magnitude_pronta

    ; Marca o número como negativo.
    mov     esi, 1

    ; Para INT_MIN, o padrão 0x80000000 é mantido.
    ; Ele será tratado como magnitude sem sinal por DIV.
    neg     eax

.magnitude_pronta:
    ; Escreve os dígitos de trás para frente.
    ;
    ; EDI aponta para o último byte do buffer.
    ; ECX contém a quantidade de caracteres.
    lea     edi, [ebp - 1]
    xor     ecx, ecx

    ; Trata o valor zero como caso especial.
    test    eax, eax
    jnz     .converter

    mov     byte [edi], '0'
    dec     edi
    inc     ecx
    jmp     .adicionar_sinal

.converter:
    ; Divide por 10 para extrair o último dígito em EDX.
    xor     edx, edx
    mov     ebx, 10
    div     ebx

    ; Converte o dígito para ASCII e grava no buffer.
    add     dl, '0'
    mov     [edi], dl

    dec     edi
    inc     ecx

    ; Continua enquanto ainda houver quociente para converter.
    test    eax, eax
    jnz     .converter

.adicionar_sinal:
    ; Se o número era negativo, adiciona o sinal antes dos dígitos.
    test    esi, esi
    jz      .imprimir

    mov     byte [edi], '-'
    dec     edi
    inc     ecx

.imprimir:
    ; EDI estava uma posição antes do início do texto; avança para
    ; apontar para o primeiro caractere a ser impresso.
    inc     edi

    push    ecx
    push    edi
    call    imprimir_string
    add     esp, 8

    pop     edi
    pop     esi
    pop     ebx

    mov     esp, ebp
    pop     ebp
    ret


; ============================================================
; imprimir_numero16(valor)
;
; [EBP + 8] = valor cujo WORD inferior contém o número
; ============================================================

imprimir_numero16:
    push    ebp
    mov     ebp, esp

    ; Estende o WORD inferior com sinal para imprimir como 32 bits.
    movsx   eax, word [ebp + 8]

    push    eax
    call    imprimir_numero32
    add     esp, 4

    mov     esp, ebp
    pop     ebp
    ret

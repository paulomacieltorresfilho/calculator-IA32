BITS 32

; ============================================================
; leitura.asm
;
; Funções exportadas:
;   ler_string(buffer, capacidade) -> EAX
;   ler_numero32()                 -> EAX
;   ler_numero16()                 -> EAX
; ============================================================

global ler_string
global ler_numero32
global ler_numero16

extern imprimir_string

; Constantes compartilhadas com o arquivo principal.
%include "constantes.inc"


section .data

    msg_numero_invalido:
        db "Número inválido. Digite novamente: "
    msg_numero_invalido_len equ $ - msg_numero_invalido

    msg_numero16_invalido:
        db "O número deve estar entre -32768 e 32767. "
        db "Digite novamente: "
    msg_numero16_invalido_len equ $ - msg_numero16_invalido


section .text


; ============================================================
; ler_string(buffer, capacidade) -> EAX
;
; [EBP + 8]  = endereço do buffer onde a string será salva
; [EBP + 12] = capacidade total do buffer
;
; Retorno:
;   EAX = tamanho da string sem '\n' ou '\r\n'
;
; O buffer é terminado com zero.
; ============================================================

ler_string:
    push    ebp
    mov     ebp, esp

    ; Variáveis locais:
    ;   [EBP - 4] = tamanho da string
    ;   [EBP - 8] = byte temporário usado para limpar a entrada
    sub     esp, 8

    ; Preserva os registradores usados pela função.
    push    ebx
    push    esi
    push    edi

    ; Inicializa o tamanho da string com 0.
    mov     dword [ebp - 4], 0

    ; Carrega os argumentos: endereço do buffer e capacidade total.
    mov     edi, [ebp + 8]
    mov     esi, [ebp + 12]

    ; Prepara a syscall read para ler da entrada padrão.
    mov     eax, SYS_READ
    mov     ebx, STDIN
    mov     ecx, edi

    ; Lê no máximo capacidade_total - 1 bytes para deixar espaço
    ; para o terminador '\0'.
    mov     edx, esi
    dec     edx

    int     80h

    ; EAX guarda a quantidade de bytes lidos, ou um valor de erro.
    ; Se não leu nada ou deu erro, termina a execução.
    cmp     eax, 0
    jle     .fim

    ; Salva temporariamente o número de bytes lidos como tamanho.
    mov     [ebp - 4], eax

    ; Usa ECX como índice para procurar o '\n'.
    xor     ecx, ecx

.procurar_enter:
    ; Se chegou ao final dos bytes lidos sem encontrar '\n',
    ; trata a entrada como string sem ENTER no buffer.
    cmp     ecx, [ebp - 4]
    jae     .sem_enter

    ; Se o caractere atual for '\n', termina a busca.
    cmp     byte [edi + ecx], 10
    je      .encontrou_enter

    inc     ecx
    jmp     .procurar_enter

.encontrou_enter:
    ; Substitui o '\n' por '\0' e guarda em EAX o tamanho
    ; real da string, sem o ENTER.
    mov     byte [edi + ecx], 0
    mov     eax, ecx

    ; Remove também '\r', caso a entrada seja "\r\n".
    ; Se o tamanho é 0, não há nada antes de '\n'; logo, não há '\r'.
    test    eax, eax
    jz      .guardar_tamanho

    ; Verifica se o último caractere antes de '\n' é '\r'.
    ; Se não for, guarda o tamanho atual.
    cmp     byte [edi + eax - 1], 13
    jne     .guardar_tamanho

    ; Se for, subtrai 1 do tamanho e troca o '\r' por '\0'.
    dec     eax
    mov     byte [edi + eax], 0

.guardar_tamanho:
    ; Salva o tamanho final da string.
    mov     [ebp - 4], eax
    jmp     .fim

.sem_enter:
    ; Caso não haja '\n', usa o tamanho lido até aqui e coloca
    ; um '\0' no final do que pôde ser guardado.
    mov     eax, [ebp - 4]
    mov     byte [edi + eax], 0

    ; Se o buffer ficou cheio, descarta o restante da linha.
    mov     edx, esi
    dec     edx

    ; Se a quantidade lida não ocupou toda a área disponível,
    ; não há excesso para descartar.
    cmp     eax, edx
    jne     .fim

.descartar_restante:
    ; Limpa a entrada lendo cada byte restante até chegar em '\n'.
    mov     eax, SYS_READ
    mov     ebx, STDIN
    lea     ecx, [ebp - 8]
    mov     edx, 1
    int     80h

    ; Se não conseguir ler o caractere, termina a execução.
    cmp     eax, 1
    jne     .fim

    cmp     byte [ebp - 8], 10
    jne     .descartar_restante

.fim:
    ; Retorna sempre o tamanho salvo em [EBP - 4], pois EAX pode
    ; ter sido sobrescrito por leituras feitas ao descartar excesso.
    mov     eax, [ebp - 4]

    pop     edi
    pop     esi
    pop     ebx

    mov     esp, ebp
    pop     ebp
    ret


; ============================================================
; ler_numero32() -> EAX
;
; Lê uma linha inteira e converte para inteiro assinado.
;
; Intervalo aceito:
;   -2147483648 até 2147483647
; ============================================================

ler_numero32:
    push    ebp
    mov     ebp, esp

    ; Buffer local:
    ;   [EBP - 16] até [EBP - 1]
    sub     esp, TAMANHO_NUMERO

    ; Preserva os registradores usados pela conversão.
    push    ebx
    push    esi
    push    edi

.tentar:
    ; Lê a entrada textual para o buffer local.
    lea     eax, [ebp - TAMANHO_NUMERO]

    push    dword   TAMANHO_NUMERO
    push    eax
    call    ler_string
    add     esp, 8

    ; ECX recebe o tamanho da string lida.
    mov     ecx, eax

    ; Entrada vazia é inválida.
    test    ecx, ecx
    jz      .invalido

    ; Inicializa os registradores de controle:
    ;   ESI = índice atual da string
    ;   EBX = 0 para positivo, 1 para negativo
    xor     esi, esi
    xor     ebx, ebx

    ; EDI aponta para o início do buffer local.
    lea     edi, [ebp - TAMANHO_NUMERO]

    ; Verifica se o número começa com sinal negativo.
    cmp     byte [edi], '-'
    jne     .verificar_positivo

    ; Marca o número como negativo e pula o sinal.
    mov     ebx, 1
    inc     esi
    jmp     .verificar_digitos

.verificar_positivo:
    ; Verifica se o número começa com sinal positivo.
    cmp     byte [edi], '+'
    jne     .verificar_digitos

    ; Pula o sinal positivo.
    inc     esi

.verificar_digitos:
    ; Não pode haver somente o sinal.
    cmp     esi, ecx
    jae     .invalido

    ; EAX será o acumulador positivo.
    xor     eax, eax

.converter:
    ; Se todos os caracteres foram consumidos, aplica o sinal.
    cmp     esi, ecx
    jae     .aplicar_sinal

    ; Carrega o caractere atual.
    movzx   edx, byte [edi + esi]

    ; Caracteres antes de '0' não são dígitos.
    cmp     edx, '0'
    jb      .invalido

    ; Caracteres depois de '9' não são dígitos.
    cmp     edx, '9'
    ja      .invalido

    ; Converte o caractere ASCII para valor numérico.
    sub     edx, '0'

    ; Antes de:
    ;
    ;   acumulador = acumulador * 10 + dígito
    ;
    ; verifica se o limite de 32 bits será ultrapassado.
    ;
    ; Limites:
    ;   positivo: 2147483647
    ;   negativo: 2147483648
    cmp     eax, 214748364
    ja      .invalido

    jne     .acumular

    ; Se o acumulador está no limite, o último dígito permitido
    ; depende do sinal do número.
    test    ebx, ebx
    jnz     .limite_negativo

    cmp     edx, 7
    ja      .invalido
    jmp     .acumular

.limite_negativo:
    cmp     edx, 8
    ja      .invalido

.acumular:
    ; Atualiza o acumulador com o dígito atual.
    imul    eax, eax, 10
    add     eax, edx

    inc     esi
    jmp     .converter

.aplicar_sinal:
    ; Se o número é positivo, retorna o acumulador como está.
    test    ebx, ebx
    jz      .retornar

    ; Para -2147483648, EAX contém 0x80000000.
    ; NEG mantém esse padrão de bits, que representa INT_MIN.
    neg     eax

.retornar:
    pop     edi
    pop     esi
    pop     ebx

    mov     esp, ebp
    pop     ebp
    ret

.invalido:
    ; Informa que a entrada é inválida e tenta novamente.
    push    dword   msg_numero_invalido_len
    push    dword   msg_numero_invalido
    call    imprimir_string
    add     esp, 8

    jmp     .tentar


; ============================================================
; ler_numero16() -> EAX
;
; Retorna o valor de 16 bits com extensão de sinal para EAX.
;
; Intervalo aceito:
;   -32768 até 32767
; ============================================================

ler_numero16:
    push    ebp
    mov     ebp, esp

.tentar:
    ; Reaproveita a leitura de 32 bits e valida o intervalo de 16 bits.
    call    ler_numero32

    ; Valores abaixo de -32768 não cabem em inteiro assinado de 16 bits.
    cmp     eax, -32768
    jl      .fora_intervalo

    ; Valores acima de 32767 também não cabem.
    cmp     eax, 32767
    jg      .fora_intervalo

    mov     esp, ebp
    pop     ebp
    ret

.fora_intervalo:
    ; Informa o erro de intervalo e pede outro número.
    push    dword   msg_numero16_invalido_len
    push    dword   msg_numero16_invalido
    call    imprimir_string
    add     esp, 8

    jmp     .tentar

section .data

    WELCOME         db  'Bem-vindo. Digite seu nome: ',
    WELCOME_LEN     EQU $-WELCOME

    HOLA_PREFIX     db 'Hola, '
    HOLA_PREFIX_LEN EQU $-HOLA_PREFIX
    HOLA_SUFFIX     db ', bem-vindo ao programa de CALC IA-32'
    HOLA_SUFFIX_LEN EQU $-HOLA_SUFFIX

    NWLN            db 0Dh, 0Ah
    NWLN_LEN        EQU $-NWLN

    PRECISION       db 'Vai trabalhar com 16 ou 32 bits (digite 0 para 16, e 1 para 32): '
    PRECISION_LEN   EQU $-PRECISION

    MENU_0         db 'ESCOLHA UMA OPÇÃO:'
    MENU_0_LEN     EQU $-MENU_0
    MENU_1         db '- 1: SOMA',
    MENU_1_LEN     EQU $-MENU_1
    MENU_2         db '- 2: SUBTRACAO',
    MENU_2_LEN     EQU $-MENU_2
    MENU_3         db '- 3: MULTIPLICACAO',
    MENU_3_LEN     EQU $-MENU_3
    MENU_4         db '- 4: DIVISAO',
    MENU_4_LEN     EQU $-MENU_4
    MENU_5         db '- 5: EXPONENCIACAO',
    MENU_5_LEN     EQU $-MENU_5
    MENU_6         db '- 6: MOD',
    MENU_6_LEN     EQU $-MENU_6
    MENU_7         db '- 7: SAIR',
    MENU_7_LEN     EQU $-MENU_7

    MAX_16BIT_NUM     EQU 32767 ; + e -
    MAX_16BIT_LEN     EQU 7 ; sinal + 5 digitos + \n
    MAX_32BIT_NUM     EQU 2147483647 ; + e -
    MAX_32BIT_LEN     EQU 12 ; sinal + 10 digitos + \n

section .bss
    digit_buffer resb 1
    num_buffer resb MAX_32BIT_LEN
    precision resb 1
    username resb 16

section .text
global _start

_start:
    call welcome_user
    call get_precision
    call menu

exit:
    mov eax, 1
    mov ebx, 0
    int 80h

get_precision:
    enter 0,0
    push eax

    push PRECISION
    push PRECISION_LEN
    call print

    call read_digit

    mov [precision], al

    pop eax
    leave
    ret

welcome_user:
    enter 0,0
    push eax

    push WELCOME
    push WELCOME_LEN
    call print

    push username
    push 16
    call read_string

    sub eax, 1 ; remove newline

    push HOLA_PREFIX
    push HOLA_PREFIX_LEN
    call print

    push username
    push eax
    call print

    push HOLA_SUFFIX
    push HOLA_SUFFIX_LEN
    call println

    pop eax
    leave
    ret

menu:
    enter 0,0

    menu_loop: 
        call print_menu

        call read_digit

        cmp al, 7 ; SAIR
        je exit

        jmp menu_loop

    leave
    ret

print_menu:
    enter 0,0

    push MENU_0
    push MENU_0_LEN
    call println

    push MENU_1
    push MENU_1_LEN
    call println

    push MENU_2
    push MENU_2_LEN
    call println

    push MENU_3
    push MENU_3_LEN
    call println

    push MENU_4
    push MENU_4_LEN
    call println

    push MENU_5
    push MENU_5_LEN
    call println

    push MENU_6
    push MENU_6_LEN
    call println

    push MENU_7
    push MENU_7_LEN
    call println

    leave
    ret

; FUNCOES AUXILIARES

; printnum (*value)
printnum:
    enter 0,0
    push eax
    push ebx
    push ecx
    push edx

    mov ecx, [EBP+8]
    xor ebx, ebx
    mov bl, [ecx]
    add bl, 0x30
    mov [ecx], ebx

        
    mov eax, 4
    mov ebx, 1
    mov edx, 1
    int 80h

    pop edx
    pop ecx
    pop ebx
    pop eax
    leave
    ret 4

; print (*str, size)
print:
    enter 0,0
    push eax
    push ebx
    push ecx
    push edx

    mov eax, 4
    mov ebx, 1
    mov ecx, [EBP+12]
    mov edx, [EBP+8]
    int 80h

    pop edx
    pop ecx
    pop ebx
    pop eax

    leave
    ret 8 

; println (*str, size)
println:
    enter 0,0
    push eax
    push ebx
    push ecx
    push edx

    mov eax, 4
    mov ebx, 1
    mov ecx, [EBP+12]
    mov edx, [EBP+8]
    int 80h

    mov eax, 4
    mov ebx, 1
    mov ecx, NWLN
    mov edx, NWLN_LEN
    int 80h

    pop edx
    pop ecx
    pop ebx
    pop eax

    leave
    ret 8

;  read_string (*str, size) -> tamanho da string
read_string:
    enter 0,0
    push eax
    push ebx
    push ecx
    push edx

    mov eax, 3
    mov ebx, 0
    mov ecx, [EBP+12]
    mov edx, [EBP+8]
    int 80h ; eax -> tamanho da string inputada

    pop edx
    pop ecx
    pop ebx
    add esp, 4 ; pop eax

    leave
    ret 8

; read_digit () -> digito (em al)
read_digit:
    enter 0,0

    push digit_buffer
    push 2
    call read_string

    xor eax, eax
    mov al, [digit_buffer]
    sub al, 0x30

    leave
    ret


; read_num32 () -> numero
read_num32:
    enter 0,0
    push esi
    push ebx
    push ecx

    xor esi, esi
    xor eax, eax
    xor ebx, ebx
    xor ecx, ecx

    push num_buffer
    push MAX_32BIT_LEN
    call read_string

    ; bl = 1 se negativo, bl = 0 se positivo

    cmp BYTE [num_buffer], 0x2D
    SETE bl ; se number_s[0] == '-' -> bl = 1

    cmp BYTE [num_buffer], 0X2B
    SETE cl ; se number_s[0] == '+' -> cl = 1

    cmp cl, bl ; al = 1 se for caracter de sinal
    jz read_char_loop ; Se ZF = 1 (al e bl forem iguals), pula para o loop sem incrementar o index
    inc esi

    read_char_loop:
        movzx ecx, BYTE [num_buffer+esi]
        cmp ecx, 0x30
        jb read_loop_end
        cmp ecx, 0x39
        ja read_loop_end
        sub ecx, 0x30
        imul eax, eax, 10
        add eax, ecx
        inc esi
        jmp read_char_loop

    read_loop_end:
        cmp bl, 0
        je read_end
        neg eax
        
    read_end:
        pop ecx
        pop ebx
        pop esi
    leave
    ret
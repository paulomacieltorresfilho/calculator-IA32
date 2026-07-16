section .data

    WELCOME         db  'Bem-vindo. Digite seu nome: ',
    WELCOME_LEN     EQU $-WELCOME

    HOLA_PREFIX     db 'Hola, '
    HOLA_PREFIX_LEN EQU $-HOLA_PREFIX
    HOLA_SUFFIX     db ', bem-vindo ao programa de CALC IA-32', 0Dh, 0Ah
    HOLA_SUFFIX_LEN EQU $-HOLA_SUFFIX

    NWLN            db 0Dh, 0Ah
    NWLN_LEN        EQU $-NWLN

    PRECISION       db 'Vai trabalhar com 16 ou 32 bits (digite 0 para 16, e 1 para 32): '
    PRECISION_LEN   EQU $-PRECISION

    MENU_0         db 'ESCOLHA UMA OPÇÃO:', 0Dh, 0Ah
    MENU_0_LEN     EQU $-MENU_0
    MENU_1         db '- 1: SOMA', 0Dh, 0Ah
    MENU_1_LEN     EQU $-MENU_1
    MENU_2         db '- 2: SUBTRACAO', 0Dh, 0Ah
    MENU_2_LEN     EQU $-MENU_2
    MENU_3         db '- 3: MULTIPLICACAO', 0Dh, 0Ah
    MENU_3_LEN     EQU $-MENU_3
    MENU_4         db '- 4: DIVISAO', 0Dh, 0Ah
    MENU_4_LEN     EQU $-MENU_4
    MENU_5         db '- 5: EXPONENCIACAO', 0Dh, 0Ah
    MENU_5_LEN     EQU $-MENU_5
    MENU_6         db '- 6: MOD', 0Dh, 0Ah
    MENU_6_LEN     EQU $-MENU_6
    MENU_7         db '- 7: SAIR', 0Dh, 0Ah
    MENU_7_LEN     EQU $-MENU_7

    MINUS_SIGN        db 0x2D

    OVERFLOW_MSG        db 'OCORREU OVERFLOW', 0Dh, 0Ah
    OVERFLOW_MSG_LEN    EQU $-OVERFLOW_MSG

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
global _start, read_num32, read_num16
extern soma, subtracao, multiplicacao, divisao, mod, exponenciacao

_start:
    call welcome_user
    call get_precision
    call menu
    call exit

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
    call print

    pop eax
    leave
    ret

menu:
    enter 4,0
    push eax

    mov dword [ebp-4], 0

    menu_loop: 
        call print_menu
        call read_digit

        cmp al, 7 ; SAIR
        je menu_exit

        cmp al, 1
        je menu_soma

        cmp al, 2
        je menu_subtracao

        cmp al, 3
        je menu_multiplicacao

        cmp al, 4
        je menu_divisao

        cmp al, 5
        je menu_exp

        cmp al, 6
        je menu_mod

        jmp menu_exit

    menu_soma:        
        push dword [precision]
        call soma
        jmp menu_print_result

    menu_subtracao:
        push dword [precision]
        call subtracao
        jmp menu_print_result

    menu_multiplicacao:
        push dword [precision]
        call multiplicacao
        jo menu_overflow
        jmp menu_print_result

    menu_divisao:
        push dword [precision]
        call divisao
        jmp menu_print_result

    menu_mod:
        push dword [precision]
        call mod
        jmp menu_print_result

    menu_exp:
        push dword [precision]
        call exponenciacao
        jo menu_overflow
        jmp menu_print_result

    menu_print_result:
        cmp byte [precision], 0
        je menu_result_16
        push eax
        call print_num32
        jmp menu_continue_loop
    
    menu_result_16:        
        push ax
        call print_num16

    menu_continue_loop:    
        call read_digit
        jmp menu_loop

    menu_exit:   
        pop eax 
        leave
        ret

    menu_overflow:
        push OVERFLOW_MSG
        push OVERFLOW_MSG_LEN
        call print
        call exit

print_menu:
    enter 0,0

    push MENU_0
    push MENU_0_LEN
    call print

    push MENU_1
    push MENU_1_LEN
    call print

    push MENU_2
    push MENU_2_LEN
    call print

    push MENU_3
    push MENU_3_LEN
    call print

    push MENU_4
    push MENU_4_LEN
    call print

    push MENU_5
    push MENU_5_LEN
    call print

    push MENU_6
    push MENU_6_LEN
    call print

    push MENU_7
    push MENU_7_LEN
    call print

    leave
    ret

; FUNCOES AUXILIARES

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

; print_num32 (value)
print_num32:
   enter 0,0
    
    mov eax, [EBP+8]
    xor esi, esi

    cmp eax, 0
    jge print_num32_aux_loop
    push MINUS_SIGN
    push 1
    call print
    mov eax, [EBP+8] 
    neg eax

    
    print_num32_aux_loop:
        xor edx, edx
        mov ecx, 10
        div ecx
        add dl, 0x30
        push dx
        cmp eax, 0
        je print_num32_loop
        inc esi
        jmp print_num32_aux_loop

    print_num32_loop:
        pop dx
        mov [digit_buffer], dl
        push digit_buffer
        push 1
        call print
        dec esi
        cmp esi, 0
        jge print_num32_loop  

    print_num32_end:
        push NWLN
        push NWLN_LEN
        call print
        leave
        ret 4

; print_num16 (value)
print_num16:
    enter 0,0
    
    mov ax, word [EBP+8]
    xor esi, esi

    cmp ax, 0
    jge print_num16_aux_loop
    push MINUS_SIGN
    push 1
    call print
    mov ax, word [EBP+8] 
    neg ax
    
    print_num16_aux_loop:
        xor dx, dx
        mov cx, 10
        div cx
        add dl, 0x30
        push dx
        cmp ax, 0
        je print_num16_loop
        inc esi
        jmp print_num16_aux_loop

    print_num16_loop:
        pop dx
        mov [digit_buffer], dl
        push digit_buffer
        push 1
        call print
        dec esi
        cmp esi, 0
        jge print_num16_loop  

    print_num16_end:
        push NWLN
        push NWLN_LEN
        call print
        leave
        ret 2

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
    jz read_char_setup ; Se ZF = 1 (al e bl forem iguals), pula para o loop sem incrementar o index
    inc esi

    read_char_setup:
        xor eax, eax
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

; read_num16 () -> numero
read_num16:
    enter 0,0
    push esi
    push ebx
    push ecx

    xor esi, esi
    xor eax, eax
    xor ebx, ebx
    xor ecx, ecx

    push num_buffer
    push MAX_16BIT_LEN
    call read_string

    ; bl = 1 se negativo, bl = 0 se positivo

    cmp BYTE [num_buffer], 0x2D
    SETE bl ; se number_s[0] == '-' -> bl = 1

    cmp BYTE [num_buffer], 0X2B
    SETE cl ; se number_s[0] == '+' -> cl = 1

    cmp cl, bl ; cl = 1 se for caracter de sinal
    jz read_char_setup_16 ; Se ZF = 1 (cl e bl forem iguals), pula para o loop sem incrementar o index
    inc esi

    read_char_setup_16:
        xor ax, ax
    read_char_loop_16:
        movzx cx, BYTE [num_buffer+esi]
        cmp cx, 0x30
        jb read_loop_end_16
        cmp cx, 0x39
        ja read_loop_end_16
        sub cx, 0x30
        imul ax, ax, 10
        add ax, cx
        inc esi
        jmp read_char_loop_16

    read_loop_end_16:
        cmp bl, 0
        je read_end_16
        neg ax
        
    read_end_16:
        pop ecx
        pop ebx
        pop esi
        leave
        ret

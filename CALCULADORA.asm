section .data

WELCOME         db  'Bem-vindo. Digite seu nome: ', 0
WELCOME_LEN     EQU $-WELCOME

HOLA_PREFIX     db 'Hola, '
HOLA_PREFIX_LEN EQU $-HOLA_PREFIX
HOLA_SUFFIX     db ', bem-vindo ao programa de CALC IA-32'
HOLA_SUFFIX_LEN EQU $-HOLA_SUFFIX

NWLN            db 0Dh, 0Ah
NWLN_LEN        EQU $-NWLN

PRECISION       db 'Vai trabalhar com 16 ou 32 bits (digite 0 para 16, e 1 para 32): '
PRECISION_LEN   EQU $-PRECISION

username_len    dd 16
    
section .bss
precision resb 1
username resb 16

section .text
global _start
; extern soma

_start:
    enter 4,0
    push WELCOME
    push WELCOME_LEN
    call print

    call print_hola

    call get_precision

    push precision
    call printnum

exit:
    mov eax, 1
    mov ebx, 0
    int 80h

get_precision:
    enter 0,0

    push PRECISION
    push PRECISION_LEN
    call print

    push precision
    push 1
    call read_string

    mov eax, [precision]
    sub eax, 0x30

    mov [precision], eax ;ARRUMAR

    leave
    ret

print_hola:
    enter 0,0

    push username
    push DWORD [username_len]
    call read_string

    sub al, 1
    mov byte [username_len], al

    push HOLA_PREFIX
    push HOLA_PREFIX_LEN
    call print

    push username
    push DWORD [username_len]
    call print

    push HOLA_SUFFIX
    push HOLA_SUFFIX_LEN
    call println

    leave
    ret


; printnum (value)
printnum:
    enter 0,0

    mov ecx, [EBP+8]
    mov ecx, [ecx]
    add ecx, 0x30
        
    mov eax, 4          ; write syscall
    mov ebx, 1          ; stdout
    mov edx, 1          ; 1 byte
    int 80h

    leave
    ret 4

; print (*str, size)
print:
    enter 0,0

    mov eax, 4
    mov ebx, 1
    mov ecx, [EBP+12]
    mov edx, [EBP+8]
    int 80h

    leave
    ret 8 

; println (*str, size)
println:
    enter 0,0

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

    leave
    ret 8

;  read_string (*str, size)
read_string:
    enter 0,0

    mov eax, 3
    mov ebx, 0
    mov ecx, [EBP+12]
    mov edx, [EBP+8]
    int 80h ; eax -> tamanho da string inputada

    leave
    ret 8


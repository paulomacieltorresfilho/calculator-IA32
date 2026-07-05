section .data

WELCOME         db  'Bem-vindo. Digite seu nome: ', 0
WELCOME_LEN     EQU $-WELCOME

HOLA_PREFIX     db 'Hola, '
HOLA_PREFIX_LEN EQU $-HOLA_PREFIX
HOLA_SUFFIX     db ', bem-vindo ao programa de CALC IA-32'
HOLA_SUFFIX_LEN EQU $-HOLA_SUFFIX

NWLN            db 0Dh, 0Ah
NWLN_LEN        EQU $-NWLN

username_len    dd 16
    
section .bss
digit_buffer resb 1
username resb 16

section .text
global _start
; extern soma

_start:
    push WELCOME
    push WELCOME_LEN
    call print
    add esp, 8

    push username
    push DWORD [username_len]
    call read_string
    add esp, 8

    sub al, 1
    mov byte [username_len], al

    call print_hola

exit:
    mov eax, 1
    mov ebx, 0
    int 80h

print_hola:
    enter 0,0
    push HOLA_PREFIX
    push HOLA_PREFIX_LEN
    call print
    add esp, 8

    push username
    push DWORD [username_len]
    call print
    add esp, 8

    push HOLA_SUFFIX
    push HOLA_SUFFIX_LEN
    call println
    add esp, 8

    leave
    ret


; printnum (value)
printnum:
    enter 0,0

    mov eax, [EBP+8]
    add eax, 48         ; Convert to ASCII
    
    mov byte [digit_buffer], al  ; Store character in buffer
    
    mov eax, 4          ; write syscall
    mov ebx, 1          ; stdout
    mov ecx, digit_buffer  ; pointer to buffer
    mov edx, 1          ; 1 byte
    int 80h

    leave
    ret

; print (*str, size)
print:
    enter 0,0

    mov eax, 4
    mov ebx, 1
    mov ecx, [EBP+12]
    mov edx, [EBP+8]
    int 80h

    leave
    ret

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
    ret

;  read_string (*str, size)
read_string:
    enter 0,0

    mov eax, 3
    mov ebx, 0
    mov ecx, [EBP+12]
    mov edx, [EBP+8]
    int 80h ; eax -> tamanho da string inputada

    leave
    ret


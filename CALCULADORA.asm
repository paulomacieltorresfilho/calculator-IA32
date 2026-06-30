section .data
msg         db  'Bem-vindo. Digite seu nome: ', 0
MSGSIZE     EQU $-msg
nwln        db 0Dh, 0Ah
NWLNSIZE    EQU $-nwln

section .text
global _start

_start:
    push msg
    push MSGSIZE
    call println

exit:
    mov eax, 1
    mov ebx, 0
    int 80h

; FUNÇÃO DE PRINTAR 
print:
    enter 0,0
    mov eax, 4
    mov ebx, 1
    mov ecx, [EBP+12]
    mov edx, [EBP+8]
    int 80h
    leave
    ret


; FUNÇÃO DE PRINTAR COM NEW LINE
println:
    enter 0,0

    mov eax, 4
    mov ebx, 1
    mov ecx, [EBP+12]
    mov edx, [EBP+8]
    int 80h

    mov eax, 4
    mov ebx, 1
    mov ecx, nwln
    mov edx, NWLNSIZE
    int 80h

    leave
    ret


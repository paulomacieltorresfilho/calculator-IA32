section .text
global divisao
extern read_num32
extern read_num16

divisao:
    enter 0,0
    cmp byte [EBP+8], 0
    je divisao16

    push ebx
    push edx
    call read_num32
    mov ebx, eax

    call read_num32

    mov edx, eax
    mov eax, ebx
    mov ebx, edx ; eax -> primeiro numero, ebx -> divisor

    cdq ; estende o sinal de eax para edx (edx:eax)

    idiv ebx
    
    pop edx
    pop ebx
    leave
    ret 4

divisao16:
    push bx
    push dx
    xor eax, eax

    call read_num16
    mov bx, ax

    call read_num16

    mov dx, ax
    mov ax, bx
    mov bx, dx

    cwd ; estende o sinal de ax para dx (dx:ax)

    idiv bx
    
    pop dx
    pop bx
    leave
    ret 4

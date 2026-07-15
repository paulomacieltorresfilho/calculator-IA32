section .text
global mod
extern read_num32
extern read_num16

mod:
    enter 0,0
    cmp byte [EBP+8], 0
    je mod16

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

    mov eax, edx
    
    pop edx
    pop ebx
    leave
    ret 4

mod16:
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

    mov ax, dx
    
    pop dx
    pop bx
    leave
    ret 4

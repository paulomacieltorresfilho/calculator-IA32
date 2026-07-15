section .text
global multiplicacao
extern read_num32
extern read_num16

multiplicacao:
    enter 0,0
    cmp byte [EBP+8], 0
    je multiplicacao16

    push ebx
    call read_num32
    mov ebx, eax

    call read_num32
    
    imul ebx, eax
    mov eax, ebx

    pop ebx
    leave
    ret 4

multiplicacao16:
    push bx
    xor eax, eax

    call read_num16
    mov bx, ax

    call read_num16

    imul bx, ax
    mov ax, bx

    pop bx
    leave
    ret 4

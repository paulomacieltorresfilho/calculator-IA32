section .text
global exponenciacao
extern read_num32
extern read_num16

exponenciacao:
    enter 0,0
    cmp byte [EBP+8], 0
    je exponenciacao16

    push ebx
    push ecx
    call read_num32
    mov ebx, eax

    call read_num32

    ; ebx^eax

    cmp eax, 0
    jle exp_zero

    mov ecx, ebx

    exp_loop:
        imul ebx, ecx
        jo exp_exit
        sub eax, 1
        cmp eax, 1
        je exp_exit_loop
        jmp exp_loop

    exp_exit_loop:
        mov eax, ebx
        jmp exp_exit
    
    exp_zero:
        mov eax, 1
        jmp exp_exit

    exp_exit:
        pop ecx
        pop ebx
        leave
        ret 4

exponenciacao16:
    push bx
    push cx
    call read_num16
    mov bx, ax

    call read_num16

    ; ebx^eax

    cmp ax, 0
    jle exp_zero16

    mov cx, bx

    exp_loop16:
        imul bx, cx
        jo exp_exit16
        sub ax, 1
        cmp ax, 1
        je exp_exit_loop16
        jmp exp_loop16

    exp_exit_loop16:
        mov ax, bx
        jmp exp_exit16
    
    exp_zero16:
        mov ax, 1
        jmp exp_exit16

    exp_exit16:
        pop cx
        pop bx
        leave
        ret 4

section .data
    num  dd  33213030
    minus_sign db 0x2D

section .bss
    digit_buffer resb 1

section .text

global _start

_start:
    enter 0,0
    
    mov eax, [num]
    xor esi, esi

    cmp eax, 0
    jge loop
    mov eax, 4
    mov ebx, 1
    mov ecx, minus_sign
    mov edx, 1
    int 80h
    mov eax, [num]
    neg eax

    
loop:
    xor edx, edx
    mov ecx, 10
    div ecx
    add dl, 0x30
    push dx
    cmp eax, 0
    je print_loop
    inc esi
    jmp loop

print_loop:
    pop dx
    mov [digit_buffer], dl
    mov eax, 4
    mov ebx, 1
    mov ecx, digit_buffer
    mov edx, 1
    int 80h
    dec esi
    cmp esi, 0
    jge print_loop
    

end:
    leave
    mov eax, 1
    mov ebx, 0
    int 80h
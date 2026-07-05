section .text
global soma

soma:
    enter 0,0
    mov eax, [EBP+12]
    add eax, [EBP+8]
    leave
    ret

section .data
number_s db '+2147483647', 0xd, 0xa


section .text
global _start

_start:
xor esi, esi
xor eax, eax
xor ebx, ebx
xor ecx, ecx

; bl = 1 se negativo, bl = 0 se positivo

cmp BYTE [number_s], 0x2D
SETE bl ; se number_s[0] == '-' -> bl = 1

cmp BYTE [number_s], 0X2B
SETE cl ; se number_s[0] == '+' -> cl = 1

cmp cl, bl ; al = 1 se for caracter de sinal
jz read_char_loop ; Se ZF = 1 (al e bl forem iguals), pula para o loop sem incrementar o index
inc esi

read_char_loop:
    movzx ecx, BYTE [number_s+esi]
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

mov eax, 1
mov ebx, 0
int 80h
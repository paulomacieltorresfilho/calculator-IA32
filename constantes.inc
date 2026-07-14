; ============================================================
; Constantes compartilhadas
; ============================================================

%ifndef CONSTANTES_INC
%define CONSTANTES_INC 1

; Syscalls Linux IA-32
%define SYS_EXIT    1
%define SYS_READ    3
%define SYS_WRITE   4

; Descritores padrão
%define STDIN       0
%define STDOUT      1

; Precisão
%define PRECISAO_16 0
%define PRECISAO_32 1

; Opções do menu
%define OP_SOMA          1
%define OP_SUBTRACAO     2
%define OP_MULTIPLICACAO 3
%define OP_DIVISAO       4
%define OP_EXPONENCIACAO 5
%define OP_MOD           6
%define OP_SAIR          7

; Tamanhos de buffers globais
%define TAMANHO_NOME     64
%define TAMANHO_NUMERO   16

%endif

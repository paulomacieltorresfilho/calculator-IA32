
# Projeto 2 - Software Básico

## Paulo Maciel Torres Filho - 200025937

### Para rodar o código:

Requisitos:
- Máquina Linux (foi testado em um Linux Mint)
- Nasm
- Ld


Para montar cada arquivo .asm:
```bash
nasm -f elf -o nome_arquivo.o nome_arquivo.asm
```

Para ligar o projeto:
``` bash
ld -m elf_i386 CALCULADORA.o SOMA.o SUB.o MUL.o DIV.o MOD.o -o program
```

Finalmente, para rodar o projeto, basta rodar o executável gerado com `./program`



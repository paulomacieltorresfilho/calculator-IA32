# Calculadora IA-32

Calculadora interativa escrita em Assembly IA-32 para Linux, usando `int 80h`.
O programa trabalha com inteiros assinados em dois modos de precisão:

- `0`: operandos/resultados de 16 bits
- `1`: operandos/resultados de 32 bits

## Estrutura

```text
.
├── calculadora.asm
├── constantes.inc
├── io/
│   ├── escrita.asm
│   └── leitura.asm
└── operacoes/
    ├── divisao.asm
    ├── exponenciacao.asm
    ├── mod.asm
    ├── multiplicacao.asm
    ├── soma.asm
    └── subtracao.asm
```

`calculadora.asm` contém o fluxo principal, menu, mensagens de UI e despacho das
operações. `io/` concentra leitura/conversão de entrada e escrita/conversão de
saída. `operacoes/` contém as operações matemáticas. `constantes.inc` centraliza
constantes compartilhadas.

## Requisitos

- Linux
- `nasm`
- `ld` com suporte a `elf_i386`
- terminal configurado com locale UTF-8 para exibir acentos corretamente

Em sistemas 64 bits, a montagem e linkedição ainda usam formato IA-32; para
executar o binário, o sistema precisa permitir execução de programas 32 bits.

## Como Compilar

```sh
make
```

Isso gera o binário:

```text
calculadora
```

Para executar:

```sh
make run
```

Para limpar artefatos:

```sh
make clean
```

## Operações

O menu implementa:

- soma
- subtração
- multiplicação
- divisão inteira com sinal
- exponenciação inteira
- módulo/resto da divisão inteira com sinal
- sair

## Corretude Atual

O projeto está completo como calculadora interativa básica:

- todas as seis operações do menu possuem implementação;
- os módulos montam separadamente;
- o programa completo linka corretamente;
- as constantes compartilhadas estão centralizadas em `constantes.inc`;
- leitura/escrita e operações foram separadas em diretórios próprios.

Tratamentos implementados:

- overflow em soma, subtração, multiplicação e exponenciação;
- divisão por zero em divisão e módulo;
- casos de overflow de `INT_MIN / -1` em divisão e módulo;
- validação de entrada numérica de 32 bits;
- validação de intervalo para modo 16 bits;
- rejeição de expoente negativo.

## Limitações Conhecidas

- A entrada foi pensada para uso interativo. Testes com `printf | ./calculadora`
  podem ser enganosos porque a syscall `read` pode consumir mais de uma linha de
  uma vez.
- A exponenciação aceita apenas expoentes inteiros não negativos.
- O programa não possui uma suíte automatizada de testes.
- As strings usam UTF-8; limites de entrada continuam sendo medidos em bytes, não
  em caracteres visíveis.

## Validação Manual

Os comandos abaixo devem montar e linkar o projeto:

```sh
make clean
make
```

Também é possível montar manualmente os módulos, por exemplo:

```sh
nasm -f elf32 calculadora.asm -o /tmp/calculadora.o
nasm -f elf32 io/leitura.asm -o /tmp/leitura.o
nasm -f elf32 io/escrita.asm -o /tmp/escrita.o
nasm -f elf32 operacoes/soma.asm -o /tmp/soma.o
```

## Licença

Este projeto é distribuído sob a licença MIT. Consulte `LICENSE` para os
termos completos.

NASM := nasm
LD := ld

BUILD_DIR := build
TARGET := calculadora

ASFLAGS := -f elf32
LDFLAGS := -m elf_i386

SOURCES := \
	calculadora.asm \
	io/leitura.asm \
	io/escrita.asm \
	operacoes/soma.asm \
	operacoes/subtracao.asm \
	operacoes/multiplicacao.asm \
	operacoes/divisao.asm \
	operacoes/exponenciacao.asm \
	operacoes/mod.asm

OBJECTS := $(SOURCES:%.asm=$(BUILD_DIR)/%.o)

.PHONY: all run clean rebuild

all: $(TARGET)

$(TARGET): $(OBJECTS)
	$(LD) $(LDFLAGS) $(OBJECTS) -o $@

$(BUILD_DIR)/%.o: %.asm constantes.inc
	mkdir -p $(dir $@)
	$(NASM) $(ASFLAGS) $< -o $@

run: $(TARGET)
	./$(TARGET)

clean:
	rm -rf $(BUILD_DIR) $(TARGET)

rebuild: clean all

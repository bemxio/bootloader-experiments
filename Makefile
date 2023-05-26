# constants
AS = nasm
ASFLAGS = -f bin

QEMU = qemu-system-i386

SRC_DIR = src
BUILD_DIR = build

SOURCES = $(wildcard $(SRC_DIR)/*.asm)
BUILDS = $(patsubst $(SRC_DIR)/%.asm,$(BUILD_DIR)/%.bin,$(SOURCES))

# special targets
.PRECIOUS: $(BUILD_DIR)/%.bin # don't delete build binaries

# rules
%.asm: $(BUILD_DIR)/%.bin
	$(QEMU) -drive format=raw,file=$^

$(BUILD_DIR)/%.bin: $(SRC_DIR)/%.asm
	mkdir -p $(BUILD_DIR)

	$(AS) $(ASFLAGS) $^ -o $@

# targets
all: $(BUILDS)

clean:
	rm -rf $(BUILD_DIR)
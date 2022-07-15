
############################################################
#	BSP configs
############################################################
BSP ?= rpi3

QEMU_MISSING_STRING = “THE BOARD IS NOT YET SUPPORTED”

ifeq ($(BSP),rpi3)
	TARGET				= aarch64_a52
	KERNEL				= kernel8.img
	QEMU_BINARY			= qemu-system-aarch64
	QEMU_MACHINE_TYPE	= raspi3
	QEMU_RELEASE_ARGS	= -d in_asm -display none
	OBJDUMP_BINARY		= aarch64-elf-objdump
	NM_BINARY			= aarch64-elf-nm
	READELF_BINARY		= aarch64-elf-readelf
	LD_SCRIPT_PATH		= $(shell pwd)/src/bsp/rasp
	RUST_MISC_ARGS		= -C target-cpu = cortex-a53
endif

export LD_SCRIPT_PATH
# Export path of link script to sub commands i.e. build.rs

############################################################
#	Target configs
############################################################
CARGO_CONFIG	= Cargo.toml
KERNEL_LD		= kernel.ld
KERNEL_ELF		= target/$(TARGET)/release/kernel
LAST_BUILD		= target/$(BSP).build_config
KERNEL_ELF_DEPS	= $(filter-out %: ,$(file < $(KERNEL_ELF).d)) $(CARGO_CONFIG) $(LAST_BUILD)
# .d file is a auto-generated file indicating the dependancy of the main file
# filter-out %: take all words that do not obey the rules "%:"

############################################################
#	Building
############################################################
RUST_FLAGS = $(RUST_MISC_ARGS)	\
	-C link-arg=--library-path=$(LD_SCRIPT_PATH) \
	-C link-arg=--script=$(KERNEL_LD)

RUST_FLAGS_INGORE = $(RUST_FLAGS)\
	-D warnings
	-D missing_docs

FEATURES = --features $(BSP) 
# Conditional compilation args for cargo and rust

COMPILER_ARGS = --target=$(TARGET)\
	$(FEATURES)\
	--release

CARGO_COMPILE = cargo rustc ${COMPILER_ARGS}

CARGO_OBJCOPY = rust-objcopy\
	--strip-all\
	-O binary

QEMU_EXEC = $(QEMU_BINARY) -M $(QEMU_MACHINE_TYPE)



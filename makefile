
############################################################
#	BSP configs
############################################################
BSP ?= rpi3

QEMU_MISSING_STRING = “THE BOARD IS NOT YET SUPPORTED”

ifeq ($(BSP),rpi3)
	TARGET				= aarch64-unknown-none-softfloat
	KERNEL				= kernel8.img
	QEMU_BINARY			= qemu-system-aarch64
	QEMU_MACHINE_TYPE	= raspi3
	QEMU_RELEASE_ARGS	= -d in_asm -display none
	OBJDUMP_BINARY		= aarch64-elf-objdump
	NM_BINARY			= aarch64-elf-nm
	READELF_BINARY		= aarch64-elf-readelf
	LD_SCRIPT_PATH		= $(shell pwd)/src/bsp/rasp
	RUST_MISC_ARGS		= -C target-cpu=cortex-a53
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
	-W warnings					 \
	-W missing_docs

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


############################################################
# Docker
############################################################
DOCKER_IMAGE = dev
DOCKER_COMMAND = docker run -it --rm -v $(shell pwd):/work/tutorial -w /work/tutorial
DOCKER_QEMU =$(DOCKER_COMMAND) $(DOCKER_IMAGE)
DOCKER_TOOLS = $(DOCKER_COMMAND) $(DOCKER_IMAGE)

############################################################
# Target
############################################################
.PHONY: all qemu readelf objdump nm

all: ${KERNEL}

$(LAST_BUILD):
	@rm -f target/*.build_config
	@mkdir -p target
	@touch ${LAST_BUILD}

$(KERNEL_ELF):$(KERNEL_ELF_DEPS)
	@echo Compiling kernel elf files
	@RUSTFLAGS="${RUST_FLAGS_INGORE}" $(CARGO_COMPILE)

$(KERNEL): $(KERNEL_ELF)
	@echo Compiling kernel binary
	@${CARGO_OBJCOPY} ${KERNEL_ELF} ${KERNEL}

qemu: ${KERNEL}
	@echo Generating and running qe mu in docker
	${DOCKER_QEMU} ${QEMU_EXEC} ${QEMU_RELEASE_ARGS} -kernel ${KERNEL}

readelf: $(KERNEL_ELF)
	$(call color_header, "Launching readelf")
	@$(DOCKER_TOOLS) $(READELF_BINARY) --headers $(KERNEL_ELF)

objdump: $(KERNEL_ELF)
	$(call color_header, "Launching objdump")
	@$(DOCKER_TOOLS) $(OBJDUMP_BINARY) --disassemble --demangle \
                --section .text   \
				--section .rodata \
                $(KERNEL_ELF) | rustfilt

nm: $(KERNEL_ELF)
	$(call color_header, "Launching nm")
	@$(DOCKER_TOOLS) $(NM_BINARY) --demangle --print-size $(KERNEL_ELF) | sort | rustfilt
/* Start address of dram*/
__rpi_phys_dram_start_addr = 0;

/* Physical address the kernel binary will be loaded*/
__rpi_phys_binary_load_addr = 0x80000;

/* ENTRY command specify the first executable instruction */ 
ENTRY(__rpi_phys_binary_load_addr)

/* PHDR command specify the program headers 
* program headers will give system loader instructions on how the program should be loaded 
* once PHDRS is used, linker will not seek to generate another program header
* syntex of PHDRS is
* PHDRS{ name type flags} 
*   name: Section names defined in the section 
*   types: Several pre-defined types
*     PT_NULL
*     PT_LOAD
*     PT_DYNAMIC
*   flags:
*     4 := R  Read
*     5 := RX Read and execute
*     6 := RW Read and write
*/
PHDRS
{
    segment_code PT_LOAD FLAGS(5);
    segment_boot_core_stack PT_LOAD FLAGS(6);
    segment_data PT_LOAD FLAGS(6);
}

SECTIONS
{
    /* Dot "." variable contains the current output location counter */
    . = __rpi_phys_dram_start_addr;
    /* Stack space*/
    .boot_core_stack (NOLOAD):{
        . +=  __rpi_phys_binary_load_addr;
        __boot_core_stack = .;
    }:segment_boot_core_stack 
    /* Stack going upwards*/

    /* Source code */
    .text :
    {
        KEEP(*(.text._start))
        *(.text._start_arguments)
        *(.text._start_rust)
        *(.text*)
    } :segment_code
    /* :segment_code means assign this section to a segement described in the program header */
    .rodata : ALIGN(8) {*(.rodata*)} :segmnt_code

    /* Data */
    .data : {*(.data*)} :segment_data
    .bss (NOLOAD) : ALIGN(16){
        __bss_start = .;
        . = ALIGN(16);
        __bss_end_exclusive = .;
    } :segment_data

    /* MISC */
    .got : {*(.got*)}
    ASSERT(SIZEOF(.got) == 0, "Relocation support not expected")
}
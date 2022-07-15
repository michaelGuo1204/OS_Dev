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
}

SECTIONS
{
    /* Dot "." variable contains the current output location counter */
    . =  __rpi_phys_binary_load_addr;

    /* Source code */
    .text :
    {
        KEEP(*(.text._start))
    } :segement_code
    /* :segement_code means assign this section to a segement described in the program header */
}
//Relocation macros to load the address of a symbol
.macro ADR_REL register symbol
    adrp \register, \symbol
    add \register, \register, #:lo12:\symbol
.endm


.section .text._start 
//Section that contains the source code
.global _start
// Give symbol external linkage
.type _start, function

.size _start, . - _start

_start:
    mrs x1,MPIDR_EL1                 //Storage values in system register to x1 
    //Multiprocessor affinity register, EL1
    //MPIDER register own 3 aff values
    //Aff0: Identify individual threads within a core [7:0]
    //Aff1: Identify individual cpu within a source [15:8]([11:8 functional])
    //Aff2: Reserved
    and x1,x1,{CONST_CORE_ID_MASK}  //Bitwise add operation to get current id
    //AND Wd,Wn,Wm 
    //Wd = Wn&Wm
    ldr x2, BOOT_CORE_ID
    cmp x1,x2
    b.ne .L_parking_loop
    // Only cpu0 will excuate code hereafter

    // Initialize DRAM will bss values defined in ld
    ADR_REL x0,__bss_start
    ADR_REL x1,__bss_end_exclusive

.L_bss_init_loop:
    cmp x0,x1
    b.eq .L_prepare_rust
    stp xzr,xzr,[x0],#16
    // STP command store a pair of values into positions
    // STP wt1,wt2,[Xn|SP],#imm
    // Store value in wt1,wt2 in [Xn|SP] compute new offset address for [Xn]
    // Here we storage values in xzr register into [x0] let offset the address in [x0] by 16
    // xzr is a register that is all zero
    b   .L_bss_init_loop

.L_prepare_rust:
    ADR_REL x0,__boot_core_stack
    mov sp,x0
    b   __start_rust   
    // Booting procedure ends, init rust kernel

.L_parking_loop:
    wfe
    b .L_parking_loop


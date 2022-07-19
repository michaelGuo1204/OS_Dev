#![feature(asm_const)]
#![no_main]
#![no_std]
// System Setup Procedure
//  1. Kernel's entry point is cpu::boot::arch_boot::_start(), which is implemented in 
//      aarch64/cpu/boot.s
//  2. Once boot, boot procedure will call kernel_init() code, which will then call panic.

mod bsp;
mod cpu;
mod panicwait;

unsafe fn kernel_init() ->!{
    panic!()
}
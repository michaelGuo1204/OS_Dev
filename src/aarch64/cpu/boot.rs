
use core::arch::global_asm;

global_asm!(
    include_str!("boot.s"),
    CONST_CORE_ID_MASK = const 0b11);
// 0x0b11 = 0000 1011 0001 0001

#[no_mangle]
pub unsafe fn __start_rust() -> !{
    crate::kernel_init()
}
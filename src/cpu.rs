#[cfg(target_arch = "aarch64")]
#[path= "aarch64/cpu.rs"]
mod arch_cpu;

mod boot;

pub use arch_cpu::wait;
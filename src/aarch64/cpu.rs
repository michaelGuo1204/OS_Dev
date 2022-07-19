use cortex_a::asm;

pub fn wait()->!{
    loop{
        asm::wfe()
    }
}
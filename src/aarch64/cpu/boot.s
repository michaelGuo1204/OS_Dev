.section .text._start 
//Section that contains the source code
.global _start
// Give symbol external linkage
.type _start, function

.size _start, . - _start

_start:

.L_parking_loop:
    wfe
    b .L_parking_loop


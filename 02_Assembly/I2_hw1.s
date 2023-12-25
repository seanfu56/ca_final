.data
n: .word 10
.text
.globl __start

fact:
    addi sp, sp, -8
    sw x1, 4(sp)
    sw x10, 0(sp)
    slti x5, x10, 2
    beq x5, x0, L1
    addi x10, x0, 2
    addi sp, sp, 8
    
    jalr x0, 0(x1)
L1:
    #addi x10, x10, -1
    srli x10, x10, 1
    jal x1, fact
    addi x6, x10, 0
    lw x10, 0(sp)
    lw x1, 4(sp)
    addi sp, sp, 8
    addi x7, x0, 6
    addi x8, x0, 5
    mul x11, x10, x7
    mul x12, x6, x8
    add x10, x0, x11
    add x10, x10, x12
    addi x10, x10, 4
    #mul x10, x10, x6
    jalr x0, 0(x1)

__start:
    la t0, n
    lw x10, 0(t0)
    jal x1, fact
    la t0, n
    sw x10, 4(t0)
    addi a0, x0, 10
    ecall
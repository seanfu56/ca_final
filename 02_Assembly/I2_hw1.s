.data
    n: .word 10
    
.text
.globl __start

FUNCTION:
    # Todo: Define your own function in HW1
    # You should store the output into x10
  addi x18, x0, -1
  addi x29, x0, 1
  addi x11, x10, 0
  addi x31, x0, 0
  la x1, OUT
func:
  addi sp, sp, -12
  sw x31, 8(sp)
  sw x10, 4(sp)
  sw x1, 0(sp)
  srli x5, x10, 1
  bge x5, x29, L1
  addi x31, x0, 2
  lw x1, 0(sp)
  addi sp, sp, 4
  #ble x11, x0, OUT
  jalr x0, 0(x1)

L1:
  addi x28, x0, 6
  mul x28, x10, x28 
  add x31, x0, x28
  addi x31, x31, 4
  srli x10, x10, 1
  jal x1, func
  lw x10, 0(sp)
  lw x26, 4(sp)
  lw x1, 8(sp)
  addi sp, sp, 12
  
  # x30 = 5
  addi x30, x0, 5
  # x6 = 5 * x31
  mul x31, x31, x30
  
  add x31, x26, x31
  
  jalr x0, 0(x1)

OUT:
  addi x10, x31, 0    

# Do NOT modify this part!!!
__start:
    la   t0, n
    lw   x10, 0(t0)
    jal  x1,FUNCTION
    la   t0, n
    sw   x10, 4(t0)
    addi a0,x0,10
    ecall
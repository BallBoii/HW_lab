addi x5, x0, 2
addi x6, x0, 3
addi x7, x0, 2
beq x6, x5, NATTEE
beq x5, x7, BRANCH
NATTEE:
    addi x9, x0, 2
    beq x0, x0, EXIT
BRANCH:
    addi x8, x0, 5
    beq x0, x0, EXIT
EXIT:
    addi x20, x0, 55
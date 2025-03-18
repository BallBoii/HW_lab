addi x5, x0, 2
addi x6, x0, 3
addi x7, x0, 2
jal NATTEE          # Normally, return address will store in x1
addi x10, x0, 99
jal EXIT
NATTEE:
    addi x9, x0, 4
    jalr x0, x1, 0
AJARNYAM:
    addi x10, x0, 5
    jalr x0, x1, 0
EXIT:
    addi x11, x0, 9
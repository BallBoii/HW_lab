addi x5, x0, 2
addi x6, x0, 3
addi x7, x0, 2
bne x5, x7, AJKRERK
bne x5, x6, AJYAM

AJKRERK:
    addi x9, x0, 10
    
AJYAM:
    addi x10, x0, 11

blt x6, x7, MILKTEA
blt x7, x6, COFFEE

MILKTEA:
    addi x11, x0, 22

COFFEE:
    addi x12, x0, 33

bge x7, x6, AJEKAPOL
bge x6, x7, AJARTHIT

AJEKAPOL:
    addi x13, x0, 7

AJARTHIT:
    addi x14, x0, 1

bge x5, x7, GGEZ
addi x15, x0, 8

GGEZ:
    addi x16, x0, 9

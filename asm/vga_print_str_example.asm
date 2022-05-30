.data 0x0000
str: .asciiz "hello world"

.text 0x0000
main:
addi $4, $0, 0       # $4 str addr offset
and $2, $2, $0
lui $2, 0xffff       # $2 sw addr
ori $2, $2, 0xf000

addi $20, $0, 0x0F42
sw $20, 0($2)

# jal print_str        # call print_str

addi $20, $0, 0x0F43
sw $20, 0($2)

addi $0, $0, 0
addi $0, $0, 0
addi $0, $0, 0
addi $0, $0, 0
addi $0, $0, 0
j main               # forever loop

print_str:

lw $3, str($4)       # $3 str content

ori $5, $0, 0x0F00   # $5 sw data
andi $6, $3, 0x00FF  # $6 substr
beq $6, $0, exit     # check the \0 character
or $5, $5, $6        # add color info
sw $5, 0($2)
srl $3, $3, 8

andi $6, $3, 0x00FF
beq $6, $0, exit
or $5, $5, $6
sw $5, 1($2)
srl $3, $3, 8

andi $6, $3, 0x00FF
beq $6, $0, exit
or $5, $5, $6
sw $5, 2($2)
srl $3, $3, 8

andi $6, $3, 0x00FF
beq $6, $0, exit
or $5, $5, $6
sw $5, 3($2)

addi $4, $4, 4
addi $2, $2, 4

j print_str

# end print_str

exit:
jr $ra






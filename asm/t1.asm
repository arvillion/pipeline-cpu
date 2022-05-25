.data 0x0000				      		
	buf: .word 0x0000
.text 0x0000						
start: 
	lui   $1,0xFFFF			
    ori  $28,$1,0xF000 # base
	ori  $27,$2,0xFFFF # and this to get low 16 bits
	ori $26,$26,1 # c==1
begin:
	add $3,$0,$0 # counter for tasks
	lw  $1,0xC70($28) # ini input
	srl  $2,$1,20 # ? 23~20 bits
	and $4,$26,$2 # 4-->ready for next input
	srl  $2,$2,1 # 2-->op
	# jump to tasks
	beq $2,$3,test0 # t0
	addi $3,$3,1
	beq $2,$3,test1 # t1
	addi $3,$3,1
	beq $2,$3,test2 # t2
	addi $3,$3,1
	beq $2,$3,test3 # t3
	addi $3,$3,1
	beq $2,$3,test4 # t3
	addi $3,$3,1
	beq $2,$3,test5 # t5
	addi $3,$3,1
	beq $2,$3,test6 # t6
	addi $3,$3,1
	beq $2,$3,test7 # t7
	j begin
test0:
	# input a
	and $5,$1,$27 # input a--> $5
	addi $8,$0,0 # ini $8

bits_count_loop:
	srl $5,$5,1	
	addi $8,$8,1	# $8--> size of a
	bne $5,$0,bits_count_loop

	# ???????????
	add $9,$0,$0 # $9-->palindrome
	and $5,$1,$27 # data-->$5

move_palindrome:
	addi $8,$8,-1
	and $10,$26,$5 # $10-->each bit for input
	sllv $10,$10,$8
	or $9,$9,$10 # move to ans
	srl $5,$5,1 
	bne $0,$8,move_palindrome

	and $5,$1,$27
	bne $9,$5,show_palindrome
	sll $8,$26,23
	or $5,$5,$8 # move the sign to the output
show_palindrome:
	sw $5,0xC70($28) 
	j begin
test1:
	# input a
	beq $4,$26,t1ReadB
	and $5,$1,$27 # input a--> $5
	sw $5,0xC70($28) # output
	j begin
t1ReadB:
	# input b
	and $6,$1,$27 # input b--> $6
	sw $6,0xC70($28) 
	j begin
test2:
	# &
	and $7,$5,$6 # output
	sw $7,0xC70($28)
	j begin
test3:
	# |
	or $7,$5,$6
	sw $7,0xC70($28)
	j begin
test4:
	# ^
	xor $7,$5,$6
	sw $7,0xC70($28)
	j begin
test5:
	# <<
	sllv $7,$5,$6
	sw $7,0xC70($28)
	j begin
test6:
	# >>
	srlv $7,$5,$6
	sw $7,0xC70($28)
	j begin
test7:
	# >>>
	srav $7,$5,$6
	sw $7,0xC70($28)
	j begin
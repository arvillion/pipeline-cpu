.data 0x0000				      		
	buf: .space 200
.text 0x0000						
start: 
	lui   $1,0xFFFF			
	ori  $28,$1,0xF000 # base
	lui   $1,0xFFFF			
	ori  $30,$1,0xE000 # base for 7seg
	ori  $27,$2,0xFFFF # and this to get low 16 bits
	ori $26,$26,1 # c==1
	# clean
	add $2,$28,$0
	addi $3,$2,2400
clean_vga:
	sw $0,0($2) # use 0 to clean vga
	addi $2,$2,1
	bne $2,$3,clean_vga

	add $2,$0,$0
	add $3,$0,$0
	
begin:
	# ini the print info of the vga
	ori $21,$0,0x0f61 # black white a
	sw $21,1($28) # row 0 col 0
	ori $21,$0,0x0f3A # black white :
	sw $21,2($28) # row 0 col 1

	ori $21,$0,0x0f62 # black white b
	sw $21,81($28) # row 1 col 0
	ori $21,$0,0x0f3A # black white :
	sw $21,82($28) # row 1 col 1

	ori $21,$0,0x0f6f # black white 0
	sw $21,161($28) # row 2 col 0
	ori $21,$0,0x0f70 # black white p
	sw $21,162($28) # row 2 col 1
	ori $21,$0,0x0f3A # black white :
	sw $21,163($28) # row 2 col 2
	
	ori $21,$0,0x0f6f # black white o
	sw $21,241($28) # row 3 col 0
	ori $21,$0,0x0f75 # black white u
	sw $21,242($28) # row 3 col 1
	ori $21,$0,0x0f74 # black white t
	sw $21,243($28) # row 3 col 2
	ori $21,$0,0x0f70 # black white p
	sw $21,244($28) # row 3 col 3
	ori $21,$0,0x0f75 # black white u
	sw $21,245($28) # row 3 col 4
	ori $21,$0,0x0f74 # black white t
	sw $21,246($28) # row 3 col 5
	ori $21,$0,0x0f3A # black white :
	sw $21,247($28) # row 3 col 5


	add $3,$0,$0 # counter for tasks
	lw  $1,0xC70($30) # ini input
	srl  $2,$1,20 # ? 23~20 bits
	and $4,$26,$2 # 4-->ready for next input
	srl  $2,$2,1 # 2-->op
	# jump to tasks
	# TODO: show the op on the VGA
	addi $21,$2,48
	sw $21,0x144($28) # row 2 col 2
	
	beq $2,$3,test0 # t0
	addi $3,$3,1
	beq $2,$3,test1 # t1
	addi $3,$3,1
	beq $2,$3,test2 # t2
	addi $3,$3,1
	beq $2,$3,test3 # t3
	addi $3,$3,1
	beq $2,$3,test4 # t4
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
	sw $5,0xc70($28) 
	# TODO: show the sign on VGA
	andi $24,$5,0xFFFF # value to be print
	addi $25,$0,6 # row 3 col 5
	j print_answer

test1:
	# input a
	beq $4,$26,t1ReadB
	and $5,$1,$27 # input a--> $5
	sw $5,0xC70($28) # output

	andi $24,$5,0xFFFF # value to be print on vga
	addi $25,$0,6 # poision row 0 
	j print_answer

t1ReadB:
	# input b
	and $6,$1,$27 # input b--> $6
	sw $6,0xC70($28) 

	andi $24,$6,0xFFFF # value to be print
	addi $25,$0,86 # poision row 1 
	j print_answer
test2:
	# &
	and $7,$5,$6 # output
	sw $7,0xC70($28)
	
	andi $24,$7,0xFFFF # value to be print
	addi $25,$0,251 # poision row 3 col 7
	j print_answer
test3:
	# |
	or $7,$5,$6
	sw $7,0xC70($28)

	andi $24,$7,0xFFFF # value to be print
	addi $25,$0,251 # poision row 3 col 7
	j print_answer
test4:
	# ^
	xor $7,$5,$6
	sw $7,0xC70($28)
	
	andi $24,$7,0xFFFF # value to be print
	addi $25,$0,251 # poision row 3 col 7
	j print_answer
test5:
	# <<
	sllv $7,$5,$6
	sw $7,0xC70($28)

	andi $24,$7,0xFFFF # value to be print
	addi $25,$0,251 # poision row 3 col 7
	j print_answer
test6:
	# >>
	srlv $7,$5,$6
	sw $7,0xC70($28)

	andi $24,$7,0xFFFF # value to be print
	addi $25,$0,251 # poision row 3 col 7
	j print_answer
test7:
	# >>>
	lui $8,0xFFFF
	add $8,$8,$5 # to find the difference between >> and >>>
	srav $7,$8,$6
	ori $8,$0,0xFFFF
	and $7,$8,$7
	sw $7,0xC70($28)

	andi $24,$7,0xFFFF # value to be print
	addi $25,$0,251 # poision row 3 col 7
	j print_answer

print_answer:
	addi $29,$0,5
	# $25 position for the last char 
	# $24 are the char to print-->show this 4 bits by 4 bits 
print_answer_ini:	
	addi $29,$29,-1
	beq $29,$0,print_continue # stop

	andi $21,$24,0xF # number wait to print
	
	srl $24,$24,4 # prepare for next print
	
	addi $23,$0,0xF
	beq $23,$21,print_F
	addi $23,$23,-1
	beq $23,$21,print_E
	addi $23,$23,-1
	beq $23,$21,print_D
	addi $23,$23,-1
	beq $23,$21,print_C
	addi $23,$23,-1
	beq $23,$21,print_B
	addi $23,$23,-1
	beq $23,$21,print_A
	addi $23,$23,-1
	beq $23,$21,print_9
	addi $23,$23,-1
	beq $23,$21,print_8
	addi $23,$23,-1
	beq $23,$21,print_7
	addi $23,$23,-1
	beq $23,$21,print_6
	addi $23,$23,-1
	beq $23,$21,print_5
	addi $23,$23,-1
	beq $23,$21,print_4
	addi $23,$23,-1
	beq $23,$21,print_3
	addi $23,$23,-1
	beq $23,$21,print_2
	addi $23,$23,-1
	beq $23,$21,print_1
	addi $23,$23,-1
	beq $23,$21,print_0
	addi $23,$23,-1
	j begin
print_F:
	addi $21,$0,0x0F46 # black white F
	add $22,$25,$28
	sw $21,0($22)
	addi $25,$25,-1 # address for the front number
	j print_answer_ini
print_E:
	addi $21,$0,0x0F45 # black white E
	add $22,$25,$28
	sw $21,0($22)
	addi $25,$25,-1 # address for the front number
	j print_answer_ini
print_D:
	addi $21,$0,0x0F44 # black white D
	add $22,$25,$28
	sw $21,0($22)
	addi $25,$25,-1 # address for the front number
	j print_answer_ini
print_C:
	addi $21,$0,0x0F43 # black white 
	add $22,$25,$28
	sw $21,0($22)
	addi $25,$25,-1 # address for the front number
	j print_answer_ini
print_B:
	addi $21,$0,0x0F42 # black white B
	add $22,$25,$28
	sw $21,0($22)
	addi $25,$25,-1 # address for the front number
	j print_answer_ini
print_A:
	addi $21,$0,0x0F41 # black white A
	add $22,$25,$28
	sw $21,0($22)
	addi $25,$25,-1 # address for the front number
	j print_answer_ini
print_9:
	addi $21,$0,0x0F39 # black white 9
	add $22,$25,$28
	sw $21,0($22)
	addi $25,$25,-1 # address for the front number
	j print_answer_ini
print_8:
	addi $21,$0,0x0F38 # black white 8
	add $22,$25,$28
	sw $21,0($22)
	addi $25,$25,-1 # address for the front number
	j print_answer_ini
print_7:
	addi $21,$0,0x0F37 # black white 7
	add $22,$25,$28
	sw $21,0($22)
	addi $25,$25,-1 # address for the front number
	j print_answer_ini
print_6:
	addi $21,$0,0x0F36 # black white 6
	add $22,$25,$28
	sw $21,0($22)
	addi $25,$25,-1 # address for the front number
	j print_answer_ini
print_5:
	addi $21,$0,0x0F35 # black white 5
	add $22,$25,$28
	sw $21,0($22)
	addi $25,$25,-1 # address for the front number
	j print_answer_ini
print_4:
	addi $21,$0,0x0F34 # black white 4
	add $22,$25,$28
	sw $21,0($22)
	addi $25,$25,-1 # address for the front number
	j print_answer_ini
print_3:
	addi $21,$0,0x0F33 # black white 3
	add $22,$25,$28
	sw $21,0($22)
	addi $25,$25,-1 # address for the front number
	j print_answer_ini
print_2:
	addi $21,$0,0x0F32 # black white 2
	add $22,$25,$28
	sw $21,0($22)
	addi $25,$25,-1 # address for the front number
	j print_answer_ini
print_1:
	addi $21,$0,0x0F31 # black white 1
	add $22,$25,$28
	sw $21,0($22)
	addi $25,$25,-1 # address for the front number
	j print_answer_ini
print_0:
	addi $21,$0,0x0F30 # black white 0
	add $22,$25,$28
	sw $21,0($22)
	addi $25,$25,-1 # address for the front number
	j print_answer_ini


	j begin
print_continue:
	addi $29,$2,48
	sw $29,164($28)
	j begin
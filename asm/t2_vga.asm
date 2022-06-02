.data 0x0000
	buf: .space 200				      		
.text 0x0000						
start: 
	lui   $1,0xFFFF			
	ori  $28,$1,0xF000 # base
	lui   $1,0xFFFF			
	ori  $30,$1,0xF000 # base for seg7

	# clean the vga
	add $2,$28,$0
	addi $3,$2,2400
clean_vga:
	sw $0,0($2) # use 0 to clean vga
	addi $2,$2,1
	bne $2,$3,clean_vga

	add $2,$0,$0
	add $3,$0,$0

	# ini the print info of the vga
	ori $21,$0,0x0f30 # black white 0
	sw $21,1($28) # row 0 col 0

	ori $21,$0,0x0f3A # black white :
	sw $21,2($28) # row 0 col 1

	ori $21,$0,0x0f31 # black white 1
	sw $21,81($28) # row 1 col 0

	ori $21,$0,0x0f3A # black white :
	sw $21,82($28) # row 1 col 1

	ori $21,$0,0x0f32 # black white 2
	sw $21,161($28) # row 2 col 0

	ori $21,$0,0x0f3A # black white :
	sw $21,162($28) # row 2 col 1

	ori $21,$0,0x0f33 # black white 3
	sw $21,241($28) # row 3 col 0

	ori $21,$0,0x0f3A # black white :
	sw $21,242($28) # row 3 col 1

	ori $21,$0,0x0f34 # black white 4
	sw $21,321($28) # row 4 col 0

	ori $21,$0,0x0f3A # black white :
	sw $21,322($28) # row 4 col 1

	ori $21,$0,0x0f35 # black white 5
	sw $21,401($28) # row 5 col 0

	ori $21,$0,0x0f3A # black white :
	sw $21,402($28) # row 5 col 1

	ori $21,$0,0x0f36 # black white 6
	sw $21,481($28) # row 6 col 0

	ori $21,$0,0x0f3A # black white :
	sw $21,482($28) # row 6 col 1

	ori $21,$0,0x0f37 # black white 7
	sw $21,561($28) # row 7 col 0

	ori $21,$0,0x0f3A # black white :
	sw $21,562($28) # row 7 col 1

	ori $21,$0,0x0f38 # black white 8
	sw $21,641($28) # row 8 col 0 

	ori $21,$0,0x0f3A # black white :
	sw $21,642($28) # row 8 col 1

	ori $21,$0,0x0f39 # black white 9
	sw $21,721($28) # row 9 col 0

	ori $21,$0,0x0f3A # black white :
	sw $21,722($28) # row 9 col 1

	ori $21,$0,0x0f6f # black white o
	sw $21,801($28) # row 10 col 1
	ori $21,$0,0x0f70 # black white p
	sw $21,802($28) # row 10 col 1
	ori $21,$0,0x0f3A # black white :
	sw $21,803($28) # row 10 col 2

	ori $21,$0,0x0f6f # black white o
	sw $21,881($28) # row 11 col 1
	ori $21,$0,0x0f75 # black white u
	sw $21,882($28) # row 11 col 1
	ori $21,$0,0x0f74 # black white t
	sw $21,883($28) # row 11 col 2
	ori $21,$0,0x0f70 # black white p
	sw $21,884($28) # row 11 col 1
	ori $21,$0,0x0f75 # black white u
	sw $21,885($28) # row 11 col 1
	ori $21,$0,0x0f74 # black white t
	sw $21,886($28) # row 11 col 2
	ori $21,$0,0x0f3A # black white :
	sw $21,887($28) # row 11 col 2

begin:
	add $3,$0,$0 # counter for tasks
	lw  $1,0xC70($30) # ini input
	srl  $2,$1,20 # 23~20 bits
	andi $4,$2,1 # 4-->ready for next input
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
	# $4 ready check
	beq $4,$5,begin
	sw $1,0xC70($28) # show
	add $5,$4,$0 # store ready
	# no size-->back
	bne $6,$0,next_input
	# read the size
	andi $6,$1,0xFFFF # $6-->size
	sw $6,0xC70($28) # show
	add $7,$0,$0 # ini index
	
	addi $9,$0,4 # ini address for VGA
	# space
	add $27,$0,$0
	j begin
next_input:
	# $7 index
	# $9 address for 7
	beq $7,$6,show_set0_full # size == index--> not change
	andi $8,$1,0xFF # 8-->next_input
	sw $8,buf($27) # store next_input
	sw $8,0xC70($28) # show

	add $24,$0,$8
	add $25,$0,$9
	jal print_answer # show on the VGA

	addi $7,$7,1 
	addi $27,$27,4
	addi $9,$9,80
	j begin

show_set0_full:
	ori $25,$0,0xFFFF
	sw $25,0xC70($28) # show full
	j begin
	
test1:
	# unsign sort 
	add $8,$0,$27 # the base address for set1
	add $9,$8,$27 # on the front of set2
	add $9,$9,$27 # on the front of set3
	# the base address for temp
	add $9,$9,$27 # on the front of temp
	
	addi $10,$0,0 # address for set0
	addi $13,$0,0 # address for temp
move_set0_to_temp:
	lw $12,buf($10)
	add $13,$10,$9
	sw $12,buf($13)
	addi $10,$10,4
	bne $10,$27,move_set0_to_temp
	
	add $12,$0,$8 # address for set1
	add $17,$12,$27 # end address for set1
loop_for_set1_sort:
	# ini	
	add $13,$0,$0 # address bias for min
	addi $14,$0,0xFFFF # ini the value of min

	# address of min in temp
	# use for loop
	add $15,$9,$0 # ini as base address of temp
	add $18,$15,$27 # end address for temp
	add $16,$0,$0 # index-->next number

get_set0_min:
	lw $16,buf($15) # data from temp
	sltu $10,$14,$16 # $ 10==1  =>  $14(min)<$16 =>  continue
	bne $10,$0,set1_continue_test1
	# smaller than min
	add $14,$16,$0 # renew min
	add $13,$15,$0 # renew address of min
set1_continue_test1:
	addi $15,$15,4 # address+=4
	bne $15,$18,get_set0_min

	# clear the min-->set as a big number
	addi $20,$0,0xFFFF
	sw $20,buf($13)
	# store the min to set1
	sw $14,buf($12) # store the min into set1 one by one
	# address+=4	
	addi $12,$12,4
	# continues
	bne $12,$17,loop_for_set1_sort
	
	addi $25,$0,1
	sw $25,0xC70($28) # show t1 finish
	j begin

test2:
	# move set0 to set2 as sign number
	add $7,$0,$27 # on the front of set1
	add $7,$7,$27 # on the front of set2
	add $8,$0,$0 # ini address bias
move_set0_to_set2:
	lw $9,buf($8) # the data from set0
	# get the 7th bit as the sign bit
	addi $10,$0,1
	sll $10,$10,7 
	and $11,$10,$9 # sign bit
	beq $11,$0,move_set0_to_set2_continue # pos number do not need change
	
	# change if sign is neg
	addi $12,$0,0xFF # Reverse by bits
	xor $9,$9,$12 # change the low 8 bits
	or $9,$9,$10 # change the old sign bit as 1
	
	# make the high 24 bits are 1
	lui $13,0xFFFF
	ori $13,$13,0xFF00
	# Splice 
	or $9,$9,$13

	addi $9,$9,1
	
move_set0_to_set2_continue:
	add $12,$8,$7 # bias+address-->the target address in set2
	sw $9,buf($12)
	addi $8,$8,4
	bne $8,$27,move_set0_to_set2	

	addi $25,$0,2 
	sw $25,0xC70($28) # show t2 finish
	j begin


test3:
	# sign sort 
	add $8,$0,$27 # on the front of set1
	add $8,$8,$27 # on the front of set2 --> base for set2
	add $9,$8,$27 # on the front of set3
	# the base address for temp
	add $9,$9,$27 # on the front of temp
	
	addi $10,$0,0 # address bias
	addi $13,$0,0 # address for temp
move_set2_to_temp:
	add $19,$10,$8 # set2 target = base + bias
	lw $12,buf($19) # data from set2
	add $13,$10,$9 # temp target = base + bias
	sw $12,buf($13)
	addi $10,$10,4
	bne $10,$27,move_set2_to_temp
	
	add $12,$27,$8 # address for set3
	add $17,$12,$27 # end address for set3
loop_for_set2_sort:
	# ini	
	add $13,$0,$0 # address bias for min
	addi $14,$0,0x7FFF # ini the value of min

	# address of min in temp
	# use for loop
	add $15,$9,$0 # ini as base address of temp
	add $18,$15,$27 # end address for temp
	add $16,$0,$0 # index-->next number

get_set2_min:
	lw $16,buf($15) # data from temp
	slt $10,$14,$16 # $ 10==1  =>  $14(min)<$16 =>  continue
	bne $10,$0,t3_countune
	# smaller than min
	add $14,$16,$0 # renew min
	add $13,$15,$0 # renew address of min
t3_countune:
	addi $15,$15,4 # address+=4
	bne $15,$18,get_set2_min

	# clear the min-->set as a big number
	addi $20,$0,0x7FFF
	sw $20,buf($13)
	# store the min to set3
	sw $14,buf($12) # store the min into set3 one by one
	# address+=4	
	addi $12,$12,4
	# continues
	bne $12,$17,loop_for_set2_sort
	
	addi $25,$0,3
	sw $25,0xC70($28) # show t3 finish
	j begin

test4:
	# max-min (in the set 1)
	# min is the front
	# max is the rear
	add $7,$0,$0
	add $7,$7,$27  # in set 1
	lw $8,buf($7) # min from set1
	
	add $7,$7,$27  # in set 2
	addi $7,$7,-4 # the rear of set1

	lw $11,buf($7) # max from set1
	sub $25,$11,$8 # max - min
	sw $25,0xC70($28) # show

	# show on the VGA
	add $24,$25,$0
	addi $25,$0,889
	jal print_answer


	j begin

test5:
	# max-min (in the set 3)
	# min is the front
	# max is the rear
	add $7,$0,$0
	add $7,$7,$27  # +=space--> in set 1
	add $7,$7,$27  # +=space--> in set 2
	add $7,$7,$27  # +=space--> in set 3
	lw $8,buf($7) # min from set3
	
	add $7,$7,$27  # in temp
	addi $7,$7,-4 # the rear of set3

	lw $11,buf($7) # max from set1
	sub $25,$11,$8 # max - min
	sw $25,0xC70($28) # show

	# show on the VGA
	add $24,$25,$0
	addi $25,$0,889
	jal print_answer

	j begin

test6:
	# show data by set and index
	andi $8,$1,0x3F # the low 6 bits from input
	srl $8,$8,2  # the 2/3/4/5 bits from input-->which num
	andi $9,$1,0x3 # the low 2 bits from input-->which set
	add $11,$0,$0 # address
	add $12,$0,$0 # i

	beq $12,$8,test6_with_address # is 0
	addi $12,$12,1 # i++
	addi $11,$0,4 # address+=4
	beq $12,$8,test6_with_address # is 1
	addi $12,$12,1 # i++
	addi $11,$0,8 # address+=4
	beq $12,$8,test6_with_address # is 2
	addi $12,$12,1 # i++
	addi $11,$0,12 # address+=4
	beq $12,$8,test6_with_address # is 3
	addi $12,$12,1 # i++
	addi $11,$0,16 # address+=4
	beq $12,$8,test6_with_address # is 4
	addi $12,$12,1 # i++
	addi $11,$0,20 # address+=4
	beq $12,$8,test6_with_address # is 5
	addi $12,$12,1 # i++
	addi $11,$0,24 # address+=4
	beq $12,$8,test6_with_address # is 6
	addi $12,$12,1 # i++
	addi $11,$0,30 # address+=4
	beq $12,$8,test6_with_address # is 7
	addi $12,$12,1 # i++
	addi $11,$0,34 # address+=4
	beq $12,$8,test6_with_address # is 8
	addi $12,$12,1 # i++
	addi $11,$0,36 # address+=4
	beq $12,$8,test6_with_address # is 9
	addi $12,$12,1 # i++
	addi $11,$0,40 # address+=4
	beq $12,$8,test6_with_address # is 10
	
test6_with_address:
	# choose set
	add $10,$0,$0 # i ini
	beq $10,$9,test6_show_set0 # is set0
	addi $10,$10,1 # i++
	beq $10,$9,test6_show_set1 # is set1
	addi $10,$10,1 # i++
	beq $10,$9,test6_show_set2 # is set2
	addi $10,$10,1 # i++
	beq $10,$9,test6_show_set3 # is set3
	j begin

test6_show_set0:
	lw $25,buf($11)
	andi $25,$25,0xFF # show low 8 bits
	sw $25,0xC70($28) # show

	# show on the VGA
	add $24,$25,$0
	addi $25,$0,889
	jal print_answer

	j begin
test6_show_set1:
	add $11,$11,$27 # += space
	lw $25,buf($11)
	andi $25,$25,0xFF # show low 8 bits
	sw $25,0xC70($28) # show

	# show on the VGA
	add $24,$25,$0
	addi $25,$0,889
	jal print_answer

	j begin
test6_show_set2:
	add $11,$11,$27 # += space
	add $11,$11,$27 # += space
	lw $25,buf($11)
	andi $25,$25,0xFF # show low 8 bits
	sw $25,0xC70($28) # show

	# show on the VGA
	add $24,$25,$0
	addi $25,$0,889
	jal print_answer


	j begin
test6_show_set3:
	add $11,$11,$27 # += space
	add $11,$11,$27 # += space
	add $11,$11,$27 # += space
	lw $25,buf($11)
	andi $25,$25,0xFF # show low 8 bits
	sw $25,0xC70($28) # show

	# show on the VGA
	add $24,$25,$0
	addi $25,$0,889
	jal print_answer

	j begin
	
test7:
	
	andi $8,$1,0xF # the low 4 bits from input-->the index
	addi $9,$0,0 # i
	addi $10,$0,0 # address for target number

	beq $8,$9,test7_with_address # is 0
	addi $9,$9,1
	addi $10,$0,4
	beq $8,$9,test7_with_address # is 1
	addi $9,$9,1
	addi $10,$0,8
	beq $8,$9,test7_with_address # is 2
	addi $9,$9,1
	addi $10,$0,12
	beq $8,$9,test7_with_address # is 3
	addi $9,$9,1
	addi $10,$0,16
	beq $8,$9,test7_with_address # is 4
	addi $9,$9,1
	addi $10,$0,20
	beq $8,$9,test7_with_address # is 5
	addi $9,$9,1
	addi $10,$0,24
	beq $8,$9,test7_with_address # is 6
	addi $9,$9,1
	addi $10,$0,28
	beq $8,$9,test7_with_address # is 7
	addi $9,$9,1
	addi $10,$0,32
	beq $8,$9,test7_with_address # is 8
	addi $9,$9,1
	addi $10,$0,36
	beq $8,$9,test7_with_address # is 9
	addi $9,$9,1
	addi $10,$0,40
	beq $8,$9,test7_with_address # is 10

test7_with_address:

	lw $25,buf($10) # set0
	addi $14,$0,1
	sll $14,$14,8
	or $25,$14,$25 # show index
	sw $25,0xC70($28) # show

	# show on the VGA
	add $24,$25,$0
	addi $25,$0,889
	jal print_answer


	add $12,$0,$0 # counter for sleep
	# the time need to sleep
	lui $13,0xB6
	ori $13,$13,0xB0B0

loop_for_sleep1:
	addi $12,$12,1
	bne $12,$13,loop_for_sleep1

	add $10,$10,$27 # +=space
	add $10,$10,$27 # +=space
	lw $25,buf($10) # set2
	andi $25,$25,0xFF 
	addi $14,$0,1
	sll $14,$14,9
	or $25,$14,$25 # show index
	sw $25,0xC70($28) # show

	# show on the VGA
	add $24,$25,$0
	addi $25,$0,889
	jal print_answer


	add $12,$0,$0
	# the time need to sleep
loop_for_sleep2:
	addi $12,$12,1
	bne $12,$13,loop_for_sleep2

	j begin
	
# try to print a Hex number at most 32bits	
print_answer:
	addi $29,$0,3
print_answer_ini:
	# $25 position for the last char 
	# $24 are the char to print-->show this 4 bits by 4 bits 
	addi $29,$29,-1
	beq $29,$0,print_return # front zero ignore-->when value is zero->return

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
print_return:
	addi $25,$2,48
	sw $25,803($28)
	jr $ra


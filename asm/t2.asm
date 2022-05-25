.data 0x0000				      		
	buf: .space 200
	temp: .space 200
.text 0x0000						
start: 
	lui   $1,0xFFFF			
	ori  $28,$1,0xF000 # base
	ori  $27,$0,0xFF # and this to get low 8 bits
	addi $26,$26,1 # c==1
begin:
	add $3,$0,$0 # counter for tasks
	lw  $1,0xC70($28) # ini input
	srl  $2,$1,20 # 23~20 bits
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
	# $4 ready check
	sw $25,0xC70($28) # show
	beq $4,$5,begin
	add $5,$4,$0 # store ready
	# no size-->back
	bne $6,$0,next_input
	# read the size
	and  $6,$27,$1 # $6-->size
	add $25,$6,$0 # show size
	add $7,$7,$0 # ini index
	add $9,$9,$0 # ini index address
	j begin
next_input:
	# $7 index
	# $9 address for 7
	beq $7,$6,begin # size = index--> not change
	and  $8,$27,$1 # 8-->next_input
	sw $8,buf($9) # store next_input
	add $25,$8,$0 # show next_input
	addi $7,$7,1 
	addi $9,$9,4
	j begin
test1:
	add $9,$0,$0 # ini $9 
	addi $16,$16,0 # i*4
move_set0_to_temp:
	lw $10,buf($16)
	sw $10,temp($16)
	addi $9,$9,1
	addi $16,$16,4
	bne $9,$6,move_set0_to_temp
	
	addi $14,$0,0 # i
	addi $16,$16,0 # i*4
loop_for_set1_sort:	
	add $9,$9,$0 # j
	add $15,$15,$0 # j*4
	add $10,$10,$0 # max
	add $13,$13,$0 # index of max
get_set1_max:
	lw $11,buf($15)
	sltu $12,$10,$11 # $12->1->$11 > max
	beq $12,$0,set1_continue
	# bigger than max
	add $10,$11,$0 # renew max
	add $13,$15,$0 # renew index
set1_continue:
	addi $9,$9,1
	addi $15,$15,4
	bne $9,$8,loop_for_set1_sort

	# ��ն�Ӧ�ڴ�
	sw $0,temp($13)
	# ���浱ǰmax����Ӧ�ĵ�ַ
	sw $10,buf($16)
	# i++
	addi $14,$14,1 
	addi $16,$16,4
	# ��ת��һ��ѭ��
	bne $14,$6,loop_for_set1_sort

	j begin
test2:
	addi $25,$0,2
	sw $25,0xC70($28)
	j begin
test3:
	addi $25,$0,3
	sw $25,0xC70($28)
	j begin
test4:
	addi $25,$0,4
	sw $25,0xC70($28)
	j begin
test5:
	addi $25,$0,5
	sw $25,0xC70($28)
	j begin
test6:
	addi $25,$0,6
	sw $25,0xC70($28)
	j begin
test7:
	addi $25,$0,7
	sw $25,0xC70($28)
	j begin

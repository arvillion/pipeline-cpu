.data 0x0000				      		
	buf: .space 200
	temp: .space 200
.text 0x0000						
start: 
	lui   $1,0xFFFF			
        ori  $28,$1,0xF000 # base
	ori  $27,$2,0xFFFF # and this to get low 16 bits
	addi $26,$26,1 #c==1
begin:
	add $3,$3,$0 # 初始化为0-->跳转任务计数器
	lw  $1,0xC70($28) # 1号保存原始输入
	srl  $2,$1,20 # 取 23~20 bits->控制位
	and $4,$26,$2 # 4-->ready for next input
	srl  $2,$2,1 # 2-->op
	#jump to tasks
	beq $2,$3,t1 # t0
	addi $3,$3,1
	beq $2,$3,t1 # t1
	addi $3,$3,1
	beq $2,$3,t2 # t2
	addi $3,$3,1
	beq $2,$3,t3 # t3
	addi $3,$3,1
	beq $2,$3,t4 # t3
	addi $3,$3,1
	beq $2,$3,t5 # t5
	addi $3,$3,1
	beq $2,$3,t6 # t6
	addi $3,$3,1
	beq $2,$3,t7 # t7
t0:
	# $4改变后读取下一位
	beq $4,$5,begin
	add $5,$4,$0 # 保存当前ready
	# $6保存集合大小，如果为0就表示还没有输入集合大小
	bne $6,$0,next_input
	# 读入集合大小，保存在$6
	lw  $6,0xC70($28)
	sw $6,0xC70($28) # 显示
	j begin
next_input:
	# $7 当前已经保存集合元素个数
	# 读满了就返回
	beq $7,$8,begin
	lw  $8,0xC70($28)
	sw $8,buf($7)
	sw $6,0xC70($28) # 显示
	addi $7,$7,1
	j begin
t1:
	add $9,$9,$0 # 循环计数器
move_set1_to_temp:
	lw $10,buf($9)
	sw $10,temp($9)
	addi $9,$9,1
	bne $9,$6,move_set1_to_temp
	
	addi $14,$0,0 # i
loop_for_set1_sort:	
	add $9,$9,$0 # j
	add $10,$10,$0 # max
	add $13,$13,$0 # index of max
get_set1_max:
	lw $11,buf($9)
	sltu $12,$10,$11 # $12->1->$11比max大
	beq $12,$0,set1_continue
	add $10,$11,$0 # 更新max
	add $13,$9,$0 # 更新index
set1_continue:
	addi $9,$9,1
	bne $9,$8,loop_for_set1_sort

	# 清空对应内存
	sw $0,temp($13)
	# 保存当前max到对应的地址
	sw $10,buf($14)
	# i++
	addi $14,$14,1 
	# 跳转下一次循环
	bne $14,$6,loop_for_sort

	j begin
t2:
	j begin
t3:
	j begin
t4:
	j begin
t5:
	j begin
t6:
	j begin
t7:
	j begin

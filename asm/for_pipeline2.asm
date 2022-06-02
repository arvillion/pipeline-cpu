.data 0x0000				      		
	buf: .space 200
.text 0x0000						
start:
	lui   $1,0xFFFF			
	ori  $28,$1,0xF000 # base
	
	lw $1,0($0)
	addi $2,$1,1

	sw $2,0xC30($28)

	j start

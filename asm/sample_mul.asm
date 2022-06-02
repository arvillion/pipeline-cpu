.data 0x0000				      		
	buf: .space 200
.text 0x0000	
begin:

	lui   $1,0xFFFF			
	ori  $28,$1,0xFC80 # base

	lui $1,0xFFFF
	ori $1,$1,0xFFFF
	
	lui $2,0xFFFF
	ori $2,$1,0xFFFF

	multu $1,$2

	# high high
	mflo $3
	
	# srl $3,$3,16

	sw $3,0($28)
	j begin
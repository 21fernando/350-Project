init: 
	# addi $a0, $0, 50
	# jal set_stepper_speed
	# j init
	# jal turn_on_stepper
	# addi $a0, $0, 2000
	# jal set_target
main:

	wait_for_ball:
	addi $t0, $0, 1
	and $t1, $t0, $25 # T1 now stores the move goalie bit
	addi $t0, $0, 1
	bne $t1, $t0, wait_for_ball

	decode_phototransistors:
	addi $t0, $0, 14
	and $t1, $t0, $25
	sra $t1, $t1, 1 # $t1 now holds the 3 min address bits in its LSBs

	addi $t0, $0, 0
	bne $t1, $t0, not_pos_0
	addi $a0, $0, 0
	j pos_loaded
	not_pos_0:
	addi $t0, $0, 1
	bne $t1, $t0, not_pos_1
	addi $a0, $0, 1
	j pos_loaded
	not_pos_1:
	addi $t0, $0, 2
	bne $t1, $t0, not_pos_2
	addi $a0, $0, 2
	j pos_loaded
	not_pos_2:
	addi $t0, $0, 3
	bne $t1, $t0, not_pos_3
	addi $a0, $0, 3
	j pos_loaded
	not_pos_3:
	addi $t0, $0, 4
	bne $t1, $t0, not_pos_4
	addi $a0, $0, 4
	j pos_loaded
	not_pos_4:
	addi $t0, $0, 5
	bne $t1, $t0, not_pos_5
	addi $a0, $0, 5
	j pos_loaded
	not_pos_5:
	addi $t0, $0, 6
	bne $t1, $t0, not_pos_6
	addi $a0, $0, 6
	j pos_loaded
	not_pos_6:
	addi $a0, $0, 7

	pos_loaded:
	jal set_target
	# addi $t0, $0, 2048
	# sll $t0, $t0, 10
	# addi $t0, $t0, 1023
	# sll $t0, $t0, 10
	# addi $t0, $t0, 255 # $t0 = time between speed changes
	# addi $t0, $0, 10
	# addi $t1, $0, 0
	# loop:
	# addi $t1, $t1, 1
	# blt $t1, $t0, loop # stall 10000 clock cycles
	# addi $a0, $a0, 10 # increment the speed
	# addi $t2, $0, 100
	# blt $a0, $t2, no_need_speed_fix
	# addi $a0, $0, 1
	# no_need_speed_fix:
	# jal set_stepper_speed
	# addi $t1, $0, 1
	# loop: j loop
	j main
j main

set_stepper_speed:
	addi $s0, $0, 7368
	mul $s1, $s0, $a0
	addi $s0, $0, 244
	sll $s0, $s0, 12
	addi $s0, $s0, 576
	sub $s2, $s0, $s1 # s2 = 1000000- 7368 * $a0
	sw $s2, 4097($0) # Store speed to the register in memory
	jr $ra # Return to main 

turn_on_stepper: 
	addi $s0, $0, 3
	sll $s0, $s0, 22
	lw $s1, 4097($0)
	or $s1, $s1, $s0
	sw $s1 4097($0)
	jr $ra

turn_off_stepper: 
	addi $s0, $0, 1020
	sll $s0, $s0, 10
	addi $s0, $s0, 1024
	sll $s0, $s0, 10
	addi $s0, $s0, 4096
	sll $s0, $s0, 12 // Now S0 is all 1s and 0 at 23 and 22
	lw $s1, 4097($0)
	or $s1, $s1, $s0
	sw $s1 4097($0)
	jr $ra

set_target:
	add $24, $0, $a0
	jr $ra
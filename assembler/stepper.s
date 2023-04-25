init: 
	addi $t0, $0, 30000
	sll $t0, $t0, 11
	addi $t0, $0, 10
	add $t1, $0, $0
	initial_delay:
	addi $t1, $t1, 1
	bne $t0, $t1, initial_delay # wait a few second before starting
	ready:
	addi $a0, $0, 1
	jal set_target # set the target to be a large negative number
	jal set_stepper_state_00  # set the stepper to operate normally
	addi $t0, $0, 32 # switch data is on bit 5 so 2^5 = 32
	wait_for_button:
	and $t1, $25, $t0 #isolate the 5th bit
	bne $t1, $t0, wait_for_button
	# now button has been pressed
	jal set_stepper_state_11 # stepper is now resetting its position
	add $a0, $0, $0
	jal set_target # set target to 0 to make sure stepper doesnt move past limit
	addi $t0, $0, 5
	add $t1, $0, $0
	wait_for_stepper_reset: 
	addi $t1, $t1, 1
	bne $t0, $t1, wait_for_stepper_reset # Now the stepper has waited a few clock cycles to allow the 0 value to sette into its system
	jal set_stepper_state_00 # stepper is operating normally again
main:
	wait_for_ball:
	addi $t0, $0, 1
	and $t1, $t0, $25 # T1 now stores the move goalie bit
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
	addi $a0, $0, 20
	j pos_loaded
	not_pos_1:
	addi $t0, $0, 2
	bne $t1, $t0, not_pos_2
	addi $a0, $0, 40
	j pos_loaded
	not_pos_2:
	addi $t0, $0, 3
	bne $t1, $t0, not_pos_3
	addi $a0, $0, 60
	j pos_loaded
	not_pos_3:
	addi $t0, $0, 4
	bne $t1, $t0, not_pos_4
	addi $a0, $0, 80
	j pos_loaded
	not_pos_4:
	addi $t0, $0, 5
	bne $t1, $t0, not_pos_5
	addi $a0, $0, 100
	j pos_loaded
	not_pos_5:
	addi $t0, $0, 60
	bne $t1, $t0, not_pos_6
	addi $a0, $0, 120
	j pos_loaded
	not_pos_6:
	addi $a0, $0, 140

	pos_loaded:
	jal set_target
	
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

set_stepper_state_00:
	addi $s0, $0, 511
	sll $s0, $s0, 12
	addi $s0, $s0, 1023
	sll $s0, $s0, 11
	addi $s0, $s0, 2047 # $s0 contains the bitmask to change the state to 00 ==> 9 1's , 00, 21 1's
	and $24, $24, $s0 # register 25 now has the stepper state 00 meaning normal movement
	jr $ra

set_stepper_state_11:
	addi $s0, $0, 3
	sll $s0, $s0, 21 #$s0 contains the bitmask to change the state to 11 ==> all 0 except 22-23 == 11
	or $24, $s0, $24
	jr $ra
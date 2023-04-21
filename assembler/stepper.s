init: 
	# addi $a0, $0, 50
	# jal set_stepper_speed
	# j init
	# jal turn_on_stepper
main:
	addi $t0, $0, 2048
	sll $t0, $t0, 10
	addi $t0, $t0, 1023
	sll $t0, $t0, 10
	addi $t0, $t0, 255 # $t0 = time between speed changes
	# addi $t0, $0, 10
	addi $t1, $0, 0
	loop:
	addi $t1, $t1, 1
	blt $t1, $t0, loop # stall 10000 clock cycles
	addi $a0, $a0, 10 # increment the speed
	addi $t2, $0, 100
	blt $a0, $t2, no_need_speed_fix
	addi $a0, $0, 1
	no_need_speed_fix:
	jal set_stepper_speed
	addi $t1, $0, 1
	j loop
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

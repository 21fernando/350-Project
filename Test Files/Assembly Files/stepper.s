init: 
	addi $a0, $0, 50
	jal set_stepper_speed
	jal turn_on_stepper
main:
	#addi $t0, $0, 10000
	#addi $t1, $0, 0
	#loop:
	#addi $t1, $t1, 1
	#blt $t1, $t0, loop #stall 10000 clock cycles
	#addi $a0, $a0, 1 # increment the speed
	#addi $t0, $0, 100
	#blt $a0, $t0, no_need_speed_fix
	#addi $a0, $0, 1
	#no_need_speed_fix:
	#jal set_stepper_speed
j main

set_stepper_speed:
	addi $s0, $0, 14500 
	mul $s1, $s0, $a0
	addi $s0, $0, 2000000
	sub $s0, $s0, $s1 #s0 = 2000000 - 14500 * $a0
	sw $s0, 4095($0) #Store speed to the register in memory
	jr $ra #Return to main 

turn_on_stepper: 
	addi $s0, $0, 12582912
	lw $s1, 4095($0)
	or $s1, $s1, $s0
	sw $s1 4095($0)
	jr $ra

turn_off_stepper: 
	addi $s0, $0, 4194303 
	lw $s1, 4095($0)
	or $s1, $s1, $s0
	sw $s1 4095($0)
	jr $ra
nop 	# simple blt test case
nop 
nop 
nop
nop
nop
addi    $r1, $r0, 4     # $r1 = 4
addi    $r2, $r0, 5     # $r2 = 5
nop
nop
nop 	
blt 	$r1, $r2, b3	# r1 < r2 --> taken
nop			# flushed instruction
nop			# flushed instruction
addi 	$r20, $r20, 1	# r20 += 1 (Incorrect)
addi 	$r20, $r20, 1	# r20 += 1 (Incorrect)
addi 	$r20, $r20, 1	# r20 += 1 (Incorrect)
b3: 
addi $r10, $r10, 1	# r10 += 1 (Correct)
blt $r2, $r1, b4	# r2 == r2 --> not taken
nop			# nop in case of flush
nop			# nop in case of flush
nop			# Spacer 
addi $r10, $r10, 1	# r10 += 1 (Correct) 
b4: 			# Landing pad for branch
nop
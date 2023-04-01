# Open input file and output file
with open('/Users/tharindu2003/Documents/ECE350/processor/Test Files/Assembly Files/sort_in.txt', 'r') as input_file, open('/Users/tharindu2003/Documents/ECE350/processor/Test Files/Assembly Files/sort_out.txt', 'w') as output_file:
    # Read lines from input file and write to output file with "nop" inserted between each line
    for line in input_file:
        output_file.write(line.strip()  + "\n")

# Rename output file to "sort.s"
import os
os.rename('/Users/tharindu2003/Documents/ECE350/processor/Test Files/Assembly Files/sort_out.txt', '/Users/tharindu2003/Documents/ECE350/processor/Test Files/Assembly Files/sort.s')

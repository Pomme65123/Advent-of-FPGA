def find_largest_steps(filename="input.txt"):
    max_steps = 0
    max_instructions = []
    line_numbers = []
    
    with open(filename, 'r') as f:
        for line_num, line in enumerate(f, 1):
            line = line.strip()
            if not line:
                continue
            
            direction = line[0]
            steps = int(line[1:])
            
            if steps > max_steps:
                max_steps = steps
                max_instructions = [line]
                line_numbers = [line_num]
            elif steps == max_steps:
                max_instructions.append(line)
                line_numbers.append(line_num)
    
    return max_steps, max_instructions, line_numbers

if __name__ == "__main__":
    max_steps, instructions, line_nums = find_largest_steps()
    
    for line_num, instr in zip(line_nums, instructions):
        print(f"  Line {line_num}: {instr}")

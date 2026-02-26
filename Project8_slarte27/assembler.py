# Template by Bruce A. Maxwell, 2015
#
# implements a simple assembler for the following assembly language
# 
# - One instruction or label per line.
#
# - Blank lines are ignored.
#
# - Comments start with a # as the first character and all subsequent
# - characters on the line are ignored.
#
# - Spaces delimit instruction elements.
#
# - A label ends with a colon and must be a single symbol on its own line.
#
# - A label can be any single continuous sequence of printable
# - characters; a colon or space terminates the symbol.
#
# - All immediate and address values are given in decimal.
#
# - Address values must be positive
#
# - Negative immediate values must have a preceeding '-' with no space
# - between it and the number.
#

# Language definition:
#
# LOAD D A   - load from address A to destination D
# LOADA D A  - load using the address register from address A + RE to destination D
# STORE S A  - store value in S to address A
# STOREA S A - store using the address register the value in S to address A + RE
# BRA L      - branch to label A
# BRAZ L     - branch to label A if the CR zero flag is set
# BRAN L     - branch to label L if the CR negative flag is set
# BRAO L     - branch to label L if the CR overflow flag is set
# BRAC L     - branch to label L if the CR carry flag is set
# CALL L     - call the routine at label L
# RETURN     - return from a routine
# HALT       - execute the halt/exit instruction
# PUSH S     - push source value S to the stack
# POP D      - pop form the stack and put in destination D
# OPORT S    - output to the global port from source S
# IPORT D    - input from the global port to destination D
# ADD A B C  - execute C <= A + B
# SUB A B C  - execute C <= A - B
# AND A B C  - execute C <= A and B  bitwise
# OR  A B C  - execute C <= A or B   bitwise
# XOR A B C  - execute C <= A xor B  bitwise
# SHIFTL A C - execute C <= A shift left by 1
# SHIFTR A C - execute C <= A shift right by 1
# ROTL A C   - execute C <= A rotate left by 1
# ROTR A C   - execute C <= A rotate right by 1
# MOVE A C   - execute C <= A where A is a source register
# MOVEI V C  - execute C <= value V
#

# 2-pass assembler
# pass 1: read through the instructions and put numbers on each instruction location
#         calculate the label values
#
# pass 2: read through the instructions and build the machine instructions
#

import sys

# converts d to an 8-bit 2-s complement binary value
def dec2comp8( d, linenum ):
    try:
        if d > 0:
            l = d.bit_length()
            v = "00000000"
            v = v[0:8-l] + format( d, 'b')
        elif d < 0:
            dt = 128 + d
            l = dt.bit_length()
            v = "10000000"
            v = v[0:8-l] + format( dt, 'b')[:]
        else:
            v = "00000000"
    except:
        print( 'Invalid decimal number on line %d' % (linenum) )
        exit()

    return v

# converts d to an 8-bit unsigned binary value
def dec2bin8( d, linenum ):
    if d > 0:
        l = d.bit_length()
        v = "00000000"
        v = v[0:8-l] + format( d, 'b' )
    elif d == 0:
        v = "00000000"
    else:
        print( 'Invalid address on line %d: value is negative' % (linenum))
        exit()

    return v


# Tokenizes the input data, discarding white space and comments
# returns the tokens as a list of lists, one list for each line.
#
# The tokenizer also converts each character to lower case.
def tokenize( fp ):
    tokens = []

    # start of the file
    fp.seek(0)

    lines = fp.readlines()

    # strip white space and comments from each line
    for line in lines:
        ls = line.strip()
        uls = ''
        for c in ls:
            if c != '#':
                uls = uls + c
            else:
                break

        # skip blank lines
        if len(uls) == 0:
            continue

        # split on white space
        words = uls.split()

        newwords = []
        for word in words:
            newwords.append( word.lower() )

        tokens.append( newwords )

    return tokens


# reads through the file and returns a dictionary of all location
# labels with their line numbers
def pass1(tokens):
    labels = {}
    new_tokens = []
    address = 0

    for line in tokens:
        # if it's a label
        if len(line) == 1 and line[0].endswith(':'):
            label = line[0][:-1]

            # check duplicate labels
            if label in labels:
                print(f"Error: duplicate label '{label}'")
                exit()

            labels[label] = address
        else:
            # it's an instruction
            new_tokens.append(line)
            address += 1

    return labels, new_tokens


reg = {
    'ra': '000',
    'rb': '001',
    'rc': '010',
    'rd': '011',
    're': '100',
    'sp': '101',
    'pc': '110',
    'cr': '111',
    'zeros': '110',  
    'ones': '111'    
}
def pass2(tokens, labels):
    output = []

    for i, line in enumerate(tokens):
        instr = line[0]

        # MOVEI V C
        if instr == 'movei':
            value = int(line[1])
            dest = reg[line[2]]

            imm = dec2comp8(value, i)

            binary = '1111' + '1' + imm + dest
            output.append(binary)

        elif instr == 'move':
            src = reg[line[1]]
            dest = reg[line[2]]

            binary = '1111' + '0' + src + '00000' + dest
            output.append(binary)

        # ADD A B C
        elif instr == 'add':
            a = reg[line[1]]
            b = reg[line[2]]
            c = reg[line[3]]

            binary = '1000' + a + b + '000' + c
            output.append(binary)

        # SUB A B C
        elif instr == 'sub':
            a = reg[line[1]]
            b = reg[line[2]]
            c = reg[line[3]]

            binary = '1001' + a + b + '000' + c
            output.append(binary)

        # BRA L
        elif instr == 'bra':
            addr = labels[line[1]]
            addr_bin = dec2bin8(addr, i)

            binary = '0010' + '0000' + addr_bin
            output.append(binary)

        # BRAZ L
        elif instr == 'braz':
            addr = labels[line[1]]
            addr_bin = dec2bin8(addr, i)

            binary = '0011' + '0000' + addr_bin
            output.append(binary)
        
        # CALL L
        elif instr == 'call':
            addr = labels[line[1]]
            addr_bin = dec2bin8(addr, i)

            # 0011 + 01 + unused + address
            binary = '00110100' + addr_bin
            output.append(binary)

        # RETURN
        elif instr == 'return':
            # 0011 + 10 + rest zeros
            binary = '0011100000000000'
            output.append(binary)

        # PUSH S
        elif instr == 'push':
            src = reg[line[1]]

            # opcode 0100
            binary = '0100' + src + '000000000'
            output.append(binary)

        # POP D
        elif instr == 'pop':
            dest = reg[line[1]]

            binary = '0101' + dest + '000000000'
            output.append(binary)


        elif instr == 'halt':
            binary = '0011110000000000'
            output.append(binary)

        else:
            print(f"Unsupported instruction: {instr}")
            exit()

    return output

def main( argv ):
    if len(argv) < 2:
        print( 'Usage: python %s <filename>' % (argv[0]))
        exit()

    fp = open( argv[1], 'r' )

    tokens = tokenize(fp)

    labels, tokens = pass1(tokens)

    machine = pass2(tokens, labels)

    print("-- program memory file for %s" % argv[1])
    print("DEPTH = 256;")
    print("WIDTH = 16;")
    print("ADDRESS_RADIX = HEX;")
    print("DATA_RADIX = BIN;")
    print("CONTENT")
    print("BEGIN")

    for i, instr in enumerate(machine):
        print("%02X : %s;" % (i, instr))

    print("[%02X..FF] : 1111111111111111;" % (len(machine)))

    print("END")

    fp.close()

    # execute pass1 and pass2 then print it out as an MIF file

    return


if __name__ == "__main__":
    main(sys.argv)

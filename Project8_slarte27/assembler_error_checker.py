import sys
from assembler import tokenize, pass1

# valid instructions and expected number of operands
INSTRUCTION_FORMAT = {
    "movei": 2,
    "move": 2,
    "add": 3,
    "sub": 3,
    "bra": 1,
    "braz": 1,
    "call": 1,
    "return": 0,
    "halt": 0,
    "push": 1,
    "pop": 1,
    "oport": 1
}

VALID_REGS = {"ra", "rb", "rc", "rd", "re", "sp", "pc", "cr", "zeros", "ones"}


def check_line(tokens, labels, line_num):
    instr = tokens[0]

    # check label format
    if instr.endswith(":"):
        label = instr[:-1]
        if not label.isalnum():
            raise Exception(f"Line {line_num}: Invalid label '{label}'")
        if len(tokens) > 1:
            raise Exception(f"Line {line_num}: Extra text after label")
        return

    # check instruction exists
    if instr not in INSTRUCTION_FORMAT:
        raise Exception(f"Line {line_num}: Unknown instruction '{instr}'")

    expected_args = INSTRUCTION_FORMAT[instr]
    actual_args = len(tokens) - 1

    # check number of arguments
    if actual_args != expected_args:
        raise Exception(
            f"Line {line_num}: '{instr}' expects {expected_args} arguments, got {actual_args}"
        )

    # check registers
    if instr in ["move", "add", "sub", "push", "pop", "oport"]:
        for t in tokens[1:]:
            if instr == "movei":
                continue
            if t not in VALID_REGS:
                raise Exception(f"Line {line_num}: Invalid register '{t}'")

    # check immediate values
    if instr == "movei":
        try:
            val = int(tokens[1])
        except:
            raise Exception(f"Line {line_num}: Invalid number '{tokens[1]}'")

        if val < -128 or val > 127:
            raise Exception(
                f"Line {line_num}: Immediate value {val} out of 8-bit range (-128 to 127)"
            )

        if tokens[2] not in VALID_REGS:
            raise Exception(f"Line {line_num}: Invalid register '{tokens[2]}'")

    # check labels exist for branches/call
    if instr in ["bra", "braz", "call"]:
        if tokens[1] not in labels:
            raise Exception(f"Line {line_num}: Undefined label '{tokens[1]}'")


def main(argv):
    if len(argv) < 2:
        print("Usage: python3 assembler_ext3.py <file>")
        return

    with open(argv[1], "r") as f:
        tokens = tokenize(f)

    labels, tokens = pass1(tokens)

    for i, line in enumerate(tokens):
        check_line(line, labels, i + 1)

    print("No syntax errors detected.")


if __name__ == "__main__":
    main(sys.argv)

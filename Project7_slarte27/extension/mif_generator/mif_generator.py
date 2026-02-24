import sys


def generate_mif(input_file, num_instructions, depth, width):
    """Generate a .mif file from a simple instruction text file."""

    header = f"""DEPTH = {depth};
WIDTH = {width};
ADDRESS_RADIX = HEX;
DATA_RADIX = BIN;
CONTENT
BEGIN
"""

    lines = []

    with open(input_file, "r") as f:
        for i, line in enumerate(f):
            line = line.strip()
            if not line:
                continue

            try:
                instruction, comment = line.split(",", 1)
            except ValueError:
                raise ValueError(f"Invalid format on line {i}: {line}")

            instruction = instruction.strip()
            comment = comment.strip()

            if len(instruction) != width:
                raise ValueError(f"Instruction length must be {width} bits (line {i})")

            lines.append(f"{i:02X} : {instruction}; -- {comment}")

    # Fill remaining memory with 1s
    if num_instructions < depth:
        filler = "1" * width
        lines.append(f"[{num_instructions:02X}..{depth - 1:02X}] : {filler};")

    footer = "END\n"

    result = header + "\n".join(lines) + "\n" + footer

    output_file = input_file.replace(".txt", ".mif")
    with open(output_file, "w") as f:
        f.write(result)

    return result


if __name__ == "__main__":
    if len(sys.argv) != 5:
        print("Usage: python3 mif_generator.py <input_file> <num_instructions> <depth> <width>")
        sys.exit(1)

    input_file = sys.argv[1]
    num_instructions = int(sys.argv[2])
    depth = int(sys.argv[3])
    width = int(sys.argv[4])

    print(generate_mif(input_file, num_instructions, depth, width))

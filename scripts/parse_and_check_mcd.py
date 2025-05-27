#!/usr/bin/env python3

import re
import math
import sys

def parse_and_check(file_path):
    with open(file_path, 'r') as f:
        content = f.read()

    # Accept binary strings of 16, 32, or 64 bits
    bit_pattern = r"[01]{16}|[01]{32}|[01]{64}"

    # Regex to match each result block
    pattern = re.compile(
        rf"Interesting result at (\d+) cycles:\s+"
        rf"A\s+=\s+({bit_pattern})\s+"
        rf"B\s+=\s+({bit_pattern})\s+"
        rf"mcd\s+=\s+({bit_pattern})", re.MULTILINE)

    all_passed = True

    for match in pattern.finditer(content):
        cycle, a_bin, b_bin, mcd_bin = match.groups()
        a = int(a_bin, 2)
        b = int(b_bin, 2)
        expected_mcd = int(mcd_bin, 2)
        computed_mcd = math.gcd(a, b)

        if computed_mcd != expected_mcd:
            print(f"[FAIL] At {cycle} cycles: gcd({a}; {b}) = {computed_mcd}, expected {expected_mcd}")
            all_passed = False
        else:
            print(f"[ OK ] At {cycle} cycles: MCD correct ({computed_mcd})")

    if all_passed:
        print("All results are correct.")
    else:
        print("Some results failed.")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <input_file>")
        sys.exit(1)
    parse_and_check(sys.argv[1])

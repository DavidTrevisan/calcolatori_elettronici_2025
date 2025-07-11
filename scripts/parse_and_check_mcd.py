#!/usr/bin/env python3

import re
import math
import sys

def bin_to_unsigned_int(bin_str):
    width = len(bin_str)
    val = int(bin_str, 2)
    # To convert in 'bin_to_signed_int'
    # if bin_str[0] == '1':  # negative in two's complement
    #     val -= 1 << width
    return val

def parse_and_check(file_path):
    with open(file_path, 'r') as f:
        content = f.read()

    # Match binary strings of 16, 32, or 64 bits
    # Start from 64 bit downward to account for zero padded values
    bit_pattern = r"[01]{64}|[01]{32}|[01]{16}"
    pattern = re.compile(
        rf"Interesting result at (\d+) cycles:\s+"
        rf"A\s+=\s+({bit_pattern})\s+"
        rf"B\s+=\s+({bit_pattern})\s+"
        rf"mcd\s+=\s+({bit_pattern})", re.MULTILINE)

    all_passed = True

    for match in pattern.finditer(content):
        cycle, a_bin, b_bin, mcd_bin = match.groups()
        a = bin_to_unsigned_int(a_bin)
        b = bin_to_unsigned_int(b_bin)
        expected_mcd = bin_to_unsigned_int(mcd_bin)
        # Use gcd included in math
        # assuming is our ultimate golden reference
        computed_mcd = math.gcd(a, b)

        if computed_mcd != expected_mcd:
            print(f"[FAIL] At {cycle} cycles: gcd({a}; {b}) = {computed_mcd}, reported {expected_mcd}")
            all_passed = False
        else:
            print(f"[ OK ] At {cycle} cycles: MCD correct ({computed_mcd})")

    if all_passed:
        print(">>> All results are correct.")
    else:
        print(">>> Some results have failed.")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <input_file>")
        sys.exit(1)
    parse_and_check(sys.argv[1])

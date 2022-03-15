#! /usr/bin/env python3

from sys import argv

if len(argv) == 1:
    print("Usage: ./extract_code.py <file>")
    exit(0)

dump_lines = []
code_lines = []

with open(argv[1], 'r') as dump:
    dump_lines = dump.readlines()

for line in dump_lines:
    print(line[11:32])


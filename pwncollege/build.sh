#! /bin/bash

echo "Assembling into ELF binary..."

name="${1::-2}"
elf_output="$name-elf"
shellcode_output="$name-shellcode"
gcc -nostdlib -static $1 -o $elf_output
echo "Assembled"

echo "Extracting shellcode..."
objcopy --dump-section .text=$shellcode_output $elf_output
echo "Shellcode extracted to file $shellcode_output"
echo "Done"

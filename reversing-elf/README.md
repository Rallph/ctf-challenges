# Reversing ELF
*A TryHackMe CTF challenge. Room for beginner reverse engineering CTF players*

[TryHackMe Link](https://tryhackme.com/room/reverselfiles)

### Crackme1
Just need to download and run the binary. Doesn't have execute permissions when downloaded, so just need to run `chmod +x crackme1` to make it executable. Once we run it we get the flag `flag{not_that_kind_of_elf}`.

### Crackme2
When run with no arguments:
```sh
$ ./crackme2 
Usage: ./crackme2 password
```

When providing a random password:
```sh
$ ./crackme2 stuff                                                                                                                              
Access denied.
```

Might be comparing providing argument with hardcoded string, so run `strings` on binary. Output:
```sh
/lib/ld-linux.so.2
libc.so.6
_IO_stdin_used
puts
printf
memset
strcmp
__libc_start_main
/usr/local/lib:$ORIGIN
__gmon_start__
GLIBC_2.0
PTRh 
j3jA
[^_]
UWVS
t$,U
[^_]
Usage: %s password
super_secret_password
Access denied.
Access granted.
;*2$"(
GCC: (Ubuntu 5.4.0-6ubuntu1~16.04.9) 5.4.0 20160609
crtstuff.c
__JCR_LIST__
deregister_tm_clones
__do_global_dtors_aux
completed.7209
__do_global_dtors_aux_fini_array_entry
frame_dummy
__frame_dummy_init_array_entry
conditional1.c
giveFlag
__FRAME_END__
__JCR_END__
__init_array_end
_DYNAMIC
__init_array_start
__GNU_EH_FRAME_HDR
_GLOBAL_OFFSET_TABLE_
__libc_csu_fini
strcmp@@GLIBC_2.0
_ITM_deregisterTMCloneTable
__x86.get_pc_thunk.bx
printf@@GLIBC_2.0
_edata
__data_start
puts@@GLIBC_2.0
__gmon_start__
__dso_handle
_IO_stdin_used
__libc_start_main@@GLIBC_2.0
__libc_csu_init
memset@@GLIBC_2.0
_fp_hw
__bss_start
main
_Jv_RegisterClasses
__TMC_END__
_ITM_registerTMCloneTable
.symtab
.strtab
.shstrtab
.interp
.note.ABI-tag
.note.gnu.build-id
.gnu.hash
.dynsym
.dynstr
.gnu.version
.gnu.version_r
.rel.dyn
.rel.plt
.init
.plt.got
.text
.fini
.rodata
.eh_frame_hdr
.eh_frame
.init_array
.fini_array
.jcr
.dynamic
.got.plt
.data
.bss
.comment
```

We see `strcmp` among the output, which is a good sign since that's the name of C's string comparison function. Later on we see these lines:
```sh
Usage: %s password
super_secret_password
Access denied.
Access granted.
```

Looks like `super_secret_password` might be it, let's try running it.
```sh
$ ./crackme2 super_secret_password
Access granted.
flag{if_i_submit_this_flag_then_i_will_get_points}
```

The adjacency of the strings in the output is also important to note here. You can imagine the source code of the program is something like:
```c
if (argc != 2) {
	printf("Usage: %s password", argv[0]); // argv[0] is always the name of the program
	return 1;
}

if (strcmp("super_secret_password", argv[1]) != 0) {
	printf("Access denied.");
	return 1;
} else {
	printf("Access granted.");
	// print flag
	return 0;
}
```

So it makes sense that those strings would be placed near each other by the compiler.

### Crackme3
This one says "use basic reverse engineering skills to obtain the flag". Will probably have to disassemble this binary.

With no arguments:
```sh
$ ./crackme3                      
Usage: ./crackme3 PASSWORD
```

With a random, wrong password:
```sh
$ ./crackme3 pass                                                                                                                             
Come on, even my aunt Mildred got this one!
```

Decided to run `strings` on the binary, like we did last time, and got this output:
```sh
# some other stuff

Usage: %s PASSWORD
malloc failed
ZjByX3kwdXJfNWVjMG5kX2xlNTVvbl91bmJhc2U2NF80bGxfN2gzXzdoMW5nNQ==
Correct password!
Come on, even my aunt Mildred got this one!
ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/

# some other stuff
```

The string `ZjByX3kwdXJfNWVjMG5kX2xlNTVvbl91bmJhc2U2NF80bGxfN2gzXzdoMW5nNQ==` caught my eye. If the jumble of letters and numbers wasn't enough, the telltale `==` at the end is a sign that this is base64 encoded data. Let's decode it and see what we get:
```sh
$ echo ZjByX3kwdXJfNWVjMG5kX2xlNTVvbl91bmJhc2U2NF80bGxfN2gzXzdoMW5nNQ== | base64 -d -
f0r_y0ur_5ec0nd_le55on_unbase64_4ll_7h3_7h1ng5                                                                                                        
```

Looks like this might be the password?
```sh
$ ./crackme3 f0r_y0ur_5ec0nd_le55on_unbase64_4ll_7h3_7h1ng5
Correct password!
```

Nice! While this doesn't follow the `flag{}` format for some reason, `f0r_y0ur_5ec0nd_le55on_unbase64_4ll_7h3_7h1ng5` is in fact the correct flag for this part.

### Crackme4
When we run this one without any arguments, we get the following message:
```sh
$ ./crackme4       
Usage : ./crackme4 password
This time the string is hidden and we used strcmp
```

If you know a bit about C programming, you know that the `strcmp` function is part of the C standard library. On Linux, binaries that use C standard library functions *dynamically link* the shared object file that contains the instructions for those functions. With `ldd`, we can see that the binary does in fact link with `libc.so.6` to get the C standard library functions.
```sh
$ ldd ./crackme4        
	linux-vdso.so.1 (0x00007ffe4a7d3000)
	libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f85344cc000)
	/lib64/ld-linux-x86-64.so.2 (0x00007f85346a9000)
```

There's another CLI utility called `ltrace`, which we can use to see the calls a program makes to dynamically linked functions, including arguments and return values. Let's try running the program with ltrace, providing a password of "pass".
```sh
$ ltrace ./crackme4 pass
__libc_start_main(0x400716, 2, 0x7fffb868ee88, 0x400760 <unfinished ...>
strcmp("my_m0r3_secur3_pwd", "pass")                                     = -3
printf("password "%s" not OK\n", "pass"password "pass" not OK
)                                                    = 23
+++ exited (status 0) +++
```

And just like that, we can easily see the password that the developer tried so hard to hide from us. Let's just make sure it works:
```sh
$ ./crackme4 my_m0r3_secur3_pwd
password OK
```

Nice.

### Crackme5
The prompt for this one asks us "What will be the input of the file to get output `Good game`?"

With this program, it looks like the wrong input tells us "Always dig deeper":
```sh
$ ./crackme5                   
Enter your input:
stuff
Always dig deeper

$ ./crackme5
Enter your input:
lol
Always dig deeper
```


Let's try our ltrace trick from earlier (had to clean up the output a bit this time, since it was getting mixed with the prompted input):
```sh
$ ltrace ./crackme5     
__libc_start_main(0x400773, 1, 0x7ffe884b2928, 0x4008d0 <unfinished ...>
puts("Enter your input:"Enter your input:
)                                                                   = 18
# this is the part where you enter the password, I entered "lol"
__isoc99_scanf(0x400966, 0x7ffe884b27e0, 0, 0x7f4652e42d53
)                                 = 1
strlen("lol")                                                                               = 3
strlen("lol")                                                                               = 3
strlen("lol")                                                                               = 3
strlen("lol")                                                                               = 3
strncmp("lol", "OfdlDSA|3tXb32~X3tX@sX`4tXtz", 28)                                          = 29
puts("Always dig deeper"
)                                                                   = 18
+++ exited (status 0) +++
                                                                                                                                                      
```

Hmm, the length of the input string is checked 4 times, so the program could possibly be looping over each of the characters. After that, our input string is compared to a strange looking string. This time it's not base64, because base64 only contains alphanumeric characters, and this string has symbols like `|`,`~`, and `@`. Maybe it's dynamically generated based on our input? Let's try a different input and see if it changes.
```sh
└─$ ltrace ./crackme5            
__libc_start_main(0x400773, 1, 0x7ffda014f258, 0x4008d0 <unfinished ...>
puts("Enter your input:"Enter your input:
)                                                                   = 18
# I entered "stuff as the input"
__isoc99_scanf(0x400966, 0x7ffda014f110, 0, 0x7f066ff41d53
)                                 = 1
strlen("stuff")                                                                             = 5
strlen("stuff")                                                                             = 5
strlen("stuff")                                                                             = 5
strlen("stuff")                                                                             = 5
strlen("stuff")                                                                             = 5
strlen("stuff")                                                                             = 5
strncmp("stuff", "OfdlDSA|3tXb32~X3tX@sX`4tXtz", 28)                                        = 36
puts("Always dig deeper"
)                                                                   = 18
+++ exited (status 0) +++
```

There's more calls to `strlen` here than before, since "stuff" has a longer length than "lol", but that weird string that gets compared at the end is still the same. Let's try putting that string as the input and see what happens.
```sh
└─$ ltrace ./crackme5
__libc_start_main(0x400773, 1, 0x7ffe61182508, 0x4008d0 <unfinished ...>
puts("Enter your input:"Enter your input:
)                                                                   = 18
__isoc99_scanf(0x400966, 0x7ffe611823c0, 0, # provided "0x7ffa50d2ad53OfdlDSA|3tXb32~X3tX@sX`4tXtz" as the input
)                                 = 1
strlen("OfdlDSA|3tXb32~X3tX@sX`4tXtz")                                                      = 28
strlen("OfdlDSA|3tXb32~X3tX@sX`4tXtz")                                                      = 28
strlen("OfdlDSA|3tXb32~X3tX@sX`4tXtz")                                                      = 28
strlen("OfdlDSA|3tXb32~X3tX@sX`4tXtz")                                                      = 28
strlen("OfdlDSA|3tXb32~X3tX@sX`4tXtz")                                                      = 28
strlen("OfdlDSA|3tXb32~X3tX@sX`4tXtz")                                                      = 28
strlen("OfdlDSA|3tXb32~X3tX@sX`4tXtz")                                                      = 28
strlen("OfdlDSA|3tXb32~X3tX@sX`4tXtz")                                                      = 28
strlen("OfdlDSA|3tXb32~X3tX@sX`4tXtz")                                                      = 28
strlen("OfdlDSA|3tXb32~X3tX@sX`4tXtz")                                                      = 28
strlen("OfdlDSA|3tXb32~X3tX@sX`4tXtz")                                                      = 28
strlen("OfdlDSA|3tXb32~X3tX@sX`4tXtz")                                                      = 28
strlen("OfdlDSA|3tXb32~X3tX@sX`4tXtz")                                                      = 28
strlen("OfdlDSA|3tXb32~X3tX@sX`4tXtz")                                                      = 28
strlen("OfdlDSA|3tXb32~X3tX@sX`4tXtz")                                                      = 28
strlen("OfdlDSA|3tXb32~X3tX@sX`4tXtz")                                                      = 28
strlen("OfdlDSA|3tXb32~X3tX@sX`4tXtz")                                                      = 28
strlen("OfdlDSA|3tXb32~X3tX@sX`4tXtz")                                                      = 28
strlen("OfdlDSA|3tXb32~X3tX@sX`4tXtz")                                                      = 28
strlen("OfdlDSA|3tXb32~X3tX@sX`4tXtz")                                                      = 28
strlen("OfdlDSA|3tXb32~X3tX@sX`4tXtz")                                                      = 28
strlen("OfdlDSA|3tXb32~X3tX@sX`4tXtz")                                                      = 28
strlen("OfdlDSA|3tXb32~X3tX@sX`4tXtz")                                                      = 28
strlen("OfdlDSA|3tXb32~X3tX@sX`4tXtz")                                                      = 28
strlen("OfdlDSA|3tXb32~X3tX@sX`4tXtz")                                                      = 28
strlen("OfdlDSA|3tXb32~X3tX@sX`4tXtz")                                                      = 28
strlen("OfdlDSA|3tXb32~X3tX@sX`4tXtz")                                                      = 28
strlen("OfdlDSA|3tXb32~X3tX@sX`4tXtz")                                                      = 28
strlen("OfdlDSA|3tXb32~X3tX@sX`4tXtz")                                                      = 28
strncmp("OfdlDSA|3tXb32~X3tX@sX`4tXtz", "OfdlDSA|3tXb32~X3tX@sX`4tXtz", 28)                 = 0
puts("Good game"
)                                                                           = 10
+++ exited (status 0) +++
```

Looks like that worked! We got the output "Good game", just like we wanted. 

As for why there's so many calls to `strlen`, I suspect that the `scanf` function internally loops over the input string and makes a call to `strlen`, for each character of the string. While I wasn't able to find a definitive answer in the <5 minutes I spent searching for it, I did find some results that support this idea. 

Fun fact: the repeated calls to `strlen` that were part of `sscanf` were famously one of the causes of [the insanely long loading times for GTA Online](https://nee.lv/2021/02/28/How-I-cut-GTA-Online-loading-times-by-70/).


### Crackme6
The description for this one says "Analyze the binary for the easy password". When we try running it without any arguments we get:
```sh
└─$ ./crackme6 
Usage : ./crackme6 password
Good luck, read the source
```

Read the source? I think I know where this is going. Let's run `file` on this program to get a bit more information.
```sh
$ file crackme6 
crackme6: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, for GNU/Linux 2.6.24, BuildID[sha1]=022f1a8e479cab9f7263af75bcdbb328bda7f291, not stripped
```

Aha, the program file is **not stripped**, meaning it still has debug symbols (variable names, function names, etc.) still included in it that we can use. [This StackOverflow question discusses it a bit more](https://unix.stackexchange.com/questions/2969/what-are-stripped-and-not-stripped-executables-in-unix). 

Let's throw the program into Ghidra, the reverse engineering tool developed by the NSA. Ghidra is able to detect that it's a 64-bit ELF binary, and after analyzing the binary with its default set of analyzers, we can see the disassembled instructions of the program, as well as Ghidra's best-guess decompiled source code. Normally the decompiled source is much more unwieldy and difficult to decipher, but since this binary came with debug symbols, Ghidra was able to use them to make the decompilation much more readable.

With debug symbols, function names are preserved. Let's navigate to the main function and check it out:
```c
int main(int param_1,undefined8 *param_2)

{
  if (param_1 == 2) {
    compare_pwd(param_2[1]);
  }
  else {
    printf("Usage : %s password\nGood luck, read the source\n",*param_2);
  }
  return 0;
}
```

Looks like there's a check on the value of `param_1`, and it will execute the `compare_pwd` function or just print the usage, depending on its value. While Ghidra is great, it's not perfect, and this is one such example. Anyone who's written some C knows that the main function has a few standard function prototypes, with the most typical one being 
```c
int main(int argc, char* argv[]);
```
where `argc` is the number of command-line arguments passed to the program, and `argv` is the array containing those arguments as strings. Since we can reasonably assume that's what `param_1` and `param_2` are supposed to be, let's fix up those names in the decompilation.

```c
int main(int argc,char **argv)

{
  if (argc == 2) {
    compare_pwd(argv[1]);
  }
  else {
    printf("Usage : %s password\nGood luck, read the source\n",*argv);
  }
  return 0;
}
```

So this program simply checks if there's two arguments (really one argument passed by the user, the first argument is always the name of the program). If there is, pass the user-provided argument (the password) to `compare_pwd`. Let's look at that next.
```c
void compare_pwd(char *param_1)

{
  int iVar1;
  
  iVar1 = my_secure_test(param_1);
  if (iVar1 == 0) {
    puts("password OK");
  }
  else {
    printf("password \"%s\" not OK\n",param_1);
  }
  return;
}
```

Looks like we have another layer of indirection here. The password is passed to `my_secure_test` which returns a value indicating whether it's valid or not. Let's look at that function.
```c
int my_secure_test(char *param_1)

{
  int iVar1;
  
  if ((*param_1 == '\0') || (*param_1 != '1')) {
    iVar1 = -1;
  }
  else if ((param_1[1] == '\0') || (param_1[1] != '3')) {
    iVar1 = -1;
  }
  else if ((param_1[2] == '\0') || (param_1[2] != '3')) {
    iVar1 = -1;
  }
  else if ((param_1[3] == '\0') || (param_1[3] != '7')) {
    iVar1 = -1;
  }
  else if ((param_1[4] == '\0') || (param_1[4] != '_')) {
    iVar1 = -1;
  }
  else if ((param_1[5] == '\0') || (param_1[5] != 'p')) {
    iVar1 = -1;
  }
  else if ((param_1[6] == '\0') || (param_1[6] != 'w')) {
    iVar1 = -1;
  }
  else if ((param_1[7] == '\0') || (param_1[7] != 'd')) {
    iVar1 = -1;
  }
  else if (param_1[8] == '\0') {
    iVar1 = 0;
  }
  else {
    iVar1 = -1;
  }
  return iVar1;
}
```

Alright, now we've gotten to the core of the password checking. We have a big if-else chain that checks if each character in `param_1` is either `\0` (aka the null terminator, which indicates the end of the string), or a particular character. If we pick out all of those from this if-else chain, one by one, we can see that the string that will make this function return 0 (indicating a correct password, as we saw in `compare_pwd`) is `1337_pwd`. Let's give it a try.
```sh
$ ./crackme6 1337_pwd
password OK
```

Great!

### Crackme7
Coming soon
# meme-stash
*The source code for this challenge can be found [here](https://github.com/karma9874/My-CTF-Challenges/tree/main/DarkCON-ctf/Web/Meme-Stash)*


- run gobuster on challenge url
- find /.git/HEAD is exposed
- do some searching and reading on getting the full repository from a git repo, find the gitjacker tool
    - https://github.com/liamg/gitjacker
    - accompanying blog post https://www.liam-galvin.co.uk/security/2020/09/26/leaking-git-repos-from-misconfigured-sites.html

- run gitjacker 
- in the repo found by gitjacker, the meme-stash directory has an extra image that contains the flag
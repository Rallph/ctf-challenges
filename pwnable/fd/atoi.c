#include<stdio.h>
#include<string.h>

int main(int argc, char* argv[]) {
	if (argc < 2) {
		printf("enter a string");
		return 1;
	}

	printf("%x",* argv[1]);
	return 0;
}

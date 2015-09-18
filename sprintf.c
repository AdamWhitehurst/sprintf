#include <stdio.h>

int main(){
	char test[20];
	sprintf(test, "This is a test %d", 1);
	puts(test);
	return 0;
}
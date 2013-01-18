#include "ksyscall.h"
#include <sys/stat.h>
#include <errno.h>
int syscall(int num, int a, int b, int c, int d, int e)
{
	errno = 0;
	int x;
	__asm__ __volatile__("int $0x80":"=a"(x):"0" (num), "b" ((int)a),
			 "c" ((int)b), "d" ((int)c), "S" ((int)d), "D" ((int)e));
	return x;
}

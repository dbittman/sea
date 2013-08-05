#include "ksyscall.h"
#include <sys/stat.h>
#include <errno.h>
scarg_t syscall(int num, scarg_t a, scarg_t b, scarg_t c, scarg_t d, scarg_t e)
{
	errno = 0;
	scarg_t x;
	__asm__ __volatile__("int $0x80":"=a"(x):"0" (num), "b" ((scarg_t)a),
			 "c" ((scarg_t)b), "d" ((scarg_t)c), "S" ((scarg_t)d), "D" ((scarg_t)e));
	return x;
}

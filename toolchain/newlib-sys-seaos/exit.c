#include "ksyscall.h"
#include <signal.h>
#include <stdio.h>

void _exit(int z)
{
	syscall(SYS_EXIT, z, 0, 0, 0, 0);
	for(;;);
}

void __exit(int z)
{
	return _exit(z);
}

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <sys/stat.h>
#include "ksyscall.h"
#include <sys/dirent.h>
#include <sys/reboot.h>
#include <errno.h>
#include <errno.h>
__attribute__ ((weak)) int optreset=0;

int __this_is_seaos__()
{
	return 1;
}

void kernel_reset(void)
{
	syscall(SYS_KRESET, RB_AUTOBOOT,0,0,0,0);
}

void kernel_shutdown(void)
{
	syscall(SYS_KPOWOFF, 0,0,0,0,0);
}

int reboot(int __howto)
{
	int ret = syscall(SYS_KRESET, __howto, 0, 0, 0, 0);
	if(ret < 0)
	{
		errno = -ret;
		return -1;
	}
	return ret;
}

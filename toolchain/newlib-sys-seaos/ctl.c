#include <sys/times.h>
#include <sys/time.h>
#include <time.h>
#include <errno.h>
#include <fcntl.h>
#include <stddef.h>
#include <unistd.h>
#include <limits.h>
#include <sys/stat.h>
#include "linux_fsinfo.h"
#include "ksyscall.h"
#include <stdio.h>
#include "sys/dirent.h"
#include <stdarg.h>

/* okay, so we don't _actually_ support the va_args thing here,
 * but we pretend to to squelch errors */
int fcntl(int des, int cmd, ...)
{
	va_list args;
	va_start(args, cmd);
	
	int ret = syscall(SYS_FCNTL, des, cmd, va_arg(args, long), 0, 0);
	
	va_end(args);
	if(ret < 0) {
		errno = -ret;
		return -1;
	}
	return ret;
}

int ioctl(int fp, int cmd, long arg)
{
	int ret = syscall(SYS_IOCTL, fp, cmd, arg, 0, 0);
	if(ret < 0) {
		errno = -ret;
		return -1;
	}
	return ret;
}

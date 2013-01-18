#include "ksyscall.h"
#include <sys/types.h>
#include <sys/statfs.h>
#include <stdio.h>
#include <unistd.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <errno.h>
int ftruncate(int f, off_t len)
{
	int ret = syscall(SYS_FTRUNCATE, f, len, 0, 0, 0);
	if(ret < 0)
	{
		errno = -ret;
		return -1;
	}
	return ret;
}

int truncate(const char *p, off_t len)
{
	int f = open(p, O_RDWR, 0);
	if(f < 0) return -1;
	int res =  ftruncate(f, len);
	int _e = errno;
	close(f);
	errno = _e;
	return res;
}

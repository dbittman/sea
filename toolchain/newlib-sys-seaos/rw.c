#include "ksyscall.h"
#include <sys/types.h>
#include <sys/statfs.h>
#include <stdio.h>
#include <unistd.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <errno.h>
off_t lseek (int fd, off_t offset, int whence)
{
	int ret = syscall(SYS_SEEK, fd, offset, whence, 0, 0);
	if(ret < 0) {
		errno = -ret;
		return -1;
	}
	return ret;
}

int write (int fd, const void *buf, size_t nbytes)
{
	int ret = syscall(SYS_WRITE, fd, (int)buf, nbytes, 0, 0);
	if(ret < 0)
	{
		errno = -ret;
		return -1;
	}
	return ret;
}

int read (int fd, void *buf, size_t nbytes)
{
	int ret = syscall(SYS_READ, fd, (int)buf, nbytes, 0, 0);
	if(ret < 0)
	{
		errno = -ret;
		return -1;
	}
	return ret;
}

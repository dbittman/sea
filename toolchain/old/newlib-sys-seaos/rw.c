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

off_t _lseek (int fd, off_t offset, int whence)
{
	return lseek(fd, offset, whence); 
}

int write (int fd, const void *buf, size_t nbytes)
{
	int ret = syscall(SYS_WRITE, fd, (scarg_t)buf, nbytes, 0, 0);
	if(ret < 0)
	{
		errno = -ret;
		return -1;
	}
	return ret;
}

int _write (int fd, const void *b, size_t n)
{
	return write(fd, b, n);
}

int read (int fd, void *buf, size_t nbytes)
{
	int ret = syscall(SYS_READ, fd, (scarg_t)buf, nbytes, 0, 0);
	if(ret < 0)
	{
		errno = -ret;
		return -1;
	}
	return ret;
}

int _read(int fd, void *b, size_t n)
{
	return read(fd, b, n);
}


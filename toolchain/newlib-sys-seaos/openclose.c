#include "ksyscall.h"
#include <sys/types.h>
#include <sys/statfs.h>
#include <stdio.h>
#include <unistd.h>
#include <sys/stat.h>
#include <stdarg.h>
#include <fcntl.h>
#include <errno.h>
int open (const char *buf, int flags, ...)
{
	va_list vargs;
	va_start(vargs, flags);
	mode_t mode=0;
	/* if we call with flags that ask for a mode, then we grab the third
	 * argument */
	if(flags & O_CREAT)
		mode = va_arg(vargs, mode_t);
	va_end(vargs);
	int ret = syscall(SYS_OPEN, (int)buf, flags, (int)mode, 0, 0);
	if(ret < 0) {
		errno = -ret;
		return -1;
	}
	return ret;
}

int close (int fd)
{
	int ret = syscall(SYS_CLOSE, fd, 0, 0, 0, 0);
	if(ret < 0) {
		errno=-ret;
		return -1;
	}
	return ret;
}

int do_dup(int i, int f)
{
	int ret = syscall(SYS_DUP2, i, f, 0, 0, 0);
	if(ret < 0)
	{
		errno = -ret;
		return -1;
	}
	return ret;
}

int dup2 (int fd1, int fd2)
{
	int saved_errno, r;
	/* If FD1 is not a valid file descriptor, then return immediately with
	   an error. */
	if (fcntl (fd1, F_GETFL, 0) == -1)
		return (-1);

	if (fd2 < 0 || fd2 >= getdtablesize ())
	{
		errno = EBADF;
		return (-1);
	}

	if (fd1 == fd2)
		return (0);

	saved_errno = errno;

	(void) close (fd2);
	r = fcntl (fd1, F_DUPFD, fd2);

	if (r >= 0)
		errno = saved_errno;
	else if (errno == EINVAL)
		errno = EBADF;
	return (r);
}

int dup(int i)
{
	return do_dup(i, 0);
}

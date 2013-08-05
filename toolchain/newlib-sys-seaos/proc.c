#include "ksyscall.h"
#include <signal.h>
#include <stdio.h>
#include <errno.h>
#include <errno.h>
int waitpid(int pid, int *stat, int opt)
{
	int ret = syscall(SYS_WAITPID, pid, (scarg_t)stat, opt, 0, 0);
	if(ret < 0) {
		errno = -ret;
		return -1;
	}
	return ret;
}

int wait(int *stat)
{
	int ret = syscall(SYS_WAITPID, -1, (scarg_t)stat, 0, 0, 0);
	if(ret < 0) {
		errno = -ret;
		return -1;
	}
	return ret;
}

int _wait(int *s)
{
	return wait(s);
}

int waitagain()
{
	return syscall(SYS_WAITAGAIN, 0, 0, 0, 0, 0);
}

int sbrk (int nbytes)
{
	int ret = syscall(SYS_SBRK, nbytes, 0, 0, 0, 0);
	if(ret < 0) {
		errno = -ret;
		return -1;
	}
	return ret;
}

int _sbrk(int n)
{
	return sbrk(n);
}

unsigned alarm(unsigned s)
{
	int ret = syscall(SYS_ALARM, s, 0, 0, 0, 0);
	if(ret < 0)
	{
		errno = -ret;
		return -1;
	}
	return ret;
}

mode_t umask(mode_t mode)
{
	int ret = syscall(SYS_UMASK, mode, 0, 0, 0, 0);
	if(ret < 0) {
		errno = -ret;
		return -1;
	}
	return ret;
}

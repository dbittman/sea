/* id.c - deal with various IDs for things. uid, gid, etc. Many of these
 * functions don't return errors ever. */

#include "ksyscall.h"
#include <signal.h>
#include <stdio.h>
#include <errno.h>
int getpid()
{
	int ret = syscall(SYS_GETPID, 0, 0, 0, 0, 0);
	if(ret < 0) {
		errno = -ret;
		return -1;
	}
	return ret;
}

uid_t get_uid()
{
	return syscall(SYS_GETUID, 0,0,0,0,0);
}

int getgrgid()
{
	return 0;
}

int setpgid(pid_t a, pid_t b)
{
	int ret = syscall(SYS_SETPGID, a, b, 0, 0, 0);
	if(ret < 0)
	{
		errno=-ret;
		return -1;
	}
	return ret;
}

int setpgrp()
{
	return setpgid(0,0);
}

uid_t getuid()
{
	return get_uid();
}

uid_t geteuid()
{
	return syscall(SYS_GETUID, 0,0,0,0,0);
}

gid_t get_gid()
{
	return syscall(SYS_GETGID, 0,0,0,0,0);
}

int set_uid(int n)
{
	int ret = syscall(SYS_SETUID, n,0,0,0,0);
	if(ret < 0) {
		errno = -ret;
		return -1;
	}
	return ret;
}

gid_t set_gid(int n)
{
	int ret = syscall(SYS_SETGID, n,0,0,0,0);
	if(ret < 0) {
		errno = -ret;
		return -1;
	}
	return ret;
}

int setreuid(uid_t r, uid_t e)
{
	int ret = syscall(SYS_SETUID, r,e,0,0,0);
	if(ret < 0) {
		errno = -ret;
		return -1;
	}
	return ret;
}

int setregid(gid_t r, gid_t e)
{
	int ret = syscall(SYS_SETGID, r,e,0,0,0);
	if(ret < 0) {
		errno = -ret;
		return -1;
	}
	return ret;
}

gid_t getgid()
{
	return get_gid();
}

gid_t getegid()
{
	return syscall(SYS_GETGID, 0,0,0,0,0);
}

int setuid(uid_t n)
{
	return set_uid(n);
}

int setgid(gid_t n)
{
	return set_gid(n);
}

int getppid()
{
	return syscall(SYS_GETPPID, 0, 0, 0, 0, 0);
}

pid_t setsid()
{
	int ret = syscall(SYS_SETSID, 0, 0, 0, 0, 0);
	if(ret < 0) {
		errno=-ret;
		return -1;
	}
	return ret;
}

pid_t getsid(pid_t p)
{
	int ret = syscall(SYS_SETSID, 1, p, 0, 0, 0);
	if(ret < 0) {
		errno=-ret;
		return -1;
	}
	return ret;
}

int getpgrp()
{
	/* TODO: */
	return getgid();
}

#include "ksyscall.h"
#include <sys/types.h>
#include <sys/statfs.h>
#include <stdio.h>
#include <unistd.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <errno.h>
/* [f]chdir - change the working directory.*/
int chdir(const char *path)
{
	int ret = syscall(SYS_CHDIR, path, 0, 0, 0,0);
	if(ret < 0)
	{
		errno = -ret;
		return -1;
	}
	return ret;
}

int fchdir(int fd)
{
	int ret = syscall(SYS_CHDIR, 0, fd, 0, 0, 0);
	if(ret < 0)
	{
		errno = -ret;
		return -1;
	}
	return ret;
}

int chmod(const char *p, mode_t m)
{
	int ret=syscall(SYS_CHMOD, (int)p, -1, m, 0, 0);
	if(ret < 0)
	{
		errno = -ret;
		return -1;
	}
	return ret;
}

int fchmod(int fd, mode_t m)
{
	int ret=syscall(SYS_CHMOD, 0, fd, m, 0, 0);
	if(ret < 0)
	{
		errno = -ret;
		return -1;
	}
	return ret;
}

int chown(const char *path, uid_t owner, gid_t group)
{
	int ret = syscall(SYS_CHOWN, path, -1, owner, group, 0);
	if(ret < 0)
	{
		errno = -ret;
		return -1;
	}
	return 0;
}

int fchown(int filedes, uid_t own, gid_t grp)
{
	int ret = syscall(SYS_CHOWN, 0, filedes, own, grp, 0);
	if(ret < 0)
	{
		errno = -ret;
		return -1;
	}
	return 0;
}

int chroot(const char *path)
{
	int ret = syscall(SYS_CHROOT, (int)path, 0, 0, 0, 0);
	if(ret < 0)
	{
		errno = -ret;
		return -1;
	}
	return ret;
}

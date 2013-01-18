#include "ksyscall.h"
#include <sys/types.h>
#include <sys/statfs.h>
#include <stdio.h>
#include <unistd.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <errno.h>
int unlink(const char * path)
{
	int ret = syscall(SYS_UNLINK, (int)path, 0, 0, 0, 0);
	if(ret < 0)
	{
		errno = -ret;
		return -1;
	}
	return ret;
}

int link(const char *path1, const char *path2)
{
	int ret= syscall(SYS_LINK, (int)path1, (int)path2, 0, 0, 0);
	if(ret < 0)
	{
		errno = -ret;
		return -1;
	}
	return ret;
}

int _link(const char *path1, const char *path2)
{
	return link(path1, path2);
}

int _syslink(const char *path1, const char *path2)
{
	return link(path1, path2);
}

ssize_t readlink(const char * path, char * buf, size_t bufsize)
{
	int ret= syscall(SYS_READLINK, (int)path, (int)buf, bufsize, 0, 0);
	if(ret < 0)
	{
		errno = -ret;
		return -1;
	}
	return ret;
}

int symlink(const char *p1, const char *p2)
{
	int ret=syscall(SYS_SYMLINK, (int)p1, (int)p2, 0, 0, 0);
	if(ret < 0)
	{
		errno = -ret;
		return -1;
	}
	return ret;
}

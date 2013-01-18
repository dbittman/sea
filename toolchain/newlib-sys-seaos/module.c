#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <sys/stat.h>
#include "ksyscall.h"
#include <sys/dirent.h>
#include <errno.h>
int sea_load_module(char *path, char *opts, int flags)
{
	int ret = syscall(SYS_LMOD, (int)path, opts, flags, 0, 0);
	if(ret < 0) {
		errno = -ret;
		return -1;
	}
	return ret;
}

int sea_unload_module(char *path, int flags)
{
	int ret = syscall(SYS_ULMOD, (int)path, flags, 0, 0, 0);
	if(ret < 0) {
		errno = -ret;
		return -1;
	}
	return ret;
}

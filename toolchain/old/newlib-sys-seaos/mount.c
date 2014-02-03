#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <sys/stat.h>
#include "ksyscall.h"
#include <sys/dirent.h>
#include <errno.h>
int sea_mount_filesystem(char *node, char *dir, char *fsname, char *opts, int flags)
{
	int ret = syscall(SYS_MOUNT2, node, dir, fsname, opts, flags);
	if(ret < 0) {
		errno = -ret;
		return -1;
	}
	return ret;
}

int sea_umount_filesystem(char *dir, int flags)
{
	int ret = syscall(SYS_UMOUNT, dir, flags, 0, 0, 0);
	if(ret < 0) {
		errno = -ret;
		return -1;
	}
	return ret;
}

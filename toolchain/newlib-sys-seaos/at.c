#include <sys/times.h>
#include <sys/time.h>
#include <time.h>
#include <errno.h>
#include <fcntl.h>
#include <stddef.h>
#include <unistd.h>
#include <limits.h>
#include <sys/stat.h>
#include "linux_fsinfo.h"
#include "ksyscall.h"
#include <stdio.h>
#include "sys/dirent.h"
#include <sys/utsname.h>

int unlinkat(int fd, const  char * path, int flags)
{
	char *newpath;
	if(fd >= 0)
		newpath = (char *)__internal_get_path_string(fd);
	else
		newpath = (char *)malloc(NAME_MAX+2);
	if(!newpath) {
		errno = ENOMEM;
		return -1;
	}
	if(path[0] != '/' && fd >= 0) {
		int ret;
		if((ret=syscall(SYS_GETPATH, fd, (scarg_t)newpath, __internal_calc_path_length(syscall(SYS_GETDEPTH, fd, 0, 0, 0, 0)), 0, 0)) < 0) {
			errno = -ret;
			free(newpath);
			return -1;
		}
		/* lets make sure that we append properly.
		 * If fd doesn't point to a directory, then this
		 * wont make sense. But fuck it, we'll just error out later */
		if(newpath[strlen(newpath)-1] != '/')
			strcat(newpath, "/");
		strcat(newpath, path);
	} else
		strcpy(newpath, path);
	if(flags & AT_REMOVEDIR)
		rmdir(newpath);
	else
		unlink(newpath);
	free(newpath);
	return 0;
}

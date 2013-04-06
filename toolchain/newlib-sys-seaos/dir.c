#include "ksyscall.h"
#include <sys/types.h>
#include <sys/statfs.h>
#include <stdio.h>
#include <unistd.h>
#include <sys/stat.h>
#include <stdlib.h>
#include "./sys/dirent.h"
#include <errno.h>
#include <fcntl.h>
#include <limits.h>
#include <sys/times.h>
#include <sys/time.h>
#include <time.h>
#include <stddef.h>
#include "linux_fsinfo.h"
#include "ksyscall.h"
#include <sys/utsname.h>
int mkdir(const char *argv, mode_t mode)
{
	char tmp[strlen(argv) + 2];
	memset(tmp, 0, strlen(argv) + 2);
	strcpy(tmp, argv);
	strcat(tmp, "/");
	int ret = open(tmp, O_CREAT | O_EXCL, mode);
	if(ret < 0)
		return -1;
	else
		close(ret);
	return 0;
}

/* Get the pathname of the current working directory,
   and put it in SIZE bytes of BUF.  Returns NULL if the
   directory couldn't be determined or SIZE was too small.
   If successful, returns BUF.  In GNU, if BUF is NULL,
   an array is allocated with `malloc'; the array is SIZE
   bytes long, unless SIZE <= 0, in which case it is as
   big as necessary.  */
#include <sys/dirent.h>

int get_cwd_pathlength()
{
	return syscall(SYS_GETCWDLEN, 0, 0, 0, 0, 0);
}

__attribute__ ((weak)) char *getcwd (char *buf, size_t size)
{
	errno = 0;
	if(buf && !size) {
		errno = EINVAL;
		return 0;
	}
	
	if(!buf) {
		if(!size) size = get_cwd_pathlength();
		if(!size) return (char *)0;
		buf = (char *)malloc(size);
	}
	
	memset(buf, 0, size);
	
	int ret = syscall(SYS_GETPWD, buf, size, 0, 0, 0);
	if(ret < 0) {
		errno = -ret;
		return 0;
	}
	return buf;
}

int rmdir(const char *b)
{
	int ret= syscall(SYS_RMDIR, (int) b, 0, 0, 0, 0);
	if(ret < 0)
	{
		errno = -ret;
		return -1;
	}
	return ret;
}

int getdents (int fd, void *dp, int count)
{
	int ret = syscall(SYS_GETDENTS, fd, (int)dp, count, 0, 0);
	if(ret < 0)
	{
		errno = -ret;
		return -1;
	}
	return ret;
}

DIR *opendir(const char *name)
{
	DIR *d = (DIR *)malloc(sizeof(DIR));
	d->pos=0;
	int res = open(name, 0, 0);
	if(res < 0) {
		free(d);
		return 0;
	}
	d->fd=res;
	return d;
}

/* This really needs cleaning up */
struct dirent *readdir(DIR *d)
{
	errno=0;
	if(!d || d->fd < 0)
	{
		errno = EBADF;
		return 0;
	}
	char name[NAME_MAX+1];
	memset(name, 0, NAME_MAX+1);
	struct stat statb;
	int ret = syscall(SYS_DIRSTATFD, d->fd, d->pos, name, &statb, 0);
	if(ret < 0) {
		if(ret != -ESRCH) 
			errno = -ret;
		return 0;
	}
	d->pos++;
	
	struct dirent *de = &d->__d;
	memset(de, 0, sizeof(*de));
	de->d_ino = statb.st_ino;
	if(S_ISCHR(statb.st_mode))
		de->d_type=3;
	else if(S_ISBLK(statb.st_mode))
		de->d_type=4;
	else if(S_ISREG(statb.st_mode))
		de->d_type=1;
	else if(S_ISDIR(statb.st_mode))
		de->d_type=2;
	else if(S_ISLNK(statb.st_mode))
		de->d_type=7;
	strcpy(de->d_name, name);
	de->d_reclen=strlen(name);
	return de;
}

int closedir(DIR *d)
{
	if(!d || d->fd < 0)
	{
		errno=EBADF;
		return -1;
	}
	close(d->fd);
	d->fd=-1;
	free(d);
	return 0;
}

/* Rewind DIRP to the beginning of the directory.  */
void rewinddir (DIR *d)
{
	if(!d || d->fd < 0)
	{
		errno=EBADF;
		return;
	}
	d->pos=0;
}

/* Seek to position POS on DIRP.  */
void seekdir (DIR *d, long int __pos){
	if(!d || d->fd < 0)
	{
		errno=EBADF;
		return;
	}
	d->pos = __pos;
}

/* Return the current position of DIRP.  */
long int telldir (DIR *d){
	if(!d || d->fd < 0)
	{
		errno=EBADF;
		return -1;
	}
	return d->pos;
}

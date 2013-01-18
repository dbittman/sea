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

int daemon(int nochdir, int noclose)
{
	int fr = fork();
	if(fr < 0)
	{
		/* errno is set by fork */
		return -1;
	}
	/* parent exits */
	if(fr)
		exit(0);
	fflush(0);
	if(!noclose) {
		fclose(stdin);
		fclose(stdout);
		fclose(stderr);
	}
	if(!nochdir)
		chdir("/");
	int f = open("/dev/tty0", O_RDONLY, 0);
	if(f >= 0) {
		ioctl(f, 2, 0);
		close(f);
	}
	setsid();
	umask(0);
	int i = open("/dev/null", O_RDONLY);
	int o = open("/dev/null", O_RDWR);
	int e = open("/dev/null", O_RDWR);
	if(i > 0)
		close(i);
	if(o > 1 || !o)
		close(i);
	if(e > 2 || !e || e == 1)
		close(e);
	errno=0;
	return 0;
}

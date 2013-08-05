#include <utime.h>
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
clock_t _times(struct tms *b)
{
	scarg_t ret = syscall(SYS_TIMES, (scarg_t)b, 0, 0, 0, 0);
	if(ret < 0) {
		errno = -ret;
		return -1;
	}
	return ret;
}

clock_t times(struct tms *b)
{
	scarg_t ret = syscall(SYS_TIMES, (scarg_t)b, 0, 0, 0, 0);
	if(ret < 0) {
		errno = -ret;
		return -1;
	}
	return ret;
}

int get_timer_ticks_hz()
{
	return syscall(SYS_TIMERTH, 0, 0, 0, 0, 0);
}

int _gettimeofday(struct timeval *tv, void *g)
{
	unsigned p;
	scarg_t hz = syscall(SYS_TIMERTH, &p, 0, 0, 0, 0);
	struct tm t;
	syscall(SYS_GETTIME, (scarg_t)&t, 0, 0, 0, 0);
	tv->tv_sec = t.tm_sec + t.tm_min*60 + t.tm_hour*60*60;
	tv->tv_usec=(p % hz)*1000;
	return 0;
}

int gettimeofday(struct timeval *tv, void *g)
{
	unsigned p;
	scarg_t hz = syscall(SYS_TIMERTH, &p, 0, 0, 0, 0);
	struct tm t;
	syscall(SYS_GETTIME, (scarg_t)&t, 0, 0, 0, 0);
	tv->tv_sec = t.tm_sec + t.tm_min*60 + t.tm_hour*60*60;
	tv->tv_usec=(p % hz)*1000;
	return 0;
}

int utime(const char *path, const struct utimbuf *times)
{
	scarg_t ret = syscall(SYS_UTIME, path, times ? times->actime : 0, times ? times->modtime : 0, 0, 0);
	if(ret < 0) {
		errno = -ret;
		return -1;
	}
	return 0;
}

void delay(int t)
{
	syscall(SYS_DELAY, t,0,0,0,0);
}

unsigned sleep(unsigned s)
{
	delay(s * get_timer_ticks_hz());
}

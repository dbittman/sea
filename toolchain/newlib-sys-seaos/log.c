#include <limits.h>
#include <stdarg.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <sys/stat.h>
#include "ksyscall.h"
#include <sys/dirent.h>
#include <errno.h>
int sys_syslog(int level, char *buf, int len)
{
	int ret = syscall(SYS_SYSLOG, level, buf, len, 0, 0);
	if(ret < 0)
	{
		errno=-ret;
		return -1;
	}
	return ret;
}

void syslog(int lev, const char *fmt, ...)
{
	int ret;
	va_list ap;
	FILE f;
	char str[256];
	f._flags = __SWR | __SSTR;
	f._bf._base = f._p = (unsigned char *) str;
	f._bf._size = f._w = INT_MAX;
	f._file = -1;  /* No file. */
	va_start (ap, fmt);
	ret = _svfprintf_r (_REENT, &f, fmt, ap);
	va_end (ap);
	*f._p = '\0';	/* terminate the string */
	sys_syslog(lev, str, strlen(str));
}

void openlog(const char *i, int o, int f)
{
	syscall(SYS_SYSLOG, o, i, f, 1, 0);
}

void closelog(void)
{
	syscall(SYS_SYSLOG, 0, 0, 0, 2, 0);
}

void setlogmask(int mask)
{
	syscall(SYS_SYSLOG, mask, 0, 0, 3, 0);
}

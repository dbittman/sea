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
#include <netdb.h>

struct hostent ___internal_hostent;
struct hostent *gethostbyaddr(const void *addr, socklen_t len, int type)
{
	int ret = syscall(SYS_GETHOST, (int)&___internal_hostent, (int)addr, (int)len, type, 0);
	if(ret < 0)
	{
		errno = -ret;
		return 0;
	}
	return &___internal_hostent;
}

struct hostent *gethostbyname(const char *name)
{
	int ret = syscall(SYS_GETHOST, (int)&___internal_hostent, 0, 0, 0, (int)name);
	if(ret < 0)
	{
		errno = -ret;
		return 0;
	}
	return &___internal_hostent;
}

int gethostname(char *name, size_t len)
{
	int ret = syscall(SYS_GETHOSTNAME, name, len, 0, 0, 0);
	if(ret < 0)
	{
		errno = -ret;
		return -1;
	}
	return 0;
}

void endservent(void)
{
	syscall(SYS_SETSERV, 0, 0, 0, 0, 0);
}

struct servent ___internal_servent;
struct servent *getservbyname(const char *name, const char *proto)
{
	int ret = syscall(SYS_GETSERV, 0, name, proto, (int)&___internal_servent, 0);
	if(ret < 0)
	{
		errno = -ret;
		return 0;
	}
	return &___internal_servent;
}

struct servent *getservbyport(int port, const char *proto)
{
		int ret = syscall(SYS_GETSERV, port, 0, proto, (int)&___internal_servent, 0);
	if(ret < 0)
	{
		errno = -ret;
		return 0;
	}
	return &___internal_servent;
}

struct servent *getservent(void)
{
	int ret = syscall(SYS_GETSERV, 0, 0, 0, (int)&___internal_servent, 0);
	if(ret < 0)
	{
		errno = -ret;
		return 0;
	}
	return &___internal_servent;
}

void setservent(int stayopen)
{
	syscall(SYS_SETSERV, 1, stayopen, 0, 0, 0);
}

unsigned long   htonl (unsigned long a){return a;}
unsigned short  htons (unsigned short a){return a;}
unsigned long   ntohl (unsigned long a){return a;}
unsigned short  ntohs (unsigned short a){return a;}

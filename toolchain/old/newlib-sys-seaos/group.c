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

int getgroups(int gidsetsize, gid_t grouplist[])
{
	return 0;
}

void endgrent()
{
	
}

void setgrent()
{
	
}

void getgrent()
{
	
}

int getgrnam()
{
	return 0;
}

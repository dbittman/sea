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

/* mmap and munmap are not quite ready yet. They will be enabled soon */
void *__mmap(void *addr, size_t len, int prot, int flags, int fildes, off_t off)
{
	struct mmapblock {
		size_t len;
		off_t off;
	} c;
	c.len = len;
	c.off = off;
	unsigned ret = syscall(SYS_MMAP, (unsigned)addr, (unsigned)&c, prot, flags, fildes);
	if(ret < 0x1000) {
		/* Is an error code */
		errno = ret;
		return (void *)-1;
	}
	return (void *)ret;
}

int __munmap(void *addr, size_t sz)
{
	int ret = syscall(SYS_MUNMAP, (unsigned)addr, sz, 0, 0, 0);
	if(ret < 0)
	{
		errno = -ret;
		return -1;
	}
	return 0;
}

int posix_memalign (void **memptr, size_t alignment, size_t size)
{
	void *mem;
	/* Test whether the ALIGNMENT argument is valid.  It must be a power
	 of two mult*iple of sizeof (void *).  */
	if (alignment % sizeof (void *) != 0 || (alignment & (alignment - 1)) != 0)
		return EINVAL;
	mem = (void *)memalign (alignment, size);
	if (mem != NULL)
	{
		*memptr = mem;
		return 0;
	}
	return ENOMEM;
}

int getpagesize()
{
	return sysconf(_SC_PAGESIZE);
}

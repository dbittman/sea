#ifndef _SYS_SELECT_H
#define _SYS_SELECT_H	1

#include <sys/types.h>
#include <sys/time.h>
#undef fd_set
typedef struct {
        unsigned long fds_bits [(1024/(8 * sizeof(unsigned long)))];
} fd_set;
int select (int __nfds, fd_set *__restrict __readfds,
		   fd_set *__restrict __writefds,
		   fd_set *__restrict __exceptfds,
		   struct timeval *__restrict __timeout);

#endif /* sys/select.h */

#include "ksyscall.h"
#include <signal.h>
#include <stdio.h>
#include <errno.h>
pid_t vfork(void)
{
	pid_t pid;
	
	pid = fork();
	
	if(!pid)
	{
		/* In child. */
		return 0;
	}
	else
	{
		/* In parent.  Wait for child to finish. */
		if (waitpid (pid, NULL, 0) < 0)
			return pid;
	}
}

int fork()
{
	int ret = syscall(SYS_FORK, 0, 0, 0, 0, 0);
	if(ret < 0) {
		errno = -ret;
		return -1;
	}
	return ret;
}

/* execve.c */

/* This and the other exec*.c files in this directory require 
   the target to provide the _execve syscall.  */


#include <unistd.h>
#include <ksyscall.h>
#include <errno.h>
int
_DEFUN(execve, (path, argv, envp),
      const char *path _AND
      char * const argv[] _AND
      char * const envp[])
{
  return _execve (path, argv, envp);
}

int _execve(char *path, char **argv, char **env)
{
	int ret = syscall(SYS_EXECVE, (int)path, (int)argv, (int)env, 0, 0);
	errno = -ret;
	return -1;
}

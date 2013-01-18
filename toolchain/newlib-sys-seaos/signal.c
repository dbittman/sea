/* BSD-like signal function.
   Copyright (C) 1991, 1992, 1996, 1997, 2000 Free Software Foundation, Inc.
   This file is part of the GNU C Library.

   The GNU C Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.

   The GNU C Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with the GNU C Library; if not, write to the Free
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
   02111-1307 USA.  */

#include <errno.h>
#include <signal.h>
#include "ksyscall.h"
#include <errno.h>
#define sigaddset(what,sig) (*(what) |= (1<<(sig)), 0)
#define sigdelset(what,sig) (*(what) &= ~(1<<(sig)), 0)
#define sigemptyset(what)   (*(what) = 0, 0)
#define sigfillset(what)    (*(what) = ~(0), 0)
#define sigismember(what,sig) (((*(what)) & (1<<(sig))) != 0)
#define weak_alias(name, aliasname) \
  extern __typeof (name) aliasname __attribute__ ((weak, alias (#name)));
# define SA_RESTART   0x10000000
sigset_t _sigintr;		/* Set by siginterrupt.  */
typedef void (*_sig_func_ptr) (int);
typedef _sig_func_ptr __sighandler_t;
/* Set the handler for the signal SIG to HANDLER,
   returning the old handler, or SIG_ERR on error.  */
__sighandler_t signal (int sig, __sighandler_t handler)
{
	struct sigaction act, oact;

	/* Check signal extents to protect __sigismember.  */
	if (handler == SIG_ERR || sig < 1 || sig >= NSIG)
	{
		errno = (EINVAL);
		return SIG_ERR;
	}

	act.sa_handler = handler;
	if (sigemptyset (&act.sa_mask) < 0 || sigaddset (&act.sa_mask, sig) < 0)
		return SIG_ERR;
	act.sa_flags = sigismember (&_sigintr, sig) ? 0 : SA_RESTART;
	if (sigaction (sig, &act, &oact) < 0)
		return SIG_ERR;

	return oact.sa_handler;
}

int sigprocmask(int how, const sigset_t *set, sigset_t *oset)
{
	int ret = syscall(SYS_SIGPROCMASK, how, set, oset, 0, 0);
	if(ret < 0) {
		errno = -ret;
		return -1;
	}
	return ret;
}

int pause()
{
	syscall(SYS_SIGNAL, getpid(), SIGISLEEP, 0, 0, 0);
	return 0;
}

int kill(int pid, int sig)
{
	int ret = syscall(SYS_SIGNAL, pid, sig, 0, 0, 0);
	if(ret < 0) {
		errno = -ret;
		return -1;
	}
	return ret;
}

int sigaction(int sig, const struct sigaction *act, struct sigaction *oact) {
	int ret = syscall(SYS_SIGACT, sig, (int)act, (int)oact, 0, 0);
	if(ret < 0) {
		errno = -ret;
		return -1;
	}
	return ret;
}

int sigsetjmp(void *a, int x)
{
	return setjmp(a);
}

int siglongjmp(void *a, int x)
{
	return longjmp(a);
}

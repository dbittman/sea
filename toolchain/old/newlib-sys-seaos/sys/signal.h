/* sys/signal.h */
#ifndef _SYS_SEA_SIGNAL_H
#define _SYS_SEA_SIGNAL_H
#define HAVE_POSIX_SIGNALS 1
#define sigaddset(what,sig) (*(what) |= (1<<(sig)), 0)
#define sigdelset(what,sig) (*(what) &= ~(1<<(sig)), 0)
#define sigemptyset(what)   (*(what) = 0, 0)
#define sigfillset(what)    (*(what) = ~(0), 0)
#define sigismember(what,sig) (((*(what)) & (1<<(sig))) != 0)
#include "_ansi.h"
#include <sys/features.h>
#include <sys/types.h>

/* #ifndef __STRICT_ANSI__*/
union sigval {
	int    sival_int;    /* Integer signal value */
	void  *sival_ptr;    /* Pointer signal value */
};

#define SI_USER 1

typedef struct {
	int          si_signo;    /* Signal number */
	int          si_code;     /* Cause of the signal */
	union sigval si_value;    /* Signal value */
	unsigned si_addr;
	int si_pid;
} siginfo_t;
typedef unsigned long sigset_t;

/*  3.3.8 Synchronously Accept a Signal, P1003.1b-1993, p. 76 */

                         /*   three arguments instead of one. */
 #define SA_NOCLDSTOP	0x00000001
 #define SA_NOCLDWAIT	0x00000002
 #define SA_SIGINFO	0x00000004
 #define SA_ONSTACK	0x08000000
 #define SA_RESTART	0x10000000
 #define SA_NODEFER	0x40000000
 #define SA_RESETHAND	0x80000000
 
 #define SA_NOMASK	SA_NODEFER
 #define SA_ONESHOT	SA_RESETHAND

typedef void (*_sig_func_ptr)(int);

struct sigaction
{
	union
	{
		void (*_sa_handler) (int);
		/* Present to allow compilation, but unsupported by gnulib.  POSIX
		 s ays that implementations may, but not* must, make sa_sigaction
		 overlap with sa_handler, but we know of no implementation where
		 they do not overlap.  */
		void (*_sa_sigaction) (int, siginfo_t *, void *);
	} _sa_func;
	sigset_t sa_mask;
	/* Not all POSIX flags are supported.  */
	int sa_flags;
};
#  define sa_handler _sa_func._sa_handler
#  define sa_sigaction _sa_func._sa_sigaction


#define SIG_SETMASK 0	/* set mask with sigprocmask() */
#define SIG_BLOCK 1	/* set of signals to block */
#define SIG_UNBLOCK 2	/* set of signals to, well, unblock */

/* These depend upon the type of sigset_t, which right now 
   is always a long.. They're in the POSIX namespace, but
   are not ANSI. */


int _EXFUN(sigprocmask, (int how, const sigset_t *set, sigset_t *oset));


int _EXFUN(kill, (pid_t, int));
int _EXFUN(killpg, (pid_t, int));
int _EXFUN(sigaction, (int, const struct sigaction *, struct sigaction *));
int _EXFUN(sigpending, (sigset_t *));
int _EXFUN(sigsuspend, (const sigset_t *));
int _EXFUN(sigpause, (int));

/* #endif __STRICT_ANSI__ */

#define SIGNULL 0
#define SIGCHILD 1 /* Child has died */
#define SIGCHLD SIGCHILD
#define SIGINT 2   /* stdout has encountered a problem */
#define SIGIN 3    /* stdin has encountered a problem */
#define SIGERR 4   /* stderr " */
#define SIGSTOP 5  /* General stop */
#define SIGUSLEEP 6 /* Sets task to USLEEP. Can only be awakened by the kernel */
#define SIGISLEEP 7 /* Sets task to ISLEEP */
#define SIGHUP 8   /* Hangup */
#define SIGKILL 9  /* Kill */
#define SIGABRT 10
#define SIGTRAP 11
#define SIGSEGV 12
#define SIGQUIT 13
#define SIGALRM  14 /* Illegal instruction */
#define SIGPAGE 15 /* Page fault */
#define SIGMSG  16
#define SIGPARENT 17
#define SIGWAIT 18
#define SIGILL 19
#define SIGOUT 20
#define SIGTERM 21
#define SIGPIPE 22
#define SIGUSR1 30
#define SIGUSR2 31
#define SIGTSTP 23
#define SIGCONT 24
#define SIGTTIN 25
#define SIGTTOU 26
#define SIGFPE 27
#define SIGBUS 28
#define SIGWINCH 29
#define MSGGET_PEEK 0
#define MSGGET_GET  1
#define NSIG 128

#ifndef _SIGNAL_H_
/* Some applications take advantage of the fact that <sys/signal.h>
 * and <signal.h> are equivalent in glibc.  Allow for that here.  */
#include <signal.h>
#endif
#endif /* _SYS_SIGNAL_H */

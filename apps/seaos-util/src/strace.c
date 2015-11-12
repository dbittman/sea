#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <sys/syscall.h>
#include <sys/ptrace.h>
#include <sys/user.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>
#include <errno.h>
#include <unistd.h>
int pid;                /*  child's process id          */
enum sc_arg_type {
	INT = 1,
	FP,
	HEXINT,
	OCTINT,
	POINTER,
	STRING,
};

struct syscall {
	const char *name;
	enum sc_arg_type arg_types[5];
};

struct syscall syscalls[128] = {
	[SYS_FSTAT] = { .name = "fstat", .arg_types = { FP, POINTER, 0, 0, 0 } },
	[SYS_STAT] = { .name = "stat", .arg_types = { STRING, POINTER, INT, 0, 0 } },
	[SYS_CLOSE] = { .name = "close", .arg_types = { FP, 0, 0, 0, 0 } },
	[SYS_OPEN]  = { .name = "open",  .arg_types = { STRING, INT, OCTINT, 0, 0 } },
	[SYS_SBRK]  = { .name = "sbrk",  .arg_types = { INT, 0, 0, 0, 0 } },
	[SYS_EXIT]  = { .name = "exit",  .arg_types = { INT, 0, 0, 0, 0 } },
	[SYS_WRITE] = { .name = "write",  .arg_types = { FP, POINTER, INT, 0, 0 } },
	[SYS_IOCTL] = { .name = "ioctl", .arg_types = { FP, INT, INT, 0, 0 } },
	[SYS_GETDENTS] = { .name = "getdents", .arg_types = { FP, POINTER, INT, 0, 0 } },
	[SYS_ACCESS] = { .name = "access", .arg_types = { STRING, INT, 0, 0, 0 } },
};

#if __x86_64__

#define SCARG5 rdi
#define SCARG4 rsi
#define SCARG3 rdx
#define SCARG2 rcx
#define SCARG1 rbx
#define SCNUM orig_rax
#define SCRET rax

#else

#define SCARG5 edi
#define SCARG4 esi
#define SCARG3 edx
#define SCARG2 ecx
#define SCARG1 ebx
#define SCNUM orig_eax
#define SCRET eax

#endif

int read_string_from(pid_t pid, long address, char *buf, int len)
{
	int i = 0;
	while(i<len) {
		long ret = ptrace(PTRACE_PEEKDATA, pid, (void *)address, 0);
		int j;
		for(j=0;i < len && j < sizeof(long);j++, i++) {
			char *bytes = (void *)&ret;
			buf[i] = bytes[j];
			if(bytes[j] == 0)
				return i;
		}
		address += sizeof(long);
	}
	return i;
}

void printarg(enum sc_arg_type type, long arg, int first)
{
	if(type == 0)
		return;
	if(!first)
		fprintf(stderr, ", ");
	switch(type) {
		char buf[129];
		int ret;
		case INT: case FP:
			fprintf(stderr, "%ld", arg);
			break;
		case HEXINT: case POINTER:
			fprintf(stderr, "%lx", arg);
			break;
		case OCTINT:
			fprintf(stderr, "%lo", arg);
			break;
		case STRING:
			ret = read_string_from(pid, arg, buf, 128);
			buf[128] = 0;
			if(ret < 128) {
				fprintf(stderr, "%x:%s", arg, buf);
			} else {
				fprintf(stderr, "%x:%s...", arg, buf);
			}
			break;
	}
}

void print_syscall(long addr, long num, long a, long b, long c, long d, long e)
{
	struct syscall *sys = &syscalls[num];
	if(sys->name) {
		fprintf(stderr, "-- %s ( ", sys->name);
		printarg(sys->arg_types[0], a, 1);
		printarg(sys->arg_types[1], b, 0);
		printarg(sys->arg_types[2], c, 0);
		printarg(sys->arg_types[3], d, 0);
		printarg(sys->arg_types[4], e, 0);
		fprintf(stderr, " ) from %p-> ", addr);
	} else {
		fprintf(stderr, "-- %ld ( %ld, %ld, %ld, %ld, %ld ) from %x -> ", num, a, b, c, d, e, addr);
		if(num == SYS_EXIT)
			fprintf(stderr, "EXIT\n");
	}
}

void usage()
{
	fprintf(stderr, "strace [options] <program> [program arguments]\n");
}

int main(int argc, char **argv)
{
    int wait_val;           /*  child's return value        */

	int c;
	while((c=getopt(argc, argv, "+h")) != -1) {
		switch(c) {
			case 'h':
				usage();
				return 0;
				break;
		}
	}

	int r;
    switch (pid = fork()) {
        case -1:
            perror("fork");
            break;
        case 0: /*  child process starts        */
            ptrace(PTRACE_TRACEME, 0, 0, 0);
            /* 
             *  must be called in order to allow the
             *  control over the child process
             */ 
            execvp(argv[optind], &argv[optind]);
            /*
             *  executes the program and causes
             *  the child to stop and send a signal 
             *  to the parent, the parent can now
             *  switch to PTRACE_SINGLESTEP   
             */ 
            break;
            /*  child process ends  */
        default:/*  parent process starts       */
            r = wait(&wait_val);
            /*   
             *   parent waits for child to stop at next 
             *   instruction (execl()) 
             */
            int starting_syscall = 1;
            while (WIFSTOPPED(wait_val)) {
                if (ptrace(PTRACE_SYSCALL, pid, 0, 0) != 0)
                    perror("ptrace");
                /* 
                 *   switch to singlestep tracing and 
                 *   release child
                 *   if unable call error.
                 */
                r = wait(&wait_val);
                if(wait_val == 3199) {
					fprintf(stderr, "process got SIGSEGV\n");
					ptrace(PTRACE_DETACH, pid, 0, 0);
					return 0;
                }
                /*   wait for next instruction to complete  */

				struct user u;
				r = ptrace(PTRACE_READUSER, pid, 0, &u);
				if(starting_syscall) {
					print_syscall(u.regs.rip, u.regs.SCNUM, u.regs.SCARG1, u.regs.SCARG2, u.regs.SCARG3, u.regs.SCARG4, u.regs.SCARG5);
					starting_syscall = 0;
					if(u.regs.SCNUM == 1) {
						fprintf(stderr, "process exited!\n");
						r = ptrace(PTRACE_DETACH, pid, 0, 0);
						break;
					}
				} else {
					fprintf(stderr, "returned %d\n", u.regs.SCRET);
					starting_syscall = 1;
				}

            }
            /*
             * continue to stop, wait and release until
             * the child is finished; wait_val != 1407
             * Low=0177L and High=05 (SIGTRAP)
             */
    }
    return 0;
}


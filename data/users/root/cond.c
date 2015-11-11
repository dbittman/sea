#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <syslog.h>
#include <string.h>
#include <errno.h>
#include <stdint.h>
#include <termios.h>
#include <sys/ioctl.h>
#include <assert.h>
#include <pty.h>
#include <stdbool.h>
#include <sys/time.h>
#include <sys/select.h>
#include <sys/types.h>
#include <signal.h>

#include "cond.h"

struct termios def_term = {
	.c_iflag = BRKINT | ICRNL,
	.c_oflag = ONLCR,
	.c_lflag = ICANON | ECHO | ISIG,
	.c_cc[VEOF] = 4,
	.c_cc[VEOL] = 0,
	.c_cc[VERASE] = '\b',
	.c_cc[VINTR] = 3,
	.c_cc[VMIN] = 1,
	.c_cc[VSUSP] = 26,
};

struct winsize def_win = {
	.ws_row = 25,
	.ws_col = 80
};

struct pty *ptys[MAX_TERMS];
struct pty *current_pty = NULL;
int keyfd;

struct pty *create_pty(struct termios *term, struct winsize *win)
{
	assert(term);
	assert(win);
	struct pty *p = calloc(1, sizeof(struct pty));
	memcpy(&p->term, term, sizeof(*term));
	memcpy(&p->win, win, sizeof(*win));
	p->cattr = DEF_ATTR;
	p->sp = LINES-25;
	p->cy = LINES-25;
	return p;
}

struct pty *spawn_terminal(char * const cmd[])
{
	struct pty *p = create_pty(&def_term, &def_win);
	clear(p);
	int pid = forkpty(&p->masterfd, NULL, &p->term, &p->win);
	if(!pid) {
		execvp(cmd[0], cmd);
	}
	for(int i=0;i<MAX_TERMS;i++) {
		if(!ptys[i]) {
			ptys[i] = p;
			break;
		}
	}
	return p;
}

void select_loop(void)
{
	while(true) {
		fd_set readers;
		FD_ZERO(&readers);
		int max = 0;
		for(int i=0;i<MAX_TERMS;i++) {
			if(ptys[i]) {
				FD_SET(ptys[i]->masterfd, &readers);
				if(ptys[i]->masterfd > max)
					max = ptys[i]->masterfd;
			}
		}
		FD_SET(keyfd, &readers);
		if(keyfd > max)
			max = keyfd;
		int r = select(max+1, &readers, NULL, NULL, NULL);
		if(r > 0) {
			for(int i=0;i<MAX_TERMS;i++) {
				if(ptys[i] && FD_ISSET(ptys[i]->masterfd, &readers)) {
					/* data available. */
					process_output(ptys[i]);
				}
			}
			if(FD_ISSET(keyfd, &readers)) {
				/* keyboard data available */
				read_keyboard();
			}
		}

	}
}

int main(int argc, char **argv)
{
	//daemon(0, 0);
	signal(SIGINT, SIG_IGN);
	signal(SIGTSTP, SIG_IGN);
	signal(SIGQUIT, SIG_IGN);
	memset(ptys, 0, sizeof(ptys));
	openlog("cond", 0, 0);
	keyfd = open("/dev/keyboard", O_RDWR | O_NONBLOCK);
	if(keyfd == -1) {
		syslog(LOG_ERR, "failed to open keyboard file: %s\n", strerror(errno));
		exit(1);
	}
	init_screen();
	char *login[] = { "bash", NULL };
	struct pty *init = spawn_terminal(login);
	if(!init) {
		syslog(LOG_ERR, "failed to start initial terminal\n");
		exit(1);
	}
	current_pty = init;
	select_loop();
}


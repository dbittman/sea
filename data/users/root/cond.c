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

#define BUFFER_SIZE 4096
#define MAX_TERMS 8

struct cell {
	uint8_t character;
	uint8_t attr;
};

struct pty {
	int masterfd;
	struct cell *buffer;
	int cx, cy;
	struct termios term;
	struct winsize win;
};

struct pty *ptys[MAX_TERMS];

struct pty *current_pty = NULL;

struct pty *create_pty(struct termios *term, struct winsize *win)
{
	assert(term);
	assert(win);
	struct pty *p = calloc(1, sizeof(struct pty));
	memcpy(&p->term, term, sizeof(*term));
	memcpy(&p->win, win, sizeof(*win));
	p->buffer = calloc(BUFFER_SIZE, sizeof(struct cell));
	return p;
}

struct pty *spawn_terminal(char * const cmd[])
{
	struct pty *p = create_pty(0, 0);
	int pid = forkpty(&p->masterfd, NULL, NULL, NULL);
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

int keyfd;

void process_output(struct pty *pty)
{

}

void keyboard_state_machine(unsigned char scancode)
{
	/* this will process the incoming scancodes, translate them to
	 * a character stream, and write them to the masterfd of the
	 * current pty. */
}

void read_keyboard(void)
{
	if(!current_pty)
		return;
	unsigned char data[16];
	int amount;
	if((amount=read(keyfd, data, 16)) > 0) {
		for(int i=0;i<amount;i++)
			keyboard_state_machine(data[i]);
	}
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

		int r = select(max, &readers, NULL, NULL, NULL);
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
	daemon(0, 0);
	memset(ptys, 0, sizeof(ptys));
	openlog("cond", 0, 0);
	keyfd = open("/dev/keyboard", O_RDWR | O_NONBLOCK);
	if(keyfd == -1) {
		syslog(LOG_ERR, "failed to open keyboard file: %s\n", strerror(errno));
		exit(1);
	}
	char *login[] = { "login", NULL };
	struct pty *init = spawn_terminal(login);
	if(!init) {
		syslog(LOG_ERR, "failed to start initial terminal\n");
		exit(1);
	}
	current_pty = init;
	select_loop();
}


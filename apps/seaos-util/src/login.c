/* 
 * Copyright (C) 2012  Daniel Bittman

 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.

 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.

 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>
 */
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <pwd.h>
#include <time.h>
#include <string.h>
#include <signal.h>
#include <sys/utsname.h>
#include <libgen.h>
#include <errno.h>
char out_tty=0;
int pid;
char *name;
int check_password(char *);
char def_shell[8] = "/bin/sh";
void sigint_h(int g)
{
	/* LOL LOL LOL */
}

int main(int argc, char **argv)
{
	name = basename(argv[0]);
	/* First do some checks */
	unsigned myuid = geteuid();
	if(myuid)
	{
		fprintf(stderr, "%s: login being executed with EUID > 0!\n", argv[0]);
		return -1;
	}
	FILE *f = fopen("/etc/passwd", "r");
	if(!f)
	{
		fprintf(stderr, "%s: unable to read user listing.\n", argv[0]);
		return -2;
	}
	fclose(f);
	if(isatty(1))
		out_tty=1;
	setbuf(stdout, NULL);
	waitpid(pid, 0, 0);
	signal(SIGINT, sigint_h);
	signal(SIGTSTP, sigint_h);
	signal(SIGQUIT, sigint_h);
	struct utsname name;
	uname(&name);
	/* Main loop */
	while(1)
	{
		printf("\nSeaOS kernel version %s (tty%d)\nor: How I learned to stop worrying and love my computer.\n\n", name.release, ioctl(0, 8, 0));
		char username[128];
		memset(username, 0, 128);
		printf("Login: ");
		while(!read(0, username, 127))
			;
		char *nl = strchr(username, '\n');
		if(nl) *nl=0;
		struct passwd *pwd = getpwnam(username);
		if(!pwd)
		{
			printf("Invalid Login\n");
			continue;
		}
		
		/* Check password */
		if(!check_password(username))
		{
			printf("Invalid Login\n");
			continue;
		}
		
		/* Okay, login the user */
		pid = fork();
		if(pid) {
			int status;
			int ret;
			while((ret = waitpid(-1,&status,0)) <= 0) {
				if(ret == -ECHILD)
					fprintf(stderr, "login: no child process\n");
			}
			ioctl(1, 0, 0);
		} else {
			set_uid(pwd->pw_uid);
			char *shell = pwd->pw_shell;
			if(!*shell)
				shell = def_shell;
			chdir(pwd->pw_dir);
			time_t now;
			time(&now);
			printf("Logged in as '%s'\n", username);
			execl(shell, shell, "--login", 0);
			if(shell != def_shell) 
			{
				shell = def_shell;
				fprintf(stderr, "%s: failed to start user's shell. Falling back to default...\n", name);
				execl(shell, shell, "-l", 0);
			}
			fprintf(stderr, "%s: could not start a login shell.\n", name);
			exit(1);
		}
	}
}

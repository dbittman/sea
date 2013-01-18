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
#include <sys/stat.h>
#include <fcntl.h>
#include <time.h>
#include <sys/time.h>
#include <string.h>
int my_tty;
#define MAX_PIDS 100000
char only_running=0;
char all=0;
char without_tty=0;
char loop=0;
char proc_count=0;
char full=0;
char *states[] = {"Dead   ", "Running", "ISleep ", "USleep ", "Frozen ", "Suicidal"};
char *level[] = {"S", "M", "H"};
int lines=0;
char pids[MAX_PIDS];
int display_task(struct task_stat *stat)
{
	if(stat->state && only_running)
		return 0;
	if(stat->tty != my_tty && !(all || without_tty))
		return 0;
	if(!without_tty && stat->tty==0)
		return 0;
	if(stat->tty)
		printf("%6d tty%-2d\t", stat->pid, stat->tty);
	else
		printf("%6d ?    \t", stat->pid);
	if(!full) {
		int seconds = (stat->utime + stat->stime)/get_timer_ticks_hz();
		int minutes = seconds / 60;
		int hours = minutes/60;
		printf("%2.2d:%2.2d:%2.2d", hours, minutes % 60, seconds % 60);
	} else {
		
		printf("%4d %4d ", stat->uid, stat->gid);
		float tmp = (stat->utime)/((float)get_timer_ticks_hz());
		int lev=0;
		while(tmp > 100.0)
			tmp = tmp / 60.0, lev++;
		printf("%6.2f%s ", tmp, level[lev]); 
		tmp = (stat->stime)/((float)get_timer_ticks_hz());
		lev=0;
		while(tmp > 100.0)
			tmp = tmp / 60.0, lev++;
		printf("%6.2f%s ", tmp, level[lev]); 
		int kb = stat->mem_usage/0x1000;
		int mb = kb / 1024;
		if(mb)
			printf("%6.2fMB", kb/1024.0);
		else
			printf("%6dKB", kb);
		
	}
	printf(" ");
	if(!full)
		printf("%s", stat->cmd);
	else
	{
		printf("%s ",  states[stat->state+1]);
		if(stat->cmd)
			printf("%s", stat->cmd);
	}
	
	printf("\n");
	fflush(0);
}

int main(int argc, char **argv)
{
	memset(pids, 0, MAX_PIDS * sizeof(char));
	int i;
	for(i=1;i<argc;i++)
	{
		if(argv[i][0] == '-')
		{
			int q=1;
			again1:
			switch(argv[i][q])
			{
				case 'A':
					all=without_tty=1;
					break;
				case 'f':
					full=1;
					break;
				case 'L':
					loop=1;
					break;
			}
			if(argv[i][++q])
				goto again1;
		} else {
			int w=0;
			again2:
			switch(argv[i][w])
			{
				case 'x':
					without_tty=1;
					break;
				case 'a':
					all=1;
					break;
				case 'r':
					only_running=1;
					break;
				case 'P':
					proc_count=1;
					break;
			}
			if(argv[i][++w])
				goto again2;
		}
	}
	int tmp = open("/dev/tty", O_RDWR);
	if(tmp < 0)
	{
		fprintf(stderr, "%s: couldn't open controlling terminal\n", basename(argv[0]));
		exit(1);
	}
	ioctl(tmp, 8, (int)&my_tty);
	close(tmp);
	struct task_stat s;
	if(!full && !proc_count)
		printf("   PID TTY\t    TIME CMD\n");
	else if(!proc_count)
		printf("   PID TTY\t UID  GID   UTIME   STIME      MEM STATE   CMD\n");
	i=0;
	int pc=0;
	int pcr=0;
	while(!task_stat(i, &s))
	{
		if(s.pid >= MAX_PIDS)
		{i++; continue;}
		if(pids[s.pid])
		{i++; continue;}
		pids[s.pid]++;
		if(!proc_count)
			display_task(&s);
		else
			s.state ? pc++ : pcr++;
		i++;
	}
	if(proc_count)
		printf("%d processes (%d running)\n", pc+pcr, pcr);
	fflush(0);
	return 0;
}

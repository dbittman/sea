/* 
 * Copyright (C) 2015  Daniel Bittman

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
#include <libgen.h>
#include <getopt.h>
#include <sys/dir.h>
#include <errno.h>
#include <unistd.h>
#include <ctype.h>
int all = 0;
int threads = 0;
#define TTYMODE_ALL 1
int ttymode = 0;
int format = 0;

#define PROCSDIR "/dev/process"
const char *progname;
int ourpid=0;
int ourtty=-1;

size_t read_field(const char *path, const char *field, int len, char *buf)
{
	char fullpath[strlen(path) + strlen(field) + 2];
	memset(buf, 0, len);
	sprintf(fullpath, "%s/%s", path, field);
	FILE *file = fopen(fullpath, "r");
	if(!file)
		return 0;
	size_t ret = fread(buf, 1, len, file);
	if(ferror(file)) {
		fprintf(stderr, "%s: failed to read process field '%s': %s\n", progname, field, strerror(errno));
		fclose(file);
		return 0;
	}
	if(ret == 0) {
		fprintf(stderr, "%s: failed to read process field '%s': no data\n", progname, field);
		fclose(file);
		return 0;
	}
	fclose(file);	
	return ret;
}

int print_threads_states(int pid)
{
	int tc = 0;
	char ppath[128];
	sprintf(ppath, "%s/%d", PROCSDIR, pid);
	DIR *dir = opendir(ppath);
	struct dirent *ent;
	while((ent = readdir(dir))) {
		if(ent->d_name[0] == '.')
			continue;
		if(!isdigit(ent->d_name[0]))
			continue;
		char tpath[256];
		sprintf(tpath, "%s/%s", ppath, ent->d_name);
		
		char statestr[8];
		if(!read_field(tpath, "state", 8, statestr))
			statestr[0] = '?';

		printf("%c", statestr[0]);
		tc++;
	}
	closedir(dir);
	return tc;
}

void print_process(int pid)
{
	char utimestr[32];
	char stimestr[32];
	char tcstr[32];
	char ttystr[64];
	char cmdstr[128];
	char path[256];
	char uidstr[16];
	char flagsstr[8];
	snprintf(path, 256, "%s/%d", PROCSDIR, pid);

	int ret;
	if(!read_field(path, "stime", 32, stimestr))
		return;
	if(!read_field(path, "utime", 32, utimestr))
		return;
	if(!read_field(path, "command", 128, cmdstr))
		return;
	int hastty = read_field(path, "tty", 64, ttystr);
	if(!read_field(path, "real_uid", 16, uidstr))
		return;
	if(!read_field(path, "flags", 8, flagsstr))
		return;
	if(!read_field(path, "thread_count", 32, tcstr))
		return;

	/* these are in microseconds */
	long utime_ms = strtol(utimestr, 0, 10);
	long stime_ms = strtol(stimestr, 0, 10);
	int tty = strtol(ttystr, 0, 10);

	if(!all && ttymode != TTYMODE_ALL && tty != ourtty) {
		return;
	}

	/* now milliseconds */
	utime_ms /= 1000;
	stime_ms /= 1000;

	float utime = utime_ms / 1000.0;
	float stime = stime_ms / 1000.0;

	char utime_unit = 'S';
	if(utime > 60) {
		utime_unit = 'M';
		utime /= 60.0;
	}

	char stime_unit = 'S';
	if(stime > 60) {
		stime_unit = 'M';
		stime /= 60.0;
	}

	if(utime > 60) {
		utime_unit = 'H';
		utime /= 60.0;
	}

	if(stime > 60) {
		stime_unit = 'H';
		stime /= 60.0;
	}
	if(format) {
		printf("%4s %5d %3s %5s %5.2f%c %5.2f%c", 
				uidstr, pid, hastty ? ttystr : "-", flagsstr, 
				utime, utime_unit, stime, stime_unit);
	} else {
		printf("%5d %3s %5.2f%c %5.2f%c", pid, hastty ? ttystr : "-", utime, utime_unit, stime, stime_unit);
	}

	if(threads) {
		printf(" %6s ", tcstr);
		int c = print_threads_states(pid);
		printf("%*s", (14-c), " ");
	}

	printf(" %s\n", cmdstr);
}

void enumerate_processes(void)
{
	DIR *procsdir = opendir(PROCSDIR);
	struct dirent *ent;

	if(format)
		printf(" UID   PID TTY FLAGS  UTIME  STIME ");
	else
		printf("  PID TTY  UTIME  STIME ");

	if(threads)
		printf("TCOUNT TSTATES        ");
	printf("CMD\n");

	while((ent = readdir(procsdir))) {
		if(ent->d_name[0] == '.')
			continue;
		char *endptr;
		int pid = strtol(ent->d_name, &endptr, 10);
		if(endptr != ent->d_name) {
			print_process(pid);
		}
	}
}

int main(int argc, char **argv)
{
	progname = argv[0];

	int c;
	while((c = getopt(argc, argv, "t:afT")) != -1) {
		switch(c) {
			case 't':
				ourtty = strtol(optarg, 0, 10);
				break;
			case 'a':
				all = 1;
				break;
			case 'f':
				format = 1;
				break;
			case 'T':
				threads = 1;
				break;
		}
	}
	/* get some stuff about us first... */
	ourpid = getpid();
	char tty[32];
	char us[256];
	sprintf(us, "%s/%d", PROCSDIR, ourpid);
	if(ourtty == -1) {
		if(!read_field(us, "tty", 32, tty))
			ourtty = 0;
		else
			ourtty = strtol(tty, 0, 10);
	}
	enumerate_processes();

	return 0;
}


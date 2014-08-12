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
#include <string.h>
#include <unistd.h>
#include <stdlib.h>
#include <machine/sea-syscall.h>

char *prog=0;
int usage()
{
	fprintf(stderr, "%s: usage: [-lrfh] [-p pid] [device]\n", prog);
	return 0;
}

int main(int argc, char **argv)
{
	prog = basename(argv[0]);
	int list=0, off=1, force=0;
	int i;
	int pid=0;
	opterr=0;
	while ((i=getopt(argc, argv, "lrfhp:")) != -1)
	{
		switch(i)
		{
			case 'l':
				list=1;
				break;
			case 'r':
				off=2;
				break;
			case 'f':
				force=1;
				break;
			case 'p':
				pid = atoi(optarg);
				break;
			case 'h':
			default:
				return usage();
			
		}
	}
	char *dev = argv[optind];
	
	if(list)
	{
		execl("/bin/cat", "/bin/cat", "/proc/swap");
		exit(0);
	}
	
	if(!dev && !pid) {
		if(!list)
			usage();
		return 0;
	}
	if(dev) {
		int ret;
		printf("%sing device %s to swap devices...\n", off == 2 ? "Remov" : "Add", dev);
		if(off)
			ret = syscall(61+off, (int)dev, (off == 2) ? force : 0, 0, 0, 0);
		printf("%s\n", ret == 0 ? "Success" : "Failed. Check kernel log for details.");
	}
	if(pid)
	{
		char err[5][64] = {
			"",
			"Not called as root",
			"Process does not exist",
			"Cannot swap a kernel task",
			"No swap devices"
		};
		printf("Preparing to swap task %d...", pid);fflush(0);
		int ret = syscall(96, pid, 0, 0, 0, 0);
		if(ret < 0)
			printf("Failed: %s\n", err[-ret]);
		else
			printf("Task will be swapped\n");
	}
	return 0;
}

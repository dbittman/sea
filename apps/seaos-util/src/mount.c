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
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <errno.h>
void display_help()
{
	printf("Mount - mount a device on to a directory\n");
	printf("Syntax: mount [-t type] device directory\n");
	printf("Switches:\n\t-t <type>: Specify filesystem type (e.g. 'ext2')\n");
	printf("Note: Not specifying -t will have the kernel try all types until one works\n");
}

int main(int argc, char **argv)
{
	/* Parse cmd line */
	int opt;
	char * type=0;
	if(argc == 1)
		execl("/bin/df", "df", "-h");
	while((opt = getopt(argc, argv, "ht:")) != -1) {
		switch(opt) {
			case 'h':
				display_help();
				return 0;
				break;
			case 't':
				type = optarg;
				break;
		}
	}
	if((optind + 2) > argc)
	{
		fprintf(stderr, "%s: usage: [-t type] device directory\n", argv[0]);
		return 1;
	}
	if(getuid())
	{
		fprintf(stderr, "%s: you must be root to use this program\n", argv[0]);
		return 2;
	}
	int ret = sea_mount_filesystem(argv[optind], argv[optind+1], type, 0, 0);
	if(ret < 0)
		fprintf(stderr, "%s: %s -> %s: %s\n", (char *)basename(argv[0]), argv[optind], argv[optind+1], strerror(errno));
	
	return ret;
}

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
#include <errno.h>
char *progname;
void usage()
{
	fprintf(stderr, "%s: usage: ioctl device command argument\n", progname);
}

int main(int argc, char **argv)
{
	progname = (char *)basename(argv[0]);
	int cmd=0;
	int arg=0;
	FILE *f;
	if(argc != 4) {
		usage();
		return 1;
	}
	f = fopen(argv[1], "rw");
	cmd = atoi(argv[2]);
	/* -[arg] is interpreted as a string */
	if(argv[3][0] == '-')
		arg = (int)argv[3]+1;
	else
		arg = atoi(argv[3]);
	if(!f)
	{
		fprintf(stderr, "%s: %s: %s\n", progname, argv[1], strerror(errno));
		return 2;
	}
	return ioctl(fileno(f), cmd, arg);
}

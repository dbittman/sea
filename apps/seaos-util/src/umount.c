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
#include <stdio.h>
#include <unistd.h>
#include <errno.h>

int main(int argc, char **argv)
{
	int force=0;
	if(argc < 2) {
		fprintf(stderr, "%s: usage: umount [-f] directory\n", argv[0]);
		return 1;
	}
	if(getuid())
	{
		fprintf(stderr, "%s: you must be root to use this program\n", argv[0]);
		return 2;
	}
	if(!strcmp(argv[1], "-f"))
		force=1;
	int ret = sea_umount_filesystem((char *)(argv[force ? 2 : 1]), force);
	if(ret < 0)
		fprintf(stderr, "%s: %s: %s\n", (char *)basename(argv[0]), argv[force ? 2 : 1], strerror(errno));
	return ret ? 1 : 0;
}

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
#include <stdlib.h>
#include <sys/stat.h>
#include <pwd.h>
#include <errno.h>
#include <unistd.h>
extern char **environ;
int reset=0;

int main(int argc, char **argv)
{
	int i;
	int pid=0;
	if(get_uid()) {
		fprintf(stderr, "%s: you must be root to use this program!\n", argv[0]);
		return 1;
	}
	for(i=0;i<argc;i++)
	{
		if(!strcmp(argv[i], "-r"))
			reset=1;
	}
	system("sh /etc/rc/shutdown");
	if(reset) 
		kernel_reset();
	else
		kernel_shutdown();
	return 0;
}

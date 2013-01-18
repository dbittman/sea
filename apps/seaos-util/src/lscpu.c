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
#include <sys/stat.h>
#include <sys/dirent.h>
#include <errno.h>
int main(int argc, char **argv)
{
	int i=0;
	DIR *d = opendir("/proc/cpu");
	if(!d)
	{
		fprintf(stderr, "%s: %s: %s\n", basename(argv[0]), "/proc/cpu", strerror(errno));
		return 1;
	}
	struct dirent *de;
	while((de = readdir(d))) {
		char path[128];
		sprintf(path, "/proc/cpu/%s", de->d_name);
		int pid;
		if(!(pid=fork()))
			execl("/bin/cat", "/bin/cat", path);
		waitpid(pid, 0, 0);
		i++;
	}
	closedir(d);
	return 0;
}

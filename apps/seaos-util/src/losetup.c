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
#include <errno.h>
#include <string.h>
#include <unistd.h>
#include <sys/stat.h>
#include <stdlib.h>
#include <assert.h>

void usage()
{
	fprintf(stderr, "usage: losetup [-r] [-c | -x | -d] [-o offset] [-s size] loop_device [file | loop_num]\n");
}

int main(int argc, char **argv)
{
	char *progname = (char *)basename(argv[0]);
	int dis=0, ro=0, create=0, remove=0;
	int opt;
	char *file=0;
	unsigned size=0, off=0;
	while((opt = getopt(argc, argv, "cxrdo:s:")) != -1) {
		switch(opt) {
			case 'd':
				dis=1;
				break;
			case 'r':
				ro=1;
				break;
			case 'o':
				off = atoi(optarg);
				break;
			case 's':
				size = atoi(optarg);
				break;
			case 'c':
				create=1;
				break;
			case 'x':
				remove=1;
				break;
		}
	}
	char *loop = argv[optind];
	if(!loop) {
		usage();
		return 1;
	}
	if(!dis && !remove) {
		file = argv[optind+1];
		if(!file) {
			usage();
			return 1;
		}
	}
	FILE *f = fopen(loop, "rw");
	if(!f && !create)
	{
		fprintf(stderr, "%s: could not open loop device '%s': %s\n", progname, argv[optind], strerror(errno));
		return 2;
	}
	int ret=0;
	if(create) {
		if(!f) {
			f = fopen("/dev/loop0", "r");
			if(!f) {
				fprintf(stderr, "%s: could not open loop device '%s': %s\n", progname, "/dev/loop0", strerror(errno));
				return 2;
			}
			int rret = ioctl(fileno(f), 7, atoi(file));
			if(rret < 0) {
				fprintf(stderr, "%s: could not create loop device '%s': %s\n", progname, loop, strerror(errno));
			}
			fclose(f);
		} else
		{
			fprintf(stderr, "%s: could not create loop device '%s': file exists\n", progname, loop);
			return 2;
		}
	} else if(remove) {
		ret = ioctl(fileno(f), 5, 0);
	} else if(dis) {
		ret = ioctl(fileno(f), 1, 0);
	} else {
		ret = ioctl(fileno(f), 0, (int)file);
		if(ret) goto errors;
		if(ro) {
			if(ioctl(fileno(f), 6, 1)) {
				fprintf(stderr, "%s: could not set loop device '%s' as read only: %s\n", progname, loop, strerror(errno));
				ret=4;
			}
		}
		if(size) {
			if(ioctl(fileno(f), 3, size)) {
				fprintf(stderr, "%s: could not set size on loop device '%s': %s\n", progname, loop, strerror(errno));
				ret=5;
			}
		}
		if(off) {
			if(ioctl(fileno(f), 2, off)) {
				fprintf(stderr, "%s: could not set offset on loop device '%s': %s\n", progname, loop, strerror(errno));
				ret=6;
			}
		}
	}
	errors:
	if(ret == -1)
	{
		switch(errno)
		{
			case EINVAL:
				fprintf(stderr, "%s: Invalid loop device '%s'\n", progname, argv[optind]);
				break;
			case EEXIST:
				fprintf(stderr, "%s: Loop device '%s' is busy\n", progname, argv[optind]);
				break;
			default:
				fprintf(stderr, "%s: %s: %s\n", progname, argv[optind+1], strerror(errno));
				break;
		}
	}
	return ret < 0 ? 3 : ret;
}

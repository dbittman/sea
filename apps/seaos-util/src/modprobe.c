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
#include <assert.h>
#include <string.h>
#include <errno.h>
#include <sys/stat.h>
#include <libgen.h>
#include <sys/utsname.h>
#include <sys/seaos.h>
#include <ctype.h>
char *prog=0;
char *directory=0; /* directory to look for modules in */

#define DEPEND_FILE "modules.deps"

char *get_default_dir()
{
	struct utsname u;
	uname(&u);
	
	char *dir = malloc(128);
	sprintf(dir, "/sys/modules-%s", u.release);
	return dir;
}

char *get_module_path(char *name)
{
	if(strchr(name, '/'))
		return strdup(name);
	char *path = malloc(strlen(name) + strlen(directory) + 2);
	sprintf(path, "%s/%s", directory, name);
	return path;
}

char *skip_space(char *s)
{
	if(!s) return 0;
	while(*s && isspace(*s))
		s++;
	return *s ? s : 0;
}

int check_module_exists(char *name)
{
	return sea_load_module(name, 0, SEA_MODULE_CHECK);
}

int check_depend(char *name)
{
	char depend_file[strlen(directory) + 1 + strlen(DEPEND_FILE) + 1];
	memset(depend_file, 0, strlen(directory) + 1 + strlen(DEPEND_FILE) + 1);
	strcpy(depend_file, directory);
	strcat(depend_file, "/");
	strcat(depend_file, DEPEND_FILE);
	
	FILE *f = fopen(depend_file, "r");
	if(!f)
		return 1;
	/* find line for this module */
	char buffer[1024];
	while(fgets(buffer, 1024, f)) {
		char *nl = strchr(buffer, '\n');
		if(nl) *nl=0;
		char *col = strchr(buffer, ':');
		if(!col) {
			fprintf(stderr, "%s: depend file syntax error\n", prog);
		} else {
			*col = 0;
			if(!strcmp(name, buffer)) {
				char *list = col+1;
				while((list = skip_space(list))) {
					char *del = strchr(list, ' ');
					if(del) *del = 0;
					if(!check_module_exists(list))
						return 0;
					if(del)
					{
						*del=' ';
						list = del+1;
					} else
						list=0;
				}
			}
		}
	}
	return 1;
}

int load(char *name, char *args, int force)
{
	if(!force && !check_depend(name))
		return -EINVAL;
	char *path = get_module_path(name);
	int r = sea_load_module(path, args, force ? SEA_MODULE_FORCE : 0);
	free(path);
	return r;
}

int unload(char *name, int force)
{
	return sea_unload_module(name, force ? SEA_MODULE_FORCE : 0);
}

void usage()
{
	fprintf(stderr, "%s: usage: [-qvfp] [-r | -e | -l] module [args]\n", prog);
}

int main(int argc, char **argv)
{
	char check_exist=0, quiet=0, remove=0, verbose=0, force=0, list=0;
	prog = basename(argv[0]);
	opterr = 0;
	int c;
	while((c = getopt(argc, argv, "d:efqrvl")) != -1)
	{
		switch(c) {
			case 'd':
				directory = optarg;
				break;
			case 'e':
				check_exist = 1;
			case 'f':
				force = 1;
				break;
			case 'q':
				quiet = 1;
				break;
			case 'r':
				remove = 1;
				break;
			case 'v':
				verbose = 1;
				break;
			case 'l':
				list=1;
				break;
			default:
				usage();
				exit(1);
		}
	}
	if(list) {
		execl("/bin/cat", "/bin/cat", "/proc/modules");
		return 1;
	}
	if(get_uid() && !check_exist) {
		fprintf(stderr, "%s: you must be root to use this program!\n", prog);
		return 1;
	}
	if(remove && check_exist)
	{
		usage();
		exit(1);
	}
	if(!directory) directory = get_default_dir();
	struct stat st;
	if(stat(directory, &st) == -1) {
		if(!quiet) fprintf(stderr, "%s: could not stat module directory %s: %s\n", prog, directory, strerror(errno));
		exit(2);
	}
	char *args=0;
	char *module = argv[optind];
	if(optind+1 < argc)
		args = argv[optind+1];
	if(!module)
	{
		usage();
		exit(1);
	}
	if(verbose && !check_exist && !remove)
		printf("%snsert%s module %s...\n", 
				force ? "Forcing i" : "I",
				force ? "ion of" : "ing",
				module);
	if(remove && verbose)
		printf("Removing module %s...\n", module);
	int ret=0;
	if(remove)
		ret = unload(module, force);
	else if(check_exist)
		ret = check_module_exists(module);
	else
		ret = load(module, args, force);
	if(ret == -1) ret = -errno;
	if(verbose && check_exist && ret)
		printf("Module %s is inserted\n", module);
	
	if(ret && !quiet && !check_exist) {
		if(remove && ret < 0)
			fprintf(stderr, "%s: could not remove module %s: %s\n", 
				prog, module, 
				ret == -EINVAL ? "modules depend on it" : "not loaded");
		if(remove && ret > 0)
			fprintf(stderr, "%s: module %s exit routine returned code %d\n", prog, module, ret);
		if(!remove && ret < 0)
			fprintf(stderr, "%s: could not insert module %s: %s\n", prog, module, strerror(-ret));
		if(!remove && ret > 0)
			fprintf(stderr, "%s: module %s init routine returned code %d\n", prog, module, ret);
	}
	if(check_exist)
		return ret ? 0 : 1;
	
	if(ret < 0) return 4;
	if(ret > 0) return 5;
	return 0;
}

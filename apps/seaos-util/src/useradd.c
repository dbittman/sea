/* add an entry to /etc/passwd and create a home directory */

#include <unistd.h>
#include <libgen.h>
#include <string.h>
#include <errno.h>
#include <pwd.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>
char *prog=0;

int check_uid_available(int u)
{
	if(getpwuid(u))
		return 0;
	return 1;
}

int find_available_uid()
{
	int i;
	for(i=1000; i>0; i--)
	{
		if(check_uid_available(i))
			break;
	}
	return i;
}

void usage(int err)
{
	fprintf(stderr, "%s: usage: [OPTIONS] login\n\n", prog);
	fprintf(stderr, "Options:\n");
	fprintf(stderr, "  -c comment\n  -d home_directory\n  -g group_id\n  -G groups\n");
	fprintf(stderr, "  -h\n  -M\n  -p password\n  -s shell\n  -u user_id\n\n");
	exit(err);
}

int main(int argc, char **argv)
{
	prog = (char *)basename(argv[0]);
	opterr = 0;
	int o;
	char *comment = "user", *home=0, *group_id="1000", *groups="", *password="x", *shell = "/bin/sh", *user_id=0;
	int uid = 0;
	int no_create_home=0;
	while((o=getopt(argc, argv, "c:d:g:G:Mp:s:u:h")) != -1) {
		switch(o) {
			case 'c':
				comment = optarg;
				break;
			case 'd':
				home = optarg;
				break;
			case 'g':
				group_id = optarg;
				break;
			case 'G':
				groups = optarg;
				break;
			case 'M':
				no_create_home = 1;
				break;
			case 'p':
				password = optarg;
				break;
			case 's':
				shell = optarg;
				break;
			case 'h':
				usage(0);
			case 'u':
				user_id = optarg;
				break;
			default:
				usage(1);
		}
	}
	if(get_uid()) {
		fprintf(stderr, "%s: you must be root to use this program\n", prog);
		return 1;
	}
	if(optind >= argc)
		usage(1);
	char *login = argv[optind];
	if(!login) usage(1);
	if(strchr(login, '/')) {
		fprintf(stderr, "%s: invalid login name\n", prog);
		return 2;
	}
	/* for some options, we now apply the defualts if they werent set */
	if(!home)
	{
		int len = sizeof(char)*strlen(login) + sizeof(char)*strlen("/users/") + sizeof(char);
		home = malloc(len);
		sprintf(home, "/users/%s", login);
	}
	if(!user_id)
		uid = find_available_uid();
	else
		uid = atoi(user_id);
	int gid = atoi(group_id);
	if(!gid) {
		fprintf(stderr, "%s: gid %d is unavailable (or invalid gid)\n", prog, uid);
		free(home);
		return 2;
	}
	if(!uid || !check_uid_available(uid)) {
		fprintf(stderr, "%s: uid %d is unavailable (or invalid uid)\n", prog, uid);
		free(home);
		return 2;
	}
	if(getpwnam(login)) {
		fprintf(stderr, "%s: login '%s' is unavailable\n", prog, login);
		free(home);
		return 2;
	}
	FILE *p = fopen("/etc/passwd", "r+");
	if(!p) {
		fprintf(stderr, "%s: /etc/passwd: %s\n", prog, strerror(errno));
		free(home);
		return 3;
	}
	if(fseek(p, 0, SEEK_END)) {
		fprintf(stderr, "%s: couldn't seek in file /etc/passwd: %s\n", prog, strerror(errno));
		free(home);
		fclose(p);
		return 3;
	}
	if(fprintf(p, "%s:%s:%d:%s:%s:%s:%s\n", login, password, uid, group_id, comment, home, shell) <= 0) {
		fprintf(stderr, "%s: couldn't write to /etc/passwd: %s\n", prog, strerror(errno));
		free(home);
		fclose(p);
		return 4;
	}
	if(!no_create_home) {
		if(mkdir(home, 0755) && errno != EEXIST) {
			fprintf(stderr, "%s: couldn't create '%s': %s\n", prog, home, strerror(errno));
			free(home);
			fclose(p);
			return 5;
		}
		if(chown(home, uid, gid)) {
			fprintf(stderr, "%s: couldn't change owner of '%s': %s\n", prog, home, strerror(errno));
			free(home);
			fclose(p);
			return 5;
		}
	}
	free(home);
	fclose(p);
	return 0;
}

#include <stdio.h>
#include <stdlib.h>
#include <pwd.h>
#include <string.h>
#include <errno.h>
#include <libgen.h>
#include <unistd.h>

char *prog = 0;

void usage(int e)
{
	fprintf(stderr, "%s: usage: [-fh] login\n  -f  don't ask for old password if root\n  -h  display this message\n\n", prog);
	exit(e);
}

int main(int argc, char **argv)
{
	prog = basename(argv[0]);
	opterr = 0;
	int c;
	char force=0;
	while((c=getopt(argc, argv, "fh")) != -1) {
		switch(c) {
			case 'h':
				usage(0);
				break;
			case 'f':
				force = 1;
				break;
			default:
				usage(1);
		}
	}
	/* first, get the login name */
	char *login=0;
	struct passwd *p;
	int my_uid = get_uid();
	if(optind >= argc)
	{
		p = getpwuid(my_uid);
		if(!p)
		{
			fprintf(stderr, "%s: could not determine login name for uid %d\n", prog, my_uid);
			return 2;
		}
		login = strdup(p->pw_name);
	} else
		login = strdup(argv[optind]);
	if(!(p=getpwnam(login))) {
		fprintf(stderr, "%s: user %s is not present on this system\n", prog, login);
		return 2;
	}
	if(my_uid && my_uid != p->pw_uid) 
	{
		fprintf(stderr, "%s: non-root user may only change their own password\n", prog);
		return 3;
	}
	if(!force || my_uid)
	{
		if(!check_password2("Old password: ", login))
		{
			fprintf(stderr, "%s: invalid password\n", prog);
			return 3;
		}
	}
	
	char new[64];
	printf("New password: ");
	fflush(0);
	ioctl(1, 1, 0);
	if(fgets(new, 63, stdin) < 0)
	{
		ioctl(1, 1, 15);
		fprintf(stderr, "%s: stdin: %s\n", prog, strerror(errno));
		return 4;
	}
	ioctl(1, 1, 15);
	char *nl = strchr(new, '\n');
	if(nl) *nl=0;
	
	char new2[64];
	printf("Confirm new password: ");
	fflush(0);
	ioctl(1, 1, 0);
	if(fgets(new2, 63, stdin) < 0)
	{
		ioctl(1, 1, 15);
		fprintf(stderr, "%s: stdin: %s\n", prog, strerror(errno));
		return 4;
	}
	ioctl(1, 1, 15);
	nl = strchr(new2, '\n');
	if(nl) *nl=0;
	if(strcmp(new, new2)) {
		fprintf(stderr, "%s: passwords don't match\n", prog);
		return 4;
	}
	
	char fp[strlen(login) + strlen("/users/") + strlen("/.passwd") + 1];
	sprintf(fp, "/users/%s/.passwd", login);
	if(!new[0]) {
		if(unlink(fp) && errno != ENOENT) {
			fprintf(stderr, "%s: /users/%s/.passwd: %s\n", prog, login, strerror(errno));
			return 5;
		}
	} else {
		FILE *f = fopen(fp, "w");
		if(!f) {
			fprintf(stderr, "%s: /users/%s/.passwd: %s\n", prog, login, strerror(errno));
			return 5;
		}
		fprintf(f, "%s", new);
		fclose(f);
		if(chown(fp, p->pw_uid, p->pw_gid))
			fprintf(stderr, "%s: could not change owner of /users/%s/.passwd: %s\n", prog, login, strerror(errno));
		if(chmod(fp, 0600))
			fprintf(stderr, "%s: could not change permissions of /users/%s/.passwd: %s\n", prog, login, strerror(errno));
	}
	return 0;
}

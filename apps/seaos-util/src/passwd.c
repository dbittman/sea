#include <stdio.h>
#include <stdlib.h>
#include <pwd.h>
#include <string.h>
#include <errno.h>
#include <libgen.h>
#include <unistd.h>
#include <openssl/sha.h>
#include <time.h>

char *prog = 0;

void get_secure_salt(unsigned char *salt, int length);
void generate_hash(unsigned char *hash, unsigned char *salt, unsigned char *password, int salt_length);
int verify_password(char *login, char *given_password);

void usage(int e)
{
	fprintf(stderr, "%s: usage: [-fh] login\n  -f  don't ask for old password if root\n  -h  display this message\n\n", prog);
	exit(e);
}

void err_exit(char *msg) {
	fprintf(stderr, "%s: %s: %s\n", prog, msg, strerror(errno));
	exit(1);
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
		free(login);
		return 2;
	}
	if(my_uid && my_uid != p->pw_uid) 
	{
		fprintf(stderr, "%s: non-root user may only change their own password\n", prog);
		free(login);
		return 3;
	}
	if(!force || my_uid)
	{
		if(!check_password2("Old password: ", login))
		{
			fprintf(stderr, "%s: invalid password\n", prog);
			free(login);
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
		free(login);
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
		free(login);
		return 4;
	}
	ioctl(1, 1, 15);
	nl = strchr(new2, '\n');
	if(nl) *nl=0;
	if(strcmp(new, new2)) {
		fprintf(stderr, "%s: passwords don't match\n", prog);
		free(login);
		return 4;
	}
	
	unsigned char salt[SHA512_DIGEST_LENGTH];
	unsigned char hash[SHA512_DIGEST_LENGTH];
	get_secure_salt(salt, SHA512_DIGEST_LENGTH);
	
	generate_hash(hash, salt, new, SHA512_DIGEST_LENGTH);
	
	FILE *shadow_old = fopen("/etc/shadow", "r");
	if(!shadow_old && errno != ENOENT) {
		fprintf(stderr, "%s: cannot open /etc/shadow, but the file may exist! (%s)\n", prog, strerror(errno));
		exit(1);
	}
	FILE *shadow_new = fopen("/etc/shadow.new", "w");
	if(!shadow_new) {
		fprintf(stderr, "%s: could not open /etc/shadow.new: %s\n", prog, strerror(errno));
		exit(1);
	}
	
	if(fchmod(fileno(shadow_new), 0600) == -1)
	{
		fprintf(stderr, "%s: could not change permissions of /etc/shadow.new: %s\n", prog, strerror(errno));
		exit(1);
	}
	
	if(shadow_old) {
		unsigned char buffer[4096];
		memset(buffer, 0, 4096);
		while(fgets(buffer, 4095, shadow_old)) {
			char *tmp = strchr(buffer, ':');
			if(tmp) {
				*tmp = 0;
				if(strcmp(login, buffer)) {
					*tmp = ':';
					fputs(buffer, shadow_new);
				}
			}
		}

		fclose(shadow_old);
	}
	if(new[0]) {
		if(fprintf(shadow_new, "%s:$6$", login) < 0){
			err_exit("error writing /etc/shadow_new");
		}
		
		int j;
		for(j=0;j<SHA512_DIGEST_LENGTH;j++) {
			if(fprintf(shadow_new, "%02x", *(salt+j)) < 0){
				err_exit("error writing /etc/shadow_new");
			}
		}
		if(fputc('$', shadow_new) == EOF){
			err_exit("error writing /etc/shadow_new");
		}
		for(j=0;j<SHA512_DIGEST_LENGTH;j++) {
			if(fprintf(shadow_new, "%02x", *(hash+j)) < 0){
				err_exit("error writing /etc/shadow_new");
			}
		}
		
		if(fputc('\n', shadow_new) == EOF){
			err_exit("error writing /etc/shadow_new");
		}
	}
	free(login);
	fclose(shadow_new);
	
	if(shadow_old) {
		if(rename("/etc/shadow", "/etc/shadow.old") == -1) {
			err_exit("failed to rename /etc/shadow");
		}
	}
	
	if(rename("/etc/shadow.new", "/etc/shadow") == -1) {
		if(rename("/etc/shadow.old", "/etc/shadow") == -1) {
			err_exit("!! failed to restore /etc/shadow.old to /etc/shadow !!");
		}
		err_exit("failed to rename /etc/shadow.new");
	}
	
	return 0;
}

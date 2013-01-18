#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <pwd.h>
#include <time.h>
#include <string.h>
#include <signal.h>
#include <sys/stat.h>
int check_password(char *username)
{
	char fp[strlen(username) + strlen("/users/") + strlen("/.passwd") + 1];
	sprintf(fp, "/users/%s/.passwd", username);
	FILE *f = fopen(fp, "r");
	if(!f) return 1;
	struct stat st;
	stat(fp, &st);
	char ps[st.st_size+1];
	memset(ps, 0, st.st_size+1);
	if(fgets(ps, st.st_size+1, f) < 0) {
		fclose(f);
		return 1;
	}
	fclose(f);
	printf("%s", "Password: ");
	fflush(0);
	char ps_t[128];
	memset(ps_t, 0, 128);
	ioctl(1, 1, 0);
	read(0, ps_t, 128);
	ioctl(1, 1, 15);
	char *w = strchr(ps_t, '\n');
	if(w) *w=0;
	if(!strcmp(ps_t, ps))
		return 1;
	return 0;
}

int check_password2(char *prompt, char *username)
{
	char fp[strlen(username) + strlen("/users/") + strlen("/.passwd") + 1];
	sprintf(fp, "/users/%s/.passwd", username);
	FILE *f = fopen(fp, "r");
	if(!f) return 1;
	struct stat st;
	stat(fp, &st);
	char ps[st.st_size+1];
	memset(ps, 0, st.st_size+1);
	if(fgets(ps, st.st_size+1, f) < 0) {
		fclose(f);
		return 1;
	}
	fclose(f);
	printf("%s", prompt);
	fflush(0);
	char ps_t[128];
	memset(ps_t, 0, 128);
	ioctl(1, 1, 0);
	read(0, ps_t, 128);
	ioctl(1, 1, 15);
	char *w = strchr(ps_t, '\n');
	if(w) *w=0;
	if(!strcmp(ps_t, ps))
		return 1;
	return 0;
}

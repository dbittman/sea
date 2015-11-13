#include <syslog.h>
#include <sys/types.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>

FILE *open_log_out(void)
{
	if(access("/var/log", F_OK) == -1) {
		if(mkdir("/var/log", 0655) == -1)
			return NULL;
	}
	return fopen("/var/log/messages", "w");
}

int main(int argc, char **argv)
{
	FILE *log = fopen("/dev/syslog", "r");
	if(!log) {
		fprintf(stderr, "failed to open /dev/syslog file\n");
		exit(1);
	}

	FILE *out = open_log_out();
	if(out)
		setbuf(out, NULL);
	setbuf(stdout, NULL);
	
	char buffer[4096];
	char ident[32];
	int pri;
	while(true) {
		if(fgets(buffer, sizeof(buffer), log) > 0) {
			if(buffer[0] == '<') {
				char *logentry = &buffer[1];
				char *pristr = strtok(logentry, ":");
				char *ident = strtok(NULL, ">");
				char *message = strtok(NULL, "");
				printf("[%s]: %s", ident, message);
				if(out)
					fprintf(out, "[%s]: %s", ident, message);
			} else {
				printf("%s", buffer);
				if(out)
					fprintf(out, "%s", buffer);
			}
		}
	}
}


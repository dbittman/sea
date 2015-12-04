#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <syslog.h>
#include <dirent.h>
#include <sys/seaos.h>
#include <errno.h>
#include <stdbool.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/wait.h>

/* fall-back plan if we don't have a config file. */
void load_all_modules(void)
{
	syslog(LOG_WARNING, "falling back to LOAD EVERYTHING mode\n");
	DIR *d = opendir("/modules");
	if(!d) {
		syslog(LOG_ERR, "failed to find module directory\n");
		exit(1);
	}
	struct dirent *de;
	while((de = readdir(d)) != NULL) {
		if(de->d_name[0] == '.')
			continue;
		char path[PATH_MAX];
		sprintf(path, "/modules/%s", de->d_name);
		syslog(LOG_INFO, "loading module %s\n", path);
		sea_load_module(path, NULL, 0);
	}
}

void load_modules(void)
{
	/* try to read in a config file */
	FILE *mods = fopen("/modules-load", "r");
	if(!mods) {
		load_all_modules();
		return;
	}

	char mname[PATH_MAX];
	while(fgets(mname, sizeof(mname), mods) != NULL) {
		strtok(mname, "\n");
		if(mname[0] == '\n' || mname[0] == '#')
			continue;
		char path[PATH_MAX];
		sprintf(path, "/modules/%s", mname);
		syslog(LOG_INFO, "loading module %s\n", path);
		sea_load_module(path, NULL, 0);
	}

	fclose(mods);
}

int main(int argc, char **argv)
{
	openlog("init", 0, 0);
	
	load_modules();
	syslog(LOG_INFO, "mounting root device %s\n", argv[1]);
	if(mkdir("/sysroot", 0777) < 0) {
		syslog(LOG_ERR, "failed to create sysroot mount point: %s\n", strerror(errno));
		exit(1);
	}
	if(sea_mount_filesystem(argv[1], "/sysroot", NULL, 0, 0) < 0) {
		syslog(LOG_ERR, "failed to mount root filesystem: %s\n", strerror(errno));
		exit(1);
	}
	if(sea_mount_filesystem("/dev/null", "/sysroot/dev", "devfs", 0, 0) < 0) {
		syslog(LOG_ERR, "failed to mount dev filesystem: %s\n", strerror(errno));
		exit(1);
	}

	if(chroot("/sysroot") < 0) {
		syslog(LOG_ERR, "failed to chroot to new sysroot: %s\n", strerror(errno));
		exit(1);
	}

	if(!fork()) {
		execlp("cond", "cond", "-a", "login", "-1", "sh /etc/rc/boot", "-9", "syslogd", (char *)NULL);
	}
	while(true) {
		waitpid(-1, 0, 0);
	}
	return 0;
}


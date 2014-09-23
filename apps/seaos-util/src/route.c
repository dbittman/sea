#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <ctype.h>
#include <netinet/in.h>
#include <net/if.h>
#include <sys/socket.h>
#include <fcntl.h>
#include <sys/ioctls.h>
#include <string.h>

struct route {
	struct sockaddr_in dest, gate, mask;
	int flags;
};

int main(int argc, char **argv)
{
	if(argc < 5) {
		perror("invalid args");
	}
	const char *iface = argv[1];
	const char *dest = argv[2];
	const char *gateway = argv[3];
	const char *mask = argv[4];
	char devname[128];
	sprintf(devname, "/dev/%s", iface);
	int fd = open(devname, O_RDWR);
	if(fd < 0) {
		perror("open failed\n");
		exit(1);
	}

	
	struct route r;
	inet_aton(dest, &r.dest.sin_addr);
	inet_aton(gateway, &r.gate.sin_addr);
	inet_aton(mask, &r.mask.sin_addr);
	r.flags |= 4;
	if(strcmp(gateway, "0.0.0.0"))
		r.flags |= 8;

	ioctl(fd, SIOCADDRT, &r);
}


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
#include <getopt.h>

struct route {
	struct sockaddr_in dest, gate, mask;
	int flags;
};

void convert_mask(int slash, char *string)
{
	uint32_t mask = 0;
	int i = 32;
	while(slash--)
		mask |= (1 << (--i));
	sprintf(string, "%d.%d.%d.%d", (mask >> 24) & 0xFF, (mask >> 16) & 0xFF, (mask >> 8) & 0xFF, mask & 0xFF);
}

void print_routes()
{
	execlp("/bin/cat", "cat", "/proc/route");
}

void usage()
{
	fprintf(stderr, "route: SeaOS Routing Table Tool\n");
	fprintf(stderr, "usage: route -a [-d] -i <interface> -n <dest address> [-g <gateway>] [-m <gateway>]\n");
	fprintf(stderr, "       route -r -i <interface> -n <dest address>\n");
	fprintf(stderr, "       route\n");
	fprintf(stderr, "Invoking route without any options prints out the routing table.\n");
	fprintf(stderr, "options:\n");
	fprintf(stderr, "  -a: Add route\n");
	fprintf(stderr, "  -r: Remove route\n");
	fprintf(stderr, "  -i: Interface for the route\n");
	fprintf(stderr, "  -n: Route destination address (in the form of n.n.n.n/m)\n");
	fprintf(stderr, "  -g: Route gateway\n");
	fprintf(stderr, "  -m: Route netmask (optional, can also be specified in dest address)\n");
	fprintf(stderr, "  -d: Set 'default' flag for this route\n");
}

int main(int argc, char **argv)
{
	const char *iface = 0;
	const char *dest = 0;
	const char *gateway = 0;
	const char *mask = 0;
	int add = 0, remove = 0, def = 0;
	char tmp_mask[32];
	int c;
	while((c = getopt(argc, argv, "hdi:g:n:m:ar")) != -1) {
		switch(c) {
			case 'h':
				usage();
				exit(0);
				break;
			case 'd':
				def = 1;
				break;
			case 'i':
				iface = optarg;
				break;
			case 'g':
				gateway = optarg;
				break;
			case 'n':
				dest = optarg;
				break;
			case 'm':
				mask = optarg;
				break;
			case 'a':
				add = 1;
				break;
			case 'r':
				remove = 1;
				break;
			default:
				exit(1);
		}
	}
	
	if(!gateway)
		gateway = "0.0.0.0";
	if(add && def && !mask)
		mask = "0.0.0.0";

	if(add && remove) {
		fprintf(stderr, "route: what are you even trying to do?\n");
		exit(1);
	}

	if(add && (!iface || !dest)) {
		fprintf(stderr, "route: invalid route creation options\n");
		exit(1);
	}

	if(remove && (!dest || !iface)) {
		fprintf(stderr, "route: invalid route deletion options\n");
		exit(1);
	}
	
	if(!remove && !add) {
		print_routes();
		exit(0);
	}

	char *slash_mask = strchr(dest, '/');
	if(slash_mask)
		*(slash_mask++) = 0;

	if(!mask && !def && add) {
		/* no mask, derive it from dest */
		if(!slash_mask) {
			fprintf(stderr, "route: no netmask specified\n");
			exit(1);
		}
		mask = tmp_mask;
		convert_mask(strtol(slash_mask, 0, 10), tmp_mask);
	}

	char devname[128];
	sprintf(devname, "/dev/%s", iface);
	int fd = open(devname, O_RDWR);
	if(fd < 0) {
		perror("open failed\n");
		exit(1);
	}
	if(add) {
		/* okay, construct the route struct... */
		struct route r;
		r.dest.sin_family = AF_INET;
		r.gate.sin_family = AF_INET;
		r.mask.sin_family = AF_INET;
		inet_aton(dest, &r.dest.sin_addr);
		inet_aton(gateway, &r.gate.sin_addr);
		inet_aton(mask, &r.mask.sin_addr);
		r.flags |= 4; /* set route as up */
		if(strcmp(gateway, "0.0.0.0"))
			r.flags |= 8;
		if(def)
			r.flags |= 2;
		if(ioctl(fd, SIOCADDRT, &r))
			return 2;
	} else {
		struct route r;
		r.dest.sin_family = AF_INET;
		inet_aton(dest, &r.dest.sin_addr);
		if(ioctl(fd, SIOCDELRT, &r))
			return 2;
	}
	return 0;
}


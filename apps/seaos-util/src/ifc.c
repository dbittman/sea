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
#include <glob.h>

#define DEV_DIR "/dev/"

const char *if_types[255] = {
	[0x18] = "loopback",
	[6] = "ethernet",
};

const char *flag_names[32] = {
	"up",
	"broadcast",
	"debug",
	"loopback",
	"pointopoint",
	"notrailers",
	"running",
	"noarp",
	"promisc",
	"allmulti",
	"oactive",
	"simplex",
	"link0",
	"link1",
	"link2",
	"multicast",
	[17] = "forward"
};

void convert_mask(int slash, char *string)
{
	uint32_t mask = 0;
	int i = 32;
	while(slash--)
		mask |= (1 << (--i));
	sprintf(string, "%d.%d.%d.%d", (mask >> 24) & 0xFF, (mask >> 16) & 0xFF, (mask >> 8) & 0xFF, mask & 0xFF);
}

int do_ioctl(const char *name, int cmd, void *arg)
{
	char tmp[IFNAMSIZ + 1 + strlen(DEV_DIR)];
	sprintf(tmp, "%s%s", DEV_DIR, name);
	int fd = open(tmp, O_RDWR);
	if(fd < 0) {
		perror("couldn't open interface");
		return -1;
	}
	int ret = ioctl(fd, cmd, arg);
	if(ret < 0)
		perror("ioctl() failed on interface");
	close(fd);
	return ret;
}

int do_set_flags(const char *name, int flags)
{
	struct ifreq ifr;
	strncpy(ifr.ifr_name, name, IFNAMSIZ);
	ifr.ifr_flags = flags;
	return do_ioctl(name, SIOCSIFFLAGS, &ifr);
}

int do_get_flags(const char *name, int *flags)
{
	struct ifreq ifr;
	strncpy(ifr.ifr_name, name, IFNAMSIZ);
	int r = do_ioctl(name, SIOCGIFFLAGS, &ifr);
	*flags = ifr.ifr_flags;
	return r;
}

int set_flag(const char *name, const char *flag, int unset)
{
	int flags = 0, i;
	if(do_get_flags(name, &flags)) {
		perror("failed to get current flags");
		return -1;
	}
	
	for(i=0;i<32;i++) {
		if(!strcasecmp(flag, flag_names[i])) {
			break;
		}
	}
	if(i == 32) {
		fprintf(stderr, "ifc: invalid flag '%s'.\n", flag);
		return -1;
	}
	if(unset)
		flags &= ~(1 << i);
	else
		flags |= 1 << i;
	if(do_set_flags(name, flags)) {
		perror("failed to set new flags");
		return -1;
	}
	return 0;
}

int print_flags(const char *name)
{
	int i, flags;
	if(do_get_flags(name, &flags)) {
		perror("failed to get current flags");
		return -1;
	}
	setbuf(stdout, 0);
	printf("\tflags: %x: ", flags);
	for(i=0;i<32;i++) {
		int w = 0;
		if((flags & 1) && flag_names[i]) {
			w = 1;
			printf("%s", flag_names[i]);
		}
		flags = flags >> 1;
		if(flags && w)
			printf(",");
	}
	printf("\n");
	return 0;
}

int do_set_mask(const char *name, struct sockaddr_in *addr)
{
	struct ifreq ifr;
	strncpy(ifr.ifr_name, name, IFNAMSIZ);
	memcpy(&ifr.ifr_netmask, addr, sizeof(ifr.ifr_netmask));
	return do_ioctl(name, SIOCSIFNETMASK, &ifr);
}

int do_set_broad_addr(const char *name, struct sockaddr_in *addr)
{
	struct ifreq ifr;
	strncpy(ifr.ifr_name, name, IFNAMSIZ);
	memcpy(&ifr.ifr_addr, addr, sizeof(ifr.ifr_addr));
	return do_ioctl(name, SIOCSIFBRDADDR, &ifr);
}

int do_set_addr(const char *name, struct sockaddr_in *addr)
{
	struct ifreq ifr;
	strncpy(ifr.ifr_name, name, IFNAMSIZ);
	memcpy(&ifr.ifr_addr, addr, sizeof(ifr.ifr_addr));
	return do_ioctl(name, SIOCSIFADDR, &ifr);
}

int do_get_mask(const char *name, struct sockaddr_in *addr)
{
	struct ifreq ifr;
	strncpy(ifr.ifr_name, name, IFNAMSIZ);
	ifr.ifr_netmask.sa_family = AF_INET;
	int ret = do_ioctl(name, SIOCGIFNETMASK, &ifr);
	if(ret < 0)
		return ret;
	memcpy(addr, &ifr.ifr_netmask, sizeof(ifr.ifr_netmask));
	return 0;
}

int do_get_addr(const char *name, struct sockaddr_in *addr)
{
	struct ifreq ifr;
	strncpy(ifr.ifr_name, name, IFNAMSIZ);
	ifr.ifr_addr.sa_family = AF_INET;
	int ret = do_ioctl(name, SIOCGIFADDR, &ifr);
	if(ret < 0)
		return ret;
	memcpy(addr, &ifr.ifr_addr, sizeof(ifr.ifr_addr));
	return 0;
}

int do_get_broad_addr(const char *name, struct sockaddr_in *addr)
{
	struct ifreq ifr;
	strncpy(ifr.ifr_name, name, IFNAMSIZ);
	ifr.ifr_addr.sa_family = AF_INET;
	int ret = do_ioctl(name, SIOCGIFBRDADDR, &ifr);
	if(ret < 0)
		return ret;
	memcpy(addr, &ifr.ifr_addr, sizeof(ifr.ifr_addr));
	return 0;
}

int set_broad_addr(const char *name, const char *str)
{
	struct sockaddr_in addr;
	addr.sin_family = AF_INET;
	inet_aton(str, &addr.sin_addr);
	return do_set_broad_addr(name, &addr);
}

int set_mask(const char *name, const char *mask_string)
{
	struct sockaddr_in addr;
	addr.sin_family = AF_INET;
	inet_aton(mask_string, &addr.sin_addr);
	return do_set_mask(name, &addr);
}

int set_addr(const char *name, char *addr_string)
{
	struct sockaddr_in addr;
	addr.sin_family = AF_INET;
	char *slash = strchr(addr_string, '/');
	if(slash) {
		/* we're given the netmask here, so do things */
		*slash = 0;
		slash++;
		int smask = strtol(slash, 0, 10);
		if(smask < 1 || smask > 32) {
			fprintf(stderr, "ifc: invalid netmask\n");
			return -1;
		}
		char tmp[32];
		convert_mask(smask, tmp);
		if(set_mask(name, tmp)) {
			fprintf(stderr, "ifc: unable to set netmask\n");
			return -1;
		}
	}
	
	if(inet_aton(addr_string, &addr.sin_addr) == 0) {
		fprintf(stderr, "ifc: invalid address '%s'.\n", addr_string);
		return -1;
	}
	return do_set_addr(name, &addr);
}

int set_mtu(const char *name, const char *str)
{
	int mtu = strtol(str, 0, 0);
	struct ifreq ifr;
	ifr.ifr_mtu = mtu;
	return do_ioctl(name, SIOCSIFMTU, &ifr);
}


void usage()
{
	fprintf(stderr, "ifc: SeaOS Network Interface Configuration\n");
	fprintf(stderr, "usage: ifc [-i <interface>] [-s <flag>] [-u <flag>]\n           [-n <address>] [-m <mask>] [-t <mtu>] [-b <broadcast>]\n");
	fprintf(stderr, "by default, with no options specified, ifc will print out interface statistics from"
			"all interfaces on the system. If just -i is specified, stats from that interface will be"
			"printed only.\n");
	fprintf(stderr, "Options:\n");
	fprintf(stderr, "  -i: specify interface to operate on.\n");
	fprintf(stderr, "  -s/u: set/unset a flag from an interface.\n");
	fprintf(stderr, "  -m: set netmask.\n");
	fprintf(stderr, "  -n: set network address.\n");
	fprintf(stderr, "  -b: set broadcast address.\n");
	fprintf(stderr, "  -t: set MTU.\n");
	exit(0);
}

void print_stats(const char *name)
{
	struct if_data ifd;
	if(do_ioctl(name, SIOCGIFDATA, &ifd)) {
		fprintf(stderr, "failed to read interface statistics\n");
		return;
	}
	struct sockaddr addr;
	addr.sa_family = AF_INET;
	struct ifreq ifr;
	strncpy(ifr.ifr_name, name, IFNAMSIZ);
	if(!do_ioctl(name, SIOCGIFHWADDR, &ifr)) {
		memcpy(&addr, &ifr.ifr_addr, sizeof(ifr.ifr_addr));
		printf("\thwaddr: %x:%x:%x:%x:%x:%x\n", (unsigned char)addr.sa_data[0], (unsigned char)addr.sa_data[1], (unsigned char)addr.sa_data[2], (unsigned char)addr.sa_data[3],
				addr.sa_data[4], addr.sa_data[5]);
	} else
		fprintf(stderr, "failed to read hwaddr\n");
	
	unsigned speed = ifd.ifi_baudrate / 1000;
	char sc = 'K';
	if(speed > 2000) {
		sc = 'M';
		speed /= 1000;
	}
	printf("\ttype: %s, MTU: %d, speed: %d %cbit/s\n", if_types[ifd.ifi_type] ? if_types[ifd.ifi_type] : "(unknown)", ifd.ifi_mtu, speed, sc);
	printf("\trx: %d rec, %d err: %d KB\n", ifd.ifi_ipackets, ifd.ifi_ierrors, ifd.ifi_ibytes / 1024);
	printf("\ttx: %d snt, %d err: %d KB\n", ifd.ifi_opackets, ifd.ifi_oerrors, ifd.ifi_obytes / 1024);
	printf("\tcollisions: %d, dropped: %d\n", ifd.ifi_collisions, ifd.ifi_iqdrops);
}

void print_interface(const char *name)
{
	printf("%s:\n", name);
	struct sockaddr_in addr, mask, broad;
	addr.sin_family = AF_INET;
	mask.sin_family = AF_INET;
	broad.sin_family = AF_INET;
	if(do_get_addr(name, &addr))
		exit(1);
	if(do_get_mask(name, &mask))
		exit(1);
	if(do_get_broad_addr(name, &broad))
		exit(1);

	char tmp[32];
	inet_ntop(AF_INET, &addr.sin_addr, tmp, 32);
	printf("\tinet: %s", tmp);
	inet_ntop(AF_INET, &mask.sin_addr, tmp, 32);
	printf(" mask: %s", tmp);
	inet_ntop(AF_INET, &broad.sin_addr, tmp, 32);
	printf(" broadcast: %s\n", tmp);
	print_flags(name);
	print_stats(name);
	printf("\n");
}

void read_stats(const char *name)
{
	if(name) {
		print_interface(name);
		return;
	}
	/* scan for interface names */
	glob_t g;
	char tmp[32];
	sprintf(tmp, "%snd*", DEV_DIR);
	g.gl_offs = 256;
	g.gl_offs = 256;
	if(glob(tmp, 0, 0, &g)) {
		perror("glob for interface failed");
		return;
	}
	int i;
	for(i=0;i<g.gl_pathc;i++)
		print_interface((char *)basename(g.gl_pathv[i]));
}

int main(int argc, char **argv)
{
	int c;
	int read = 1; /* by default, we read data and print it out. operation modes that
				   * write settings change this to 0. */
	const char *name = 0;
	/* parse options to look for the interface name... */
	opterr = 0;
	while((c = getopt(argc, argv, "hi:")) != -1) {
		switch(c) {
			case 'h':
				usage();
				break;
			case 'i':
				name = optarg;
				break;
		}
	}

	/* reset getopt() and set the things */
	optind = 0;
	opterr = 1;
	while((c = getopt(argc, argv, "u:s:n:m:i:hb:")) != -1) {
		switch(c) {
			case 'u':
				read = 0;
				if(!name) {
					fprintf(stderr, "ifc: no interface specified\n");
					exit(1);
				}
				if(set_flag(name, optarg, 1))
					exit(1);
				break;
			case 's':
				read = 0;
				if(!name) {
					fprintf(stderr, "ifc: no interface specified\n");
					exit(1);
				}
				if(set_flag(name, optarg, 0))
					exit(1);
				break;
			case 'n':
				read = 0;
				if(!name) {
					fprintf(stderr, "ifc: no interface specified\n");
					exit(1);
				}
				if(set_addr(name, optarg))
					exit(1);
				break;
			case 'b':
				read = 0;
				if(!name) {
					fprintf(stderr, "ifc: no interface specified\n");
					exit(1);
				}
				if(set_broad_addr(name, optarg))
					exit(1);
				break;
			case 'm':
				read = 0;
				if(!name) {
					fprintf(stderr, "ifc: no interface specified\n");
					exit(1);
				}
				if(set_mask(name, optarg))
					exit(1);
				break;
			case 't':
				read = 0;
				if(!name) {
					fprintf(stderr, "ifc: no interface specified\n");
					exit(1);
				}
				if(set_mtu(name, optarg))
					exit(1);
				break;
			case 'i': break;
			default:
				exit(1);
		}
	}
	if(read)
		read_stats(name);
	return 0;
}


#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <errno.h>

struct sl_io {
	int rep;
	int port;
	int in;
	int string, stringdown;
	int size;
	long value, addr;
};

struct slaunch {
	struct sl_io io;
	int rtu_cause, error;
};

struct vmioctl {
	int flags;
	int irq;
	int min;
	unsigned long us_vaddr, paddr;
	struct slaunch run;
};

int main(int argc, char **argv)
{
	int f = open("/dev/shivctl", O_RDWR);
	if(f < 0) {
		perror("open: shivctl");
		exit(1);
	}

	struct vmioctl ctl;

	int r = ioctl(f, 1, (long)&ctl);
	if(r < 0) {
		perror("ioctl VM_CREATE");
		exit(1);
	}

	int v = open("/dev/shiv1", O_RDWR);
	if(v < 0) {
		perror("open: shiv1");
		exit(1);
	}

	FILE *bios = fopen("/shivbios", "r");
	if(!bios) {
		perror("open bios");
		exit(1);
	}

	unsigned char *map = mmap(0, 0x1000, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANON, 0, 0);
	if(!map) {
		perror("mmap");
		exit(1);
	}

	ctl.us_vaddr = (unsigned long)map;
	
	int i;
	for(i=0;i<256;i++) {
		ctl.paddr = 0x1000 * i;
		r = ioctl(v, 8, &ctl);
		if(r < 0) {
			perror("ioctl VM_MAP");
			exit(1);
		}

		fprintf(stderr, "writing %x\r", ctl.paddr);
		memset(map, 0, 0x1000);
		if(ctl.paddr >= 0xE0000 && ctl.paddr <= 0xFFFFF) {
			/* copy bios */
			fread(map, 1, 0x1000, bios);
			if(ferror(bios)) {
				perror("read bios");
				exit(1);
			}
		}

		r = ioctl(v, 9, &ctl);
		if(r < 0) {
			perror("ioctl VM_UNMAP");
			exit(1);
		}
	}
		ctl.paddr = 0x1000 * 255;
		r = ioctl(v, 8, &ctl);
		if(r < 0) {
			perror("ioctl VM_MAP");
			exit(1);
		}


	printf("--> %x %x %x %x %x %x\n",
			map[0xff0],
			map[0xff1],
			map[0xff2],
			map[0xff3],
			map[0xff4],
			map[0xff5]);


	while(1) {
	
		r = ioctl(v, 5, &ctl);
		if(r < 0) {
			int cause = errno;
			fprintf(stderr, "exited vm monitor: %d (%d)\n", r, errno);
		} else {
			fprintf(stderr, "RTU: %d\n", ctl.run.rtu_cause);
		}
	}
	return 0;
}


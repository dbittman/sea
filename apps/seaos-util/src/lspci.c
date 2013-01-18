/* 
 * Copyright (C) 2012  Daniel Bittman

 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.

 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.

 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>
 */
#include <stdio.h>
#include <sys/types.h>
#include <sys/dirent.h>
#include <errno.h>
#include <unistd.h>
#include "pci_l.h"
#include <string.h>
#define uint16_t unsigned short
#define uint32_t unsigned 
#define uint8_t unsigned char
struct pci_config_space
{
	/* 0x00 */
	uint16_t vendor_id;
	uint16_t device_id;
	/* 0x04 */
	uint16_t command;
	uint16_t status;
	/* 0x08 */
	uint16_t revision;
	uint8_t  subclass;
	uint8_t  class_code;
	/* 0x0C */
	uint8_t  cache_line_size;
	uint8_t  latency_timer;
	uint8_t  header_type;
	uint8_t  bist;
	/* 0x10 */
	uint32_t bar0;
	/* 0x14 */
	uint32_t bar1;
	/* 0x18 */
	uint32_t bar2;
	/* 0x1C */
	uint32_t bar3;
	/* 0x20 */
	uint32_t bar4;
	/* 0x24 */
	uint32_t bar5;
	/* 0x28 */
	uint32_t cardbus_cis_pointer;
	/* 0x2C */
	uint16_t subsystem_vendor_id;
	uint16_t subsystem_id;
	/* 0x30 */
	uint32_t expansion_rom_base_address;
	/* 0x34 */
	uint32_t reserved0;
	/* 0x38 */
	uint32_t reserved1;
	/* 0x3C */
	uint8_t  interrupt_line;
	uint8_t  interrupt_pin;
	uint8_t  min_grant;
	uint8_t  max_latency;
};

struct pci_device
{
	unsigned short bus, dev, func;
	struct pci_config_space *pcs;
	
	unsigned char flags;
	unsigned error;
	char pad;
	unsigned *node;
};
#define	PCI_DEVTABLE_LEN	(sizeof(PciDevTable)/sizeof(PCI_DEVTABLE))
static const char * class_code[13] = 
{ 
	"Legacy", "Mass Storage Controller", "Network Controller", 
	"Video Controller", "Multimedia Unit", "Memory Controller", "Bridge",
	"Simple Communications Controller", "Base System Peripheral", "Input Device",
	"Docking Station", "Processor", "Serial Bus Controller"
};
const char *getVendor (uint16_t vendor)
{
	unsigned int i;
	for (i = 0; i < PCI_VENTABLE_LEN; i++)
	{
		if (PciVenTable[i].VenId == vendor)
			return PciVenTable[i].VenShort;
	}
	return "";
}

const char *getDevice (uint16_t vendor, uint16_t device)
{
	unsigned int i;
	for (i = 0; i < PCI_DEVTABLE_LEN; i++)
	{
		if (PciDevTable[i].VenId == vendor && PciDevTable[i].DevId == device)
			return PciDevTable[i].ChipDesc;
	}
	return "";
}
const char *getDeviceS (uint16_t vendor, uint16_t device)
{
	unsigned int i;
	for (i = 0; i < PCI_DEVTABLE_LEN; i++)
	{
		if (PciDevTable[i].VenId == vendor && PciDevTable[i].DevId == device)
			return PciDevTable[i].Chip;
	}
	return "";
}
int desc=0;
char astat[16];
char *getstat(char s)
{
	memset(astat, 0, 16);
	memset(astat, '-', 8);
	if(s & 0x1)
		astat[0]='D';
	if(s & 0x2)
		astat[1]='E';
	if(s & 0x4)
		astat[2]='F';
	
	return astat;
}

int help()
{
	printf("lspci - Print info about PCI devices\n");
	printf("Options: -d - Output more information\n");
	printf("Output formated:\n\tBUS:DEVICE.FUNCTION CLASSCODE: VENDOR DEVICE-NAME-SHORT\n");
	printf("When -d is used, a second line for each device is printed:\n");
	printf("\tFLAGS:LAST-ERROR-CODE: DEVICE-NAME-LONG\n");
	printf("Flags are as follows:\n\tD: Device has a driver using it\n\tE: Device is active\n\tF: Device has an error\n");
	
	return 0;
}

int main(int argc, char **argv)
{
	if(argc > 1 && argv[1][1] == 'd')
		desc=1;
	if(argc > 1 && argv[1][1] == 'h')
		return help();
	DIR *d = opendir("/proc/pci");
	if(!d)
	{
		fprintf(stderr, "%s: could not open /proc/pci. This is usually caused by the pci driver not being loaded. Please load the pci driver and try again.\n", basename(argv[0]));
		return 1;
	}
	struct dirent *dir;
	while(dir = readdir(d))
	{
		char path[128];
		sprintf(path, "/proc/pci/%s", dir->d_name);
		FILE *f = fopen(path, "r");
		if(!f)
		{
			fprintf(stderr, "%s: %s: %s\n", basename(argv[0]), path, strerror(errno));
		} else
		{
			char buf[128];
			fread(buf, 1, 36, f);
			struct pci_device *p = (struct pci_device *)buf;
			printf("%2.2x:%2.2x.%d %s: %s %s\n", p->bus, p->dev, p->func, class_code[p->pcs->class_code], getVendor(p->pcs->vendor_id), getDeviceS(p->pcs->vendor_id, p->pcs->device_id));
			if(desc)
				printf("\t%s:%d: %s\n", getstat(p->flags), p->error, getDevice(p->pcs->vendor_id, p->pcs->device_id));
			fclose(f);
		}
	}
	closedir(d);
	return 0;
}

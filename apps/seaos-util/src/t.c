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
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <sys/stat.h>

int main(int c, char **a)
{
	printf("TEST PROGRAM\n");
	fprintf(stderr, "This goes to stderr\n");
	int i;
	printf("Here are the arguments\n");
	for(i=0;i<c;i++)
	{
		printf("%d: %s\n", i, *(a+i));
	}
	printf("Lets malloc alot of memory\n");
	char *g = malloc(0x100000);
	printf("got %x\n", g);
	free(g);
	printf("Done testing\n");
	if(c > 1)
	{
		if(a[1][0] == 'p')
			syscall(0, 1, 0, 0, 0, 0);
		if(a[1][0] == 'f')
		{
			printf("NULL POINTER\n");
			unsigned *po = (unsigned *)0;
			printf("%x\n", *po);
		}
		printf("Testing usermode!\n");
		asm("cli");
		printf("Failed...\n");
	}
	return 0;
}

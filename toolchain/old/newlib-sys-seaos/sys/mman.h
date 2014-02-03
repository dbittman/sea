#ifndef __MMF_H
#define __MMF_H
void *mmap(void *addr, size_t len, int prot, int flags, int fildes, off_t off);
int munmap(void *, int);
/*
 * Prots to 'mmap'.
 */
#define PROT_READ       0x1
#define PROT_WRITE      0x2
#define PROT_EXEC       0x4
#define PROT_NONE       0x0
/*
 * Flags to 'mmap'.
 */
#define MAP_SHARED      0x001
#define MAP_PRIVATE     0x002
#define MAP_FIXED       0x010
#define MAP_FILE        0x000
#define MAP_ANONYMOUS   0x020
#define MAP_ANON        MAP_ANONYMOUS
#define MAP_GROWSDOWN   0x0100
#define MAP_DENYWRITE   0x0800
#define MAP_EXECUTABLE  0x1000
#define MAP_LOCKED      0x0080
#define MAP_NORESERVE   0x0040
/*
 * Failed flag from 'mmap'.
 */
#define MAP_FAILED_EADDR  ((unsigned long long) (-1LL))
/*
 * Flags to 'mremap'.
 */
#define MREMAP_MAYMOVE  1
/*
 * Flags to 'msync'.
 */
#define MS_ASYNC        1
#define MS_SYNC         4
#define MS_INVALIDATE   2

#endif

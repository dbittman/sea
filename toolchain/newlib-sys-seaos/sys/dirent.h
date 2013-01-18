/* libc/sys/linux/sys/dirent.h - Directory entry as returned by readdir */

/* Written 2000 by Werner Almesberger */


#ifndef _SYS_DIRENT_H
#define _SYS_DIRENT_H
#define DT_BLK 4
#define DT_CHR 3
#define DT_DIR 2
#define DT_REG 1
#define DT_FIFO 5
#define DT_LNK 7
#define DT_SOCK 6
#define DT_UNKNOWN 0
#include <sys/types.h>
#define _LIBC 1
#define  NOT_IN_libc 1
#include <sys/lock.h>
#undef _LIBC


#ifdef __USE_LARGEFILE64
struct dirent64
  {
   unsigned long long d_ino;
    unsigned long long d_off;
    unsigned short int d_reclen;
    unsigned char d_type;
    char d_name[256];		/* We must not include limits.h! */
  };
#endif

#define d_fileno	d_ino	/* Backwards compatibility.  */

#undef  _DIRENT_HAVE_D_NAMLEN
#define _DIRENT_HAVE_D_RECLEN
#define _DIRENT_HAVE_D_OFF
#define _DIRENT_HAVE_D_TYPE
#define HAVE_NO_D_NAMLEN	/* no struct dirent->d_namlen */
#define HAVE_DD_LOCK  		/* have locking mechanism */

#define MAXNAMLEN 255		/* sizeof(struct dirent.d_name)-1 */


#if 0

typedef struct {
    int dd_fd;		/* directory file */
    int dd_loc;		/* position in buffer */
    int dd_seek;
    char *dd_buf;	/* buffer */
    int dd_len;		/* buffer length */
    int dd_size;	/* amount of data in buffer */
    _LOCK_RECURSIVE_T dd_lock;
} DIR;
#endif




#define __dirfd(dir) (dir)->fd
#define dd_fd fd
struct dirent
  {
#ifndef __USE_FILE_OFFSET64
    unsigned d_ino;
    unsigned d_off;
#else
    unsigned long long d_ino;
    unsigned long long d_off;
#endif
    unsigned short int d_reclen;
    unsigned char d_type;
    char d_name[256];		/* We must not include limits.h! */
  };

  
struct __dirstream {
	int pos;
	int fd;
	struct dirent __d;
};


typedef struct __dirstream DIR;
/* --- redundant --- */

DIR *opendir(const char *);
struct dirent *readdir(DIR *);
void rewinddir(DIR *);
int closedir(DIR *);

/* internal prototype */
void _seekdir(DIR *dir, long offset);
DIR *_opendir(const char *);

#ifndef _POSIX_SOURCE
long telldir (DIR *);
void seekdir (DIR *, off_t loc);

int scandir (const char *__dir,
             struct dirent ***__namelist,
             int (*select) (const struct dirent *),
             int (*compar) (const struct dirent **, const struct dirent **));

int alphasort (const struct dirent **__a, const struct dirent **__b);
#endif /* _POSIX_SOURCE */

  
  #endif

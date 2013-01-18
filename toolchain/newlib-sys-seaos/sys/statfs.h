#ifndef _SYS_STATFS_H
#define _SYS_STATFS_H

struct statfs
  {
    unsigned f_type;
    unsigned f_bsize;
    unsigned long long f_blocks;
    unsigned long long f_bfree;
    unsigned long long f_bavail;
    unsigned long long f_files;
    unsigned long long f_ffree;
    unsigned f_fsid;
    unsigned f_namelen;
    unsigned f_frsize;
    unsigned f_flags;
    unsigned f_spare[4];
  };
  
  struct statvfs
  {
    unsigned f_type;
    unsigned f_bsize;
    unsigned long long f_blocks;
    unsigned long long f_bfree;
    unsigned long long f_bavail;
    unsigned long long f_files;
    unsigned long long f_ffree;
    unsigned f_fsid;
    unsigned f_namelen;
    unsigned f_frsize;
    unsigned f_flags;
    unsigned f_spare[4];
  };
  
int statfs(const char *path, struct statfs *buf);
int fstatfs(int fd, struct statfs *buf);

int statvfs(const char *path, struct statfs *buf);
int fstatvfs(int fd, struct statfs *buf);

enum
{
  ST_RDONLY = 1,		/* Mount read-only.  */
#define ST_RDONLY	ST_RDONLY
  ST_NOSUID = 2			/* Ignore suid and sgid bits.  */
#define ST_NOSUID	ST_NOSUID
  ,
  ST_NODEV = 4,			/* Disallow access to device special files.  */
# define ST_NODEV	ST_NODEV
  ST_NOEXEC = 8,		/* Disallow program execution.  */
# define ST_NOEXEC	ST_NOEXEC
  ST_SYNCHRONOUS = 16,		/* Writes are synced at once.  */
# define ST_SYNCHRONOUS	ST_SYNCHRONOUS
  ST_MANDLOCK = 64,		/* Allow mandatory locks on an FS.  */
# define ST_MANDLOCK	ST_MANDLOCK
  ST_WRITE = 128,		/* Write on file/directory/symlink.  */
# define ST_WRITE	ST_WRITE
  ST_APPEND = 256,		/* Append-only file.  */
# define ST_APPEND	ST_APPEND
  ST_IMMUTABLE = 512,		/* Immutable file.  */
# define ST_IMMUTABLE	ST_IMMUTABLE
  ST_NOATIME = 1024,		/* Do not update access times.  */
# define ST_NOATIME	ST_NOATIME
  ST_NODIRATIME = 2048,		/* Do not update directory access times.  */
# define ST_NODIRATIME	ST_NODIRATIME
  ST_RELATIME = 4096		/* Update atime relative to mtime/ctime.  */
# define ST_RELATIME	ST_RELATIME
};


#endif

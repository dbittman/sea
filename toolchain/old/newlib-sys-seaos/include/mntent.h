 #ifndef __MNTENT_H
 #define __MNTENT_H
 
#define __need_FILE
#include <stdio.h>
#include <paths.h>


/* File listing canonical interesting mount points.  */
#define	MNTTAB		_PATH_MNTTAB	/* Deprecated alias.  */

/* File listing currently active mount points.  */
#define	MOUNTED		_PATH_MOUNTED	/* Deprecated alias.  */


/* General filesystem types.  */
#define MNTTYPE_IGNORE	"ignore"	/* Ignore this entry.  */
#define MNTTYPE_NFS	"nfs"		/* Network file system.  */
#define MNTTYPE_SWAP	"swap"		/* Swap device.  */


/* Generic mount options.  */
#define MNTOPT_DEFAULTS	"defaults"	/* Use all default options.  */
#define MNTOPT_RO	"ro"		/* Read only.  */
#define MNTOPT_RW	"rw"		/* Read/write.  */
#define MNTOPT_SUID	"suid"		/* Set uid allowed.  */
#define MNTOPT_NOSUID	"nosuid"	/* No set uid allowed.  */
#define MNTOPT_NOAUTO	"noauto"	/* Do not auto mount.  */



/* Structure describing a mount table entry.  */
struct mntent
  {
    char *mnt_fsname;		/* Device or server for filesystem.  */
    char *mnt_dir;		/* Directory mounted on.  */
    char *mnt_type;		/* Type of filesystem: ufs, nfs, etc.  */
    char *mnt_opts;		/* Comma-separated options for fs.  */
    int mnt_freq;		/* Dump frequency (in days).  */
    int mnt_passno;		/* Pass number for `fsck'.  */
  };


/* Prepare to begin reading and/or writing mount table entries from the
   beginning of FILE.  MODE is as for `fopen'.  */
extern FILE *setmntent (const char *__file, const char *__mode);

/* Read one mount table entry from STREAM.  Returns a pointer to storage
   reused on the next call, or null for EOF or error (use feof/ferror to
   check).  */
extern struct mntent *getmntent (FILE *__stream);

/* Reentrant version of the above function.  */
extern struct mntent *getmntent_r (FILE *__restrict __stream,
				   struct mntent *__restrict __result,
				   char *__restrict __buffer,
				   int __bufsize);

/* Write the mount table entry described by MNT to STREAM.
   Return zero on success, nonzero on failure.  */
extern int addmntent (FILE *__restrict __stream,
		      const struct mntent *__restrict __mnt);

/* Close a stream opened with `setmntent'.  */
extern int endmntent (FILE *__stream);

/* Search MNT->mnt_opts for an option matching OPT.
   Returns the address of the substring, or null if none found.  */
extern char *hasmntopt (const struct mntent *__mnt,
			const char *__opt);

#endif


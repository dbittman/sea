#ifndef __SYS_SEAOS_H
#define __SYS_SEAOS_H

#define SEA_MODULE_FORCE 1
#define SEA_MODULE_CHECK 2

int sea_mount_filesystem(char *node, char *dir, char *fsname, char *opts, int flags);
int sea_umount_filesystem(char *dir, int flags);
int sea_load_module(char *path, char *opts, int flags);
int sea_unload_module(char *path, int flags);

#endif

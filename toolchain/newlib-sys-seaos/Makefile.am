AUTOMAKE_OPTIONS = cygnus
INCLUDES = $(NEWLIB_CFLAGS) $(CROSS_CFLAGS) $(TARGET_CFLAGS) -I ./include -I ./include/netinet

SUBDIRS = machine \
	$(EXTRA_SUBDIRS)\
	.

SUBLIBS = \
	$(EXTRA_SUBLIBS) \
	$(SEAOS_MACH_LIB)
ADD_OBJS = \
	$(SEAOS_MACH_LIB)
AM_CCASFLAGS = $(INCLUDES)
noinst_LIBRARIES = lib.a
if MAY_SUPPLY_SYSCALLS
extra_objs = getopt.o sysc.o \
			mmap.o \
			cfspeed.o \
			rand.o \
			rand48.o \
			rand_r.o \
			seaos.o \
			termios.o \
			pathconf.o \
			time.o \
			proc.o \
			signal.o \
			log.o \
			mount.o \
			module.o \
			id.o \
			fork.o \
			exit.o \
			group.o \
			srv.o \
			nice.o \
			ctl.o \
			ctype.o \
			daemon.o \
			execl.o \
			execle.o \
			execlp.o \
			execv.o \
			execve.o \
			execvp.o \
			ftok.o at.o ch.o dir.o link.o openclose.o rw.o special.o stat.o sync.o truncate.o mntent.o
else
extra_objs =
endif
lib_a_SOURCES =
lib_a_LIBADD = $(extra_objs) $(ADD_OBJS)
EXTRA_lib_a_SOURCES = ${extra_objs:.o=.c}
lib_a_DEPENDENCIES = $(extra_objs) $(ADD_OBJS)
lib_a_CCASFLAGS = $(AM_CCASFLAGS)
lib_a_CFLAGS = $(AM_CFLAGS) -I ./include -I ./include/netinet
if MAY_SUPPLY_SYSCALLS
all: crt0.o
endif
ACLOCAL_AMFLAGS = -I ../../..
CONFIG_STATUS_DEPENDENCIES = $(newlib_basedir)/configure.host

## Process this file with automake to generate Makefile.in

AUTOMAKE_OPTIONS = cygnus

INCLUDES = $(NEWLIB_CFLAGS) $(CROSS_CFLAGS) $(TARGET_CFLAGS)

LIB_SOURCES = hp-timing.c setjmp.S dl-procinfo.c

## liblinuxi386_la_LDFLAGS = -Xcompiler -nostdlib

AM_CFLAGS = -I$(srcdir)/../..
AM_CCASFLAGS = -I$(srcdir)/../.. $(INCLUDES)

if USE_LIBTOOL
noinst_LTLIBRARIES = libseaosi386.la
libseaosi386_la_SOURCES = $(LIB_SOURCES)
noinst_DATA = objectlist.awk.in
else
noinst_LIBRARIES = lib.a
lib_a_SOURCES = $(LIB_SOURCES)
lib_a_CFLAGS = $(AM_CFLAGS)
lib_a_CCASFLAGS = $(AM_CCASFLAGS)
noinst_DATA =
endif # USE_LIBTOOL

include $(srcdir)/../../../../../Makefile.shared

all-local: 
	cp lib.a ..
ACLOCAL_AMFLAGS = -I ../../../../.. -I ../../../../../..
CONFIG_STATUS_DEPENDENCIES = $(newlib_basedir)/configure.host

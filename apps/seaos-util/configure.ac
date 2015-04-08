#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

PACKAGE=seaos-util
VERSION=0.1

AC_PREREQ([2.68])
AC_INIT(PACKAGE, VERSION)
AC_CONFIG_SRCDIR([src/swap.c])
AC_CONFIG_HEADERS([config.h])
AM_INIT_AUTOMAKE
# Checks for programs.
AC_PROG_CC

# Checks for libraries.

# Checks for header files.
AC_CHECK_HEADERS([fcntl.h stdlib.h string.h sys/time.h unistd.h])

# Checks for typedefs, structures, and compiler characteristics.
AC_TYPE_UINT16_T
AC_TYPE_UINT32_T
AC_TYPE_UINT8_T

# Checks for library functions.
AC_FUNC_FORK
AC_FUNC_MALLOC
AC_CHECK_FUNCS([memset strchr strerror strrchr])

AC_OUTPUT(Makefile src/Makefile)


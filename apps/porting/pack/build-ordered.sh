#!/bin/sh
JOBS="gmp ncurses" build-all.sh $2
JOBS="gmp ncurses" aggregate.sh $1 $2
JOBS="mpfr readline gdbm" build-all.sh $2
JOBS="mpfr readline gdbm" aggregate.sh $1 $2
JOBS="mpc openssl libpipeline" build-all.sh $2
JOBS="mpc openssl libpipeline" aggregate.sh $1 $2

REST="gcc autoconf automake bash binutils bison cond coreutils diffutils e2fsprogs findutils flex gawk grep groff grub gzip less m4 make man-db nano nasm pack patch seaosutil sed tar vim which libtool bzip2"

JOBS=$REST build-all.sh $2
JOBS=$REST aggregate.sh $1 $2


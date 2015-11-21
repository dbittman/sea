#!/bin/sh
JOBS="gmp ncurses" build-all.sh $2
JOBS="gmp ncurses" aggregate.sh $1 $2
JOBS="mpfr readline" build-all.sh $2
JOBS="mpfr readline" aggregate.sh $1 $2
JOBS="mpc openssl" build-all.sh $2
JOBS="mpc openssl" aggregate.sh $1 $2

REST="autoconf automake bash binutils bison cond coreutils diffutils e2fsprogs findutils flex gawk gcc grep grub gzip less m4 make nano nasm pack patch seaosutil sed tar vim which"

JOBS=$REST build-all.sh $2
JOBS=$REST aggregate.sh $1 $2


#!/bin/sh
echo "changing bash config.h (${1})"
echo "#undef GETCWD_BROKEN" >> ../build-${1}-bash-4.2/config.h
echo "#define HAVE_GETCWD 1" >> ../build-${1}-bash-4.2/config.h

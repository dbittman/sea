#!/bin/sh

echo "#undef GETCWD_BROKEN" >> config.h
echo "#define HAVE_GETCWD 1" >> config.h

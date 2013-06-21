#!/bin/sh
cd ..
cp -rf nasm-2.10/* build-${1}-nasm-2.10/
rm -rf nasm-2.10
ln -s build-${1}-nasm-2.10 nasm-2.10
cd nasm-2.10

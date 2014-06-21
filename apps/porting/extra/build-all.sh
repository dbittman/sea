#!/bin/sh

LIST=`cat package-list`

for i in $LIST; do
  sh build-$i.sh $1 $2
done

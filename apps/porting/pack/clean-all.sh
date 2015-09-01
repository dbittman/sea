#!/bin/sh

for i in $(ls packs); do
	./clean.sh $i $1
done


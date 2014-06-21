#!/bin/sh
if [ -e buildnr ]; then
  awk '/[0-9]+/ {print $1+1}' < buildnr > buildnr.new && rm buildnr
else
  echo -n "1" > buildnr.new
fi

mv buildnr.new buildnr

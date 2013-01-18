#!/bin/sh

VAL=`cat build_number`
VAL=$((VAL + 1))
echo $VAL > build_number

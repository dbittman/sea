#!/bin/sh

if [[ $1 == "rw" ]]; then
	svn checkout https://seaos-apps.googlecode.com/svn/trunk/ apps --username $2
	svn checkout https://seaos-kernel.googlecode.com/svn/trunk/ system --username $2
else
	svn checkout http://seaos-apps.googlecode.com/svn/trunk/ apps
	svn checkout http://seaos-kernel.googlecode.com/svn/trunk/ system
fi

cd apps
svn update
cd ../system
svn update
cd ..
svn update

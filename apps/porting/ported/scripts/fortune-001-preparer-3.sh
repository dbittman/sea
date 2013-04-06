cp ../files/fortune.c .
mkdir -p ../build-${1}-fortune-001
i586-pc-seaos-gcc fortune.c -o ../build-${1}-fortune-001/fortune
cp -rf ../build-${1}-fortune-001/fortune ../../../data/usr/bin/

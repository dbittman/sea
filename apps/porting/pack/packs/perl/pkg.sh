VERSION=5.22.0
NAME=perl
DESC=
DEPENDS=
CONFLICTS=

SOURCES=(https://raw.github.com/arsv/perl-cross/releases/perl-5.22.0-cross-1.0.1.tar.gz http://www.cpan.org/src/5.0/perl-5.22.0.tar.gz)
SOURCES_HASHES=(a32bcce864f0ece05074c8ea009fb6c2 e32cb6a8dda0084f2a43dac76318d68d)
PATCHES=()

function prepare() {
	if ! [ -d $NAME-$VERSION ]; then
		tar xf $NAME-$VERSION.tar.gz
		tar xf perl-5.22.0-cross-1.0.1.tar.gz
	fi
}

function build() {
	cp -rf ../src/$NAME-$VERSION/* .
	if ! ./configure --prefix=/usr --target=$HOST_TRIPLET --sysroot=$($HOST_TRIPLET-gcc -print-sysroot) --with-cc=$HOST_TRIPLET-gcc --with-ranlib=$HOST_TRIPLET-ranlib --with-objdump=$HOST_TRIPLET-objdump --host-cc=gcc --host-ranlib=ranlib --host-objdump=objdump; then
		return 1
	fi

	if ! make DESTDIR=$INSTALL_ROOT all install; then
		return 1
	fi
}


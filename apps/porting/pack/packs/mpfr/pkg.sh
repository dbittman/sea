VERSION=3.1.2
NAME=mpfr
DESC=
DEPENDS=
CONFLICTS=

SOURCES=(ftp://ftp.gnu.org/gnu/mpfr/mpfr-3.1.2.tar.gz)
SOURCES_HASHES=(181aa7bb0e452c409f2788a4a7f38476)
PATCHES=("patches/$NAME-$VERSION-seaos-all.patch")

function prepare() {
	if ! [ -d $NAME-$VERSION ]; then
		tar xf $NAME-$VERSION.tar.gz
	fi
}

function build() {
	if ! ../src/$NAME-$VERSION/configure --prefix=/usr --host=$HOST_TRIPLET --build=$(sh ../src/mpfr-3.1.2/config.guess) CFLAGS='-fno-stack-protector'; then
		return 1
	fi

	if ! make DESTDIR=$INSTALL_ROOT -j1 all install; then
		return 1
	fi
}


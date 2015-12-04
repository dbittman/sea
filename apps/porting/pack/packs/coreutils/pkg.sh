VERSION=8.16
NAME=coreutils
DESC=
DEPENDS=
CONFLICTS=

SOURCES=(http://ftp.gnu.org/gnu/coreutils/coreutils-8.16.tar.xz)
SOURCES_HASHES=(89b06f91634208dceba7b36ad1f9e8b9)
PATCHES=("patches/$NAME-$VERSION-seaos-all.patch")

function prepare() {
	if ! [ -d $NAME-$VERSION ]; then
		tar xf $NAME-$VERSION.tar.xz
	fi
}

function build() {
	if ! ../src/$NAME-$VERSION/configure --enable-no-install-program=hostname,su --disable-nls --datarootdir=/usr/share --prefix=/ --host=$HOST_TRIPLET --disable-shared; then
		return 1
	fi

	if ! DESTDIR=$INSTALL_ROOT OPTIONAL_PKGLIB_PROGS= make -j$INDIV_PARALLEL all install; then
		return 1
	fi
}


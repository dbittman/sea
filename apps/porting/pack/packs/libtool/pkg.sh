VERSION=2.4.6
NAME=libtool
DESC=
DEPENDS=
CONFLICTS=

SOURCES=(http://ftp.gnu.org/gnu/libtool/libtool-2.4.6.tar.xz)
SOURCES_HASHES=(1bfb9b923f2c1339b4d2ce1807064aa5)
PATCHES=("patches/$NAME-$VERSION-seaos-all.patch")

function prepare() {
	if ! [ -d $NAME-$VERSION ]; then
		tar xf $NAME-$VERSION.tar.xz
	fi
}

function build() {
if ! ../src/$NAME-$VERSION/configure --prefix=/usr --host=$HOST_TRIPLET --build=$(../src/libtool-2.5.6/build-aux/config.guess); then
		return 1
	fi

	if ! make DESTDIR=$INSTALL_ROOT all install; then
		return 1
	fi
}


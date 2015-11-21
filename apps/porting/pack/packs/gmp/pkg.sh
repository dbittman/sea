VERSION=5.1.1
NAME=gmp
DESC=
DEPENDS=
CONFLICTS=

SOURCES=(ftp://ftp.gnu.org/gnu/gmp/gmp-5.1.1.tar.bz2)
SOURCES_HASHES=(2fa018a7cd193c78494525f236d02dd6)
PATCHES=("patches/$NAME-$VERSION-seaos-all.patch")

function prepare() {
	if ! [ -d $NAME-$VERSION ]; then
		tar xf $NAME-$VERSION.tar.bz2
	fi
}

function build() {
if ! ../src/$NAME-$VERSION/configure --prefix=/usr --host=$HOST_TRIPLET CC_FOR_BUILD=gcc CXX_FOR_BUILD=g++ --build=$(../src/gmp-5.1.1/config.guess); then
		return 1
	fi

	if ! make DESTDIR=$INSTALL_ROOT -j1 all install; then
		return 1
	fi
}


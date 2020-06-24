#!/bin/bash
set -e
CPUC=$(awk '/^processor/{n+=1}END{print n}' /proc/cpuinfo)

apt-get update
apt-get install -qy --no-install-recommends \
    libtommath1 \
    libtommath-dev \
    bzip2 \
    ca-certificates \
    curl \
    g++ \
    gcc \
    libicu57 \
    libicu-dev \
    libncurses5-dev \
    libedit-dev \
    autoconf \
    automake \
    bison \
    libatomic-ops-dev \
    libtool \
    make

mkdir -p /home/firebird
cd /home/firebird
curl -L -o firebird-source.tar.bz2 -L \
    "${FBURL}"
tar --strip=1 -xf firebird-source.tar.bz2
curl -L -o builds/make.new/config/config.guess -L "http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.guess;hb=HEAD"
curl -L -o builds/make.new/config/config.sub -L "http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.sub;hb=HEAD"
NOCONFIGURE=1 ./autogen.sh
./configure \
        --prefix=${PREFIX} --with-fbbin=${PREFIX}/bin --with-fbsbin=${PREFIX}/bin --with-fblib=${PREFIX}/lib \
        --with-fbinclude=${PREFIX}/include --with-fbdoc=${PREFIX}/doc --with-fbudf=${PREFIX}/UDF \
        --with-fbsample=${PREFIX}/examples --with-fbsample-db=${PREFIX}/examples/empbuild --with-fbhelp=${PREFIX}/help \
        --with-fbintl=${PREFIX}/intl --with-fbmisc=${PREFIX}/misc --with-fbplugins=${PREFIX} \
        --with-fblog=${VOLUME}/log --with-fbglock=/var/firebird/run \
        --with-fbconf=${VOLUME}/etc --with-fbmsg=${PREFIX} \
        --with-fbsecure-db=${VOLUME}/system --with-system-icu --with-system-editline
export CFLAGS=""
export CPPFLAGS=""
export CXXFLAGS="-std=gnu++98"
export FCFLAGS=""
export FFLAGS=""
export GCJFLAGS=""
export LDFLAGS=""
export OBJCFLAGS=""
export OBJCXXFLAGS=""
make
make silent_install
cd /
rm -rf /home/firebird
find ${PREFIX} -name .debug -prune -exec rm -rf {} \;
apt-get purge -qy --auto-remove \
    bzip2 \
    ca-certificates \
    curl \
    g++ \
    gcc \
    libicu-dev \
    libncurses5-dev \
    libtommath-dev \
    make \
    zlib1g-dev \
    libedit-dev \
    autoconf \
    automake \
    bison \
    libatomic-ops-dev
rm -rf /var/lib/apt/lists/*

mkdir -p "${PREFIX}/skel"
mv ${VOLUME}/system/security2.fdb ${PREFIX}/skel/security2.fdb
mv "${VOLUME}/etc" "${PREFIX}/skel"

#!/bin/bash
#last update:2016-07-19

set -e
if [[ ! $# == 2 ]]; then
    echo "Usage: $0 source_path install_path"
    exit 3
fi

exist() {
    if [ ! -f $1 ];then
        echo "file $1 don't exist."
        exit 4
    fi
}

exist $1

dirname() {
    if [[ `echo $1 | grep 'bz2$' ` ]];then
        echo `basename $1 .tar.bz2`
    elif [[ `echo $1 | grep 'gz$' ` ]];then
        echo `basename $1 .tar.gz`
    else
        echo `basename $1 .tar.xz`
    fi
}

DIR=`dirname $1`
SOURCE_DIR=$1
INSTALL_DIR=$2

install() {
    yum install -y zlib-devel bzip2-devel gd-devel libpng-devel freetype libxml2-devel libjpeg-turbo-devel libcurl-devel
    tar xf ${SOURCE_DIR} -C /usr/src
    cd /usr/src/${DIR}
    ./configure --prefix=${INSTALL_DIR} \
    --with-php-config-path=${INSTALL_DIR}/etc \
    --enable-fpm \
    --with-zlib \
    --with-bz2 \
    --with-curl \
    --with-gd \
    --enable-bcmath \
    --enable-mbstring \
    --enable-mysqlnd \
    --with-pdo-mysql=mysqlnd \
    --with-mysqli=mysqlnd \
    --with-freetype-dir \
    --with-jpeg-dir \
    --with-png-dir \
    --with-zlib-dir
    make && make install
    cp /usr/src/${DIR}/php.ini-production ${INSTALL_DIR}/etc/php.ini
    cp ${INSTALL_DIR}/etc/php-fpm.conf{.default,}
    cp ${INSTALL_DIR}/etc/php-fpm.d/www.conf{.default,}
}
install

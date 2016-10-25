#!/bin/bash
#last update:2016-07-14

set -e
if [ ! $# == 3 ]; then
    echo "Usage: $0 source_path  zlib_source_path install_path"
    exit 3
fi

if [ ! -f $1 ];then
    echo "file $1 don't exist."
    exit 4
fi


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
ZDIR=`dirname $2`
SOURCE_DIR=$1
ZLIB_DIR=$2
INSTALL_DIR=$3

install()  {
    yum install -y pcre-devel zlib-devel openssl-devel
    id nginx || useradd -s /sbin/nologin -M nginx
    tar xf ${SOURCE_DIR} -C /usr/src
    tar xf ${ZLIB_DIR} -C /usr/src
    cd /usr/src/${DIR}
    ./configure --prefix=${INSTALL_DIR} \
    --user=nginx \
    --group=nginx \
    --with-threads \
    --with-file-aio \
    --with-http_ssl_module \
    --with-http_v2_module \
    --with-http_gzip_static_module \
    --with-http_auth_request_module \
    --with-stream \
    --with-stream=dynamic \
    --with-stream_ssl_module \
    --with-pcre \
    --with-zlib=/usr/src/${ZDIR}
    make && make install
    echo 'Install Completed.'
}

install

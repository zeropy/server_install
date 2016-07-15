#!/bin/bash
#last update:2016-07-15
set -e
if [ ! $# == 3 ]; then
    echo "Usage: $0 source_path install_dir data_dir"
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
SOURCE_PATH=$1
INSTALL_DIR=$2
DATA_DIR=$3

install() {
    yum install -y cmake ncurses-devel bison openssl-devel
    id mysql || useradd -s /sbin/nologin -M mysql
    tar xf ${SOURCE_PATH} -C /usr/src
    cd /usr/src/${DIR}
    if [ -f CMakeCache.txt ];then
        rm -rf CMakeCache.txt
    fi
    cmake . -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} \
    -DGRN_DEFAULT_ENCODING=utf8 \
    -DMYSQL_DATADIR=${DATA_DIR} \
    -DWITH_INNOBASE_STORAGE_ENGINE=1 \
    -DWITH_ARCHIVE_STORAGE_ENGINE=1  \
    -DWITH_BLACKHOLE_STORAGE_ENGINE=1 \
    -DWITH_FEDERATED_STORAGE_ENGINE=1 \
    -DWITH_READLINE=1 \
    -DWITH_SSL=system \
    -DWITH_ZLIB=system \
    -DENABLED_LOCAL_INFILE=1 \
    -DEXTRA_CHARSETS=all \
    -DDEFAULT_CHARSET=utf8 \
    -DDEFAULT_COLLATION=utf8_general_ci 
    make && make install
    cd ${INSTALL_DIR}
    scripts/mysql_install_db --user=mysql --datadir=${DATA_DIR}
    
}

install

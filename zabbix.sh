#!/bin/bash
#last update:2016-07-18

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

pre_install() {
    yum install -y libcurl-devel libxml2-devel net-snmp-devel mariadb-devel
    id zabbix || useradd -s /sbin/nologin -M zabbix
}
install_server() {
    tar xf ${SOURCE_DIR} -C /usr/src
    cd /usr/src/${DIR}
    ./configure --prefix=${INSTALL_DIR} \
    --enable-server \
    --enable-agent \
    --with-mysql \
    --with-nt-snmp \
    --with-libxml2 \
    --with-curl 
    make && make install
}
install_agent() {
    tar xf  ${SOURCE_DIR} -C /usr/src
    cd /usr/src/${DIR}
    ./configure --prefix=${INSTALL_DIR} \
    --enable-agent
    make && make install
}

echo -e 'Please enter the Numbers:\n
(1) Zabbix Server and Agent\n
(2) Zabbix Agent
'
read -p 'input:' NUM

case $NUM in 
    1)
        pre_install
        install_server;;
    2)
        install_agent;;
    *)
        exit 0;;
esac



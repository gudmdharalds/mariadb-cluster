#!/bin/bash

function sysexit {
        echo "ERROR: $1"
        exit 1
}

# Figure out instance (1, 2, 3 ...)
INSTANCE=$1

if [ "$INSTANCE" == "" ] ; then
        sysexit "No instance defined."
fi

if [ ! -d "/home/docker/docker-containers-data/mariadb-cluster-1/$INSTANCE/libmysql/mysql" ] ; then
        sysexit "Could not find MariaDB data."
fi

docker stop --time=1000 mariadb-cluster-1-$INSTANCE




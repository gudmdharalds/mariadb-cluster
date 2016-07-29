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

DOCKER_CONTAINERS=`docker ps|grep -v "CONTAINER ID" |grep mariadb-cluster-1-$INSTANCE | wc -l`

if [ "$DOCKER_CONTAINERS" != "0" ] ; then
	sysexit "Container already running; will not clean anything up"
fi


docker run -d --volume="/home/docker/docker-containers-data/mariadb-cluster-1/$INSTANCE/libmysql:/var/lib/mysql" -t mariadb-cluster rm -f /var/lib/mysql/mysql.sock 



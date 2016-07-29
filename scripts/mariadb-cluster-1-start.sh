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

# Find out mode, primary node or joining node
MODE=$2

# Figure out name of one container 
NODES=$3

if [ "$MODE" == "" ] ; then
        sysexit "No mode defined."

elif [ "$MODE" != "primary" ] && [ "$MODE" != "joining" ]  ; then
	sysexit "Invalid mode"
fi

if [ "$MODE" == "joining" ] && [ "$NODES" == "" ] ; then
	sysexit "Please specify a single node to join (container name only)"
fi


if [ ! -d "/home/docker/docker-containers-data/mariadb-cluster-1/$INSTANCE/libmysql/mysql" ] ; then
	sysexit "Could not find MariaDB data."
fi

if [  -S "/home/docker/docker-containers-data/mariadb-cluster-1/$INSTANCE/libmysql/mysql.sock" ] ; then
	sysexit "MariaDB Cluster appears to be running!"
fi


# 
# Figure out a name for our selves ..
#

DOCKER_CONTAINER_NAME="mariadb-cluster-1-$INSTANCE"

#
# Figure out if this instance is still running
#

RUNNING=`docker inspect $DOCKER_CONTAINER_NAME 2>/dev/null |grep "\"Running\":" |grep true`;

# Empty string means it is not running
if [ "$RUNNING" != "" ] ; then
	sysexit "It seems that docker container is running already"
fi

docker inspect $DOCKER_CONTAINER_NAME >/dev/null 2>&1

if [ $? == 0 ] ; then
	docker rename $DOCKER_CONTAINER_NAME $DOCKER_CONTAINER_NAME-`date +%s` 
fi


#
# We want one of the containers to expose 3306
# to the host-machine, for maintenance access
# and such. Only bound to localhost.
#

MYSQL_PORT_EXPOSED=`netstat -lpn 2>/dev/null |grep 3306 |grep LISTEN`;

if [ "$MYSQL_PORT_EXPOSED" == "" ] ; then
	export RUN_ARGS="--publish=127.0.0.1:3306:3306"
fi

#
# Now determinate linkage: By default, we will link
# to one node. 
#



if [ "$MODE" == "primary" ] ; then
	CONTAINERS_LINKAGE="";
	CLUSTER_ARGS="--wsrep_new_cluster --wsrep_cluster_address=gcomm://"

elif [ "$MODE" == "joining" ] ; then
	CONTAINERS_LINKAGE="--link=$NODES:$NODES";
	CLUSTER_ARGS="--wsrep_cluster_address=gcomm://$NODES"
fi

docker run $RUN_ARGS -d --volume="/home/docker/docker-containers-data/mariadb-cluster-1/$INSTANCE/libmysql:/var/lib/mysql" --volume="/home/docker/docker-containers-data/mariadb-cluster-shared-1/:/var/lib/mysql-shared" --name=$DOCKER_CONTAINER_NAME $CONTAINERS_LINKAGE -t mariadb-cluster /usr/sbin/mysqld --basedir=/usr $CLUSTER_ARGS 



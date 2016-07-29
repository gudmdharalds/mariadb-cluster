#!/bin/bash

INSTANCE=$1


if [ "$INSTANCE" == "" ] ; then
	echo "No instance defined."
	exit 1
fi


if [  -d "/home/docker/docker-containers-data/mariadb-cluster-1/$INSTANCE/libmysql/mysql" ] ; then 
	echo "ERROR: MariaDB data files exist!"
	exit 1
fi

if [  -d "/home/docker/docker-containers-data/mariadb-cluster-1/$INSTANCE/libmysql/performance_schema" ] ; then 
	echo "ERROR: MariaDB data files exist!"
	exit 1 
fi

# 
# We need to run as root when initializing,
# because otherwise cannot change permissions 
# on /var/lib/mysql and /var/lib/mysql-shared

docker run --user=root --volume="/home/docker/docker-containers-data/mariadb-cluster-1/$INSTANCE/libmysql:/var/lib/mysql" --volume="/home/docker/docker-containers-data/mariadb-cluster-shared-1/:/var/lib/mysql-shared" mariadb-cluster /bin/sh -c "chown mysql:mysql /var/lib/mysql /var/lib/mysql-shared && chown -R mysql:mysql /etc/my.cnf.d && su - mysql -s /bin/bash -c /etc/mariadb-installation-init.sh ; chown -R root:root /etc/my.cnf.d "



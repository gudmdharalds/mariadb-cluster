
Dockerfile for MariaDB-cluster running on CentOS 7.1
===

* Uses CentOS 7.1 as base
* Dockerizes MariaDB, ready to be launched as primary node or joining node in a cluster
* Scripts to initialize new nodes, start and stop nodes
* Assumes data is stored in `/home/docker/docker-containers-data/mariadb-cluster-1`
* Allows multiple instances of MariaDB to run (numbered 1, 2, 3, etc.)
* MariaDB will be accessible from the local machine (`127.0.0.1:3306`)
* MariaDB root-password will be available in `~docker/mariadb-cluster-shared-1`

Note that these Dockerfiles are not meant to be bullet-proof, nor to be used in high-availability environments. Rather, they are intended for those who would like to build something more with MariaDB, and like to use CentOS.

Starting a new cluster
===

The following sequence of commands will initialize a cluster with three nodes. These commands all assume that they are run as the `docker` user. They also assume that all the `Dockerfile`-files have been built, and that the `scripts` folder is accessible in ~/scripts.

```
$ mkdir -p docker-containers-data 
$ cd docker-containers-data 
$ mkdir -p mariadb-cluster-1/1/libmysql mariadb-cluster-1/2/libmysql mariadb-cluster-1/3/libmysql mariadb-cluster-shared-1
$ ./scripts/mariadb-cluster-1-init.sh 1
$ ./scripts/mariadb-cluster-1-init.sh 2
$ ./scripts/mariadb-cluster-1-init.sh 3
$ ./scripts/mariadb-cluster-1-start.sh 1 primary
$ sleep 30
$ ./scripts/mariadb-cluster-1-start.sh 2 joining mariadb-cluster-1-1
$ sleep 30
$ ./scripts/mariadb-cluster-1-start.sh 3 joining mariadb-cluster-1-1
```

This is of course not very useful, as these three nodes would all live on the same Docker-instance and the same machine. If docker crashes, the machine or the OS, the MariaDB cluster will go with it and your fancy DB will have to be revived. To get redundancy, you will have to run each MariaDB instance on a different host machine - which means more configuration, and more to set-up. 



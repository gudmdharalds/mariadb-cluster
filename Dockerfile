#
# Use CentOS 7.1 as base
#

FROM centos:7.1.1503

# Needed to make things work
RUN yum swap -y fakesystemd systemd && \
    yum install -y systemd-devel

# Update system
# While tempting, do not remove this:
# You need your systems to run up-to-date software.
RUN yum makecache fast && \
    yum update -y && \
    yum clean all

# Specify maintainer
MAINTAINER Gudmundur Haraldsson <gudm.d.haralds@gmail.com>

VOLUME ["/var/lib/mysql"]
VOLUME ["/var/lib/mysql-shared"]

# Add MariaDB repo and PGP key
ADD mariadb-galera.repo /etc/yum.repos.d/
ADD RPM-GPG-KEY-MariaDB /etc/pki/rpm-gpg/

# Install the packages we need - MariaDB and such
RUN yum install -y coreutils libstdc++ gettext-common-devel libxml2-devel xmlsec1-devel libffi-devel telnet net-tools iproute iputils hostname psmisc 

# Install galera (rsync is expected by galera) 
RUN yum install -y mariadb-devel mariadb-libs mariadb MariaDB-server MariaDB-client galera rsync 

# And add our installation script 
ADD mariadb-installation-init.sh /etc/

# Then our custom server config
ADD server.cnf /etc/my.cnf.d/

# Add a symbolic link to this configuration file
# which resides in the shared-area of this particular
# cluster. It will be resolvable when the first
# node of the cluster has initialized this file.
RUN cd /etc/my.cnf.d/ && ln -s /var/lib/mysql-shared/server-99-sst-auth.cnf .

# Make mysql owner of all of these folders - the
# MariaDB server has to be able to write to these.
RUN chown mysql:mysql /var/lib/mysql/ /var/lib/mysql-shared/ 

USER mysql

EXPOSE 3306 4567

CMD ["/bin/bash"]

FROM centos:7

#### install basic packages ####
RUN yum install -y epel-release
RUN  yum install -y apt-utils apt-transport-https unixodbc unixodbc-dev wget sudo \
                       python python-psutil python-requests python-jsonschema \
                       libssl-dev super lsof postgresql odbc-postgresql libjson-perl gnupg \
                       vim rsyslog g++ dpkg-dev cdbs libcurl4-openssl-dev \
                       tig git libpam0g-dev libkrb5-dev libfuse-dev \
                       libbz2-dev libxml2-dev zlib1g-dev python-dev \
                       make gcc help2man telnet ftp udt

RUN yum install -y python3 \
    python3-distro \
    python3-psutil \
    python3-jsonschema \
    python3-requests \
    python3-pip \
    python3-pyodbc

#### Get and install globus repo ####
RUN wget -q https://downloads.globus.org/globus-connect-server/stable/installers/repo/rpm/globus-repo-latest.noarch.rpm
RUN rpm --force -i globus-repo-latest.noarch.rpm

#### Install and configure globus specific things ####
RUN yum install -y globus-gridftp-server-progs \
    globus-simple-ca \
    globus-gass-copy-progs \
    libglobus-common-dev \
    libglobus-gridftp-server-dev \
    libglobus-gridmap-callout-error-dev \
    globus-gsi-cert-utils-progs \
    globus-proxy-utils

RUN mkdir /iRODS_DSI
RUN chmod 777 /iRODS_DSI

#### Get and install iRODS repo ####
RUN rpm --import https://packages.irods.org/irods-signing-key.asc
RUN wget -qO - https://packages.irods.org/renci-irods.yum.repo --no-check-certificate | tee /etc/yum.repos.d/renci-irods.yum.repo

#### Install iRODS ####
ARG irods_version
ENV IRODS_VERSION ${irods_version}

RUN yum install -y irods-server-${irods_version} irods-dev-${irods_version} irods-database-plugin-postgres-${irods_version} irods-runtime-${irods_version} irods-icommands-${irods_version}

RUN yum install -y 'irods-externals*'

#### Install irods-gridftp-client ####
RUN yum install -y irods-gridftp-client

#### Set up ICAT database. ####
ADD db_commands.txt /
RUN yum install -y postgresql-server postgresql-contrib
RUN su - postgres -c "pg_ctl initdb"
RUN su - postgres -c "/usr/bin/pg_ctl -D /var/lib/pgsql/data -l logfile start && sleep 1 && psql -f /db_commands.txt"

ADD start.globus.centos7.sh /
RUN chmod u+x /start.globus.centos7.sh

ENTRYPOINT "/start.globus.centos7.sh"


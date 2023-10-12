FROM almalinux:8

RUN \
  yum update -y && \
  yum install -y \
    pam-devel \
    python3-jsonschema \
    authd \
    epel-release \
    gcc-c++ \
    gnupg \
    make \
    python3 \
    python3-pip \
    rsyslog \
    sudo \
    unixODBC-devel \
    wget \
    which \
    diffutils \
    procps \
    rpm-build \
  && \
  yum clean all && \
  rm -rf /var/cache/yum /tmp/*

# python 2 and 3 must be installed separately because yum will ignore/discard python2
RUN \
  yum check-update -q >/dev/null || { [ "$?" -eq 100 ] && yum update -y; } && \
  yum install -y \
    python3 \
    python3-devel \
    python3-pip \
  && \
  yum clean all && \
  rm -rf /var/cache/yum /tmp/*

RUN python3 -m pip install xmlrunner distro psutil pyodbc jsonschema requests

RUN rpm --import https://packages.irods.org/irods-signing-key.asc && \
    wget -qO - https://packages.irods.org/renci-irods.yum.repo | tee /etc/yum.repos.d/renci-irods.yum.repo

RUN rpm --import https://core-dev.irods.org/irods-core-dev-signing-key.asc && \
    wget -qO - https://core-dev.irods.org/renci-irods-core-dev.yum.repo | tee /etc/yum.repos.d/renci-irods-core-dev.yum.repo

COPY rsyslog.conf /etc/rsyslog.conf

#### install basic packages ####
#RUN yum update -y && yum install -y epel-release
#RUN  yum install -y apt-utils apt-transport-https unixODBC unixODBC-devel wget sudo \
#                       python python-psutil python-requests python-jsonschema \
#                       libssl-devel super lsof postgresql odbc-postgresql libjson-perl gnupg \
#                       vim rsyslog g++ dpkg-devel cdbs libcurl4-openssl-devel \
#                       tig git libpam0g-devel libkrb5-devel libfuse-devel \
#                       libbz2-devel libxml2-devel zlib1g-devel python-devel \
#                       make gcc help2man telnet ftp udt

#### Get and install globus repo ####
RUN wget -q https://downloads.globus.org/globus-connect-server/stable/installers/repo/rpm/globus-repo-latest.noarch.rpm
RUN rpm --force -i globus-repo-latest.noarch.rpm

#### Install and configure globus specific things ####
RUN yum install -y globus-gridftp-server-progs \
    globus-simple-ca \
    globus-gass-copy-progs \
    globus-gsi-cert-utils-progs \
    globus-proxy-utils

RUN yum --disablerepo epel install -y globus-common-devel \
    globus-gridftp-server-devel \
    globus-gridmap-callout-error-devel


RUN mkdir /iRODS_DSI
RUN chmod 777 /iRODS_DSI

#### Install iRODS ####
ARG irods_version
ENV IRODS_VERSION ${irods_version}

RUN yum install -y irods-server-${irods_version} irods-devel-${irods_version} irods-database-plugin-postgres-${irods_version} irods-runtime-${irods_version} irods-icommands-${irods_version}

RUN yum install -y 'irods-externals*'

#### Install irods-gridftp-client ####
#RUN yum install -y irods-gridftp-client

#### Set up ICAT database. ####
ADD db_commands.txt /
RUN yum install -y postgresql-server postgresql-contrib
RUN su - postgres -c "pg_ctl initdb"
RUN su - postgres -c "/usr/bin/pg_ctl -D /var/lib/pgsql/data -l logfile start && sleep 1 && psql -f /db_commands.txt"

ADD start.globus.almalinux8.sh /
RUN chmod u+x /start.globus.almalinux8.sh

ENTRYPOINT "/start.globus.almalinux8.sh"


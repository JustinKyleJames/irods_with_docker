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

#### Get and install iRODS repo ####
RUN rpm --import https://packages.irods.org/irods-signing-key.asc
RUN wget -qO - https://packages.irods.org/renci-irods.yum.repo --no-check-certificate | tee /etc/yum.repos.d/renci-irods.yum.repo

#### Install iRODS ####
ARG irods_version
ENV IRODS_VERSION ${irods_version}

RUN yum install -y irods-server-${irods_version} irods-dev-${irods_version} irods-database-plugin-postgres-${irods_version} irods-runtime-${irods_version} irods-icommands-${irods_version}

RUN yum install -y 'irods-externals*'

#### Set up ICAT database. ####
ADD db_commands.txt /
RUN yum install -y postgresql-server postgresql-contrib
RUN su - postgres -c "pg_ctl initdb"
RUN su - postgres -c "/usr/bin/pg_ctl -D /var/lib/pgsql/data -l logfile start && sleep 1 && psql -f /db_commands.txt"

ADD start.centos7.sh /
RUN chmod u+x /start.centos7.sh

ADD setup_s3_resc.sh /

ENTRYPOINT "/start.centos7.sh"


FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ARG APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=true

#### install basic packages ####

# For Postgres 14
RUN apt-get update && apt-get install -y wget lsb-release gnupg gnupg2 gnupg1 
RUN sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

RUN apt-get update && \
    apt-get install -y apt-utils apt-transport-https unixodbc unixodbc-dev wget lsb-release sudo \
                       postgresql-14 \
                       libssl-dev super lsof libjson-perl gnupg \
                       vim sudo rsyslog g++ dpkg-dev cdbs libcurl4-openssl-dev \
                       tig git libpam0g-dev libkrb5-dev libfuse-dev \
                       libbz2-dev libxml2-dev zlib1g-dev \
                       make gcc help2man telnet ftp

RUN apt-get install -y python3 \
    python3-distro \
    python3-psutil \
    python3-jsonschema \
    python3-requests \
    python3-pip \
    python3-pyodbc \
    python3-dev

#### Get and install globus repo ####
RUN wget -q https://downloads.globus.org/globus-connect-server/stable/installers/repo/deb/globus-repo_latest_all.deb
RUN dpkg -i globus-repo_latest_all.deb
RUN apt-get update

#### Install and configure globus specific things ####
RUN apt-get install -y globus-gridftp-server-progs \
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
RUN wget -qO - https://packages.irods.org/irods-signing-key.asc | sudo apt-key add -
RUN echo "deb [arch=amd64] https://packages.irods.org/apt/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/renci-irods.list
RUN apt-get update

#### Install iRODS ####
ARG irods_version
ENV IRODS_VERSION ${irods_version}

RUN apt-get install -y irods-server=${irods_version} irods-dev=${irods_version} irods-database-plugin-postgres=${irods_version} irods-runtime=${irods_version} irods-icommands=${irods_version}

RUN apt-get install -y 'irods-externals*'

#### Install irods-gridftp-client ####
#RUN apt-get install -y irods-gridftp-client

#### Set up ICAT database. ####
ADD db_commands.txt /
RUN service postgresql start && su - postgres -c 'psql -f /db_commands.txt'

ADD start.globus.ubuntu22.sh /
RUN chmod u+x /start.globus.ubuntu22.sh

ENTRYPOINT "/start.globus.ubuntu22.sh"

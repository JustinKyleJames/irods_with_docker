#!/bin/bash

usage() {
cat <<_EOF_
Usage: ./build_image_with_globus.sh [OPTIONS]...

Builds a new docker image with globus installed and configured

Example:

    ./build_image_with_globus.sh --os-type <arg> --irods-version <arg> ...

Available options:

    --os-type (required)                    The OS type.  One of centos|centos7|ubuntu|ubuntu18|ubuntu20|ubuntu22|alma|alma8|almalinux8|debian11|debian12|el9
    --irods-version                         The version of irods - example 4.2.11, 4.3.0, etc.
    -h, --help                              This message

_EOF_
    exit
}

# TODO rename to *.Dockerfile

while [ -n "$1" ]; do
    case "$1" in
        --os-type )
            shift
            case "$1" in
                ubuntu | ubuntu18 )
                    dockerfile=globus.ubuntu18.Dockerfile
                    image=ubuntu_18_with_globus_irods
                    version_extension="~bionic"
                    globus_package_version_extension="-1"
                    ;;
                ubuntu20 )
                    dockerfile=globus.ubuntu20.Dockerfile
                    image=ubuntu_20_with_globus_irods
                    version_extension="~focal"
                    globus_package_version_extension="-1"
                    ;;
                ubuntu22 )
                    dockerfile=globus.ubuntu22.Dockerfile
                    image=ubuntu_22_with_globus_irods
                    version_extension="~jammy"
                    globus_package_version_extension="-1"
                    ;;
                debian11 )
                    dockerfile=globus.debian11.Dockerfile
                    image=debian_11_with_globus_irods
                    version_extension="~bullseye"
                    globus_package_version_extension="-1"
                    ;;
                debian12 )
                    dockerfile=globus.debian12.Dockerfile
                    image=debian_12_with_globus_irods
                    version_extension="~bookworm"
                    globus_package_version_extension="-1"
                    ;;
                centos | centos7 )
                    dockerfile=globus.centos7.Dockerfile
                    image=centos7_with_globus_irods
                    version_extension=".el7"
                    globus_package_version_extension="-1"
                    ;;
                alma | alma8 | almalinux8 )
                    dockerfile=globus.almalinux8.Dockerfile
                    image=almalinux8_with_globus_irods
                    version_extension=".el8"
                    globus_package_version_extension="-1"
                    ;;
                el9 )
                    dockerfile=globus.el9.Dockerfile
                    image=el9_with_globus_irods
                    version_extension=".el9"
                    globus_package_version_extension="-1"
                    ;;
                * )
                    echo os type set to $1
                    usage
                    ;;
            esac
            ;;
        --irods-version )
            shift
            irods_version=${1}

            ;;
        -h | --help)
            usage
            ;;
    esac
    shift
done


if [ -z "$dockerfile" ]; then
    usage
fi

if [ -z "${irods_version}" ]; then
    irods_version="4.3.0"
fi

case "$irods_version" in
    4.2.8 | 4.2.9 | 4.2.10 )
        irods_repo_version=$irods_version
        ;;
    4.2.11 | 4.2.12 | 4.3.0 ) #| 4.3.1 )
        irods_repo_version=${irods_version}-1${version_extension}
        ;;
    4.3.1 )
        irods_repo_version=${irods_version}-0${version_extension}
        ;;
    4.3.2 )
        irods_repo_version=${irods_version}-0${version_extension}
        ;;
    * )
        usage
        ;;
esac

#irods_version_cleaned=`echo $irods_version | sed 's|\([^~]\+\).*|\1|g'`
image="${image}_${irods_version}"
build_args="$build_args --build-arg irods_version=${irods_repo_version}"

set -x
docker build -f $dockerfile -t $image $build_args .
set +x

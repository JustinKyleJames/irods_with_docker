#!/bin/bash

usage() {
cat <<_EOF_
Usage: ./build_image_with_globus.sh [OPTIONS]...

Builds a new docker image with globus installed and configured

Example:

    ./build_image_with_globus.sh --os_type <arg> --irods-version <arg> ...

Available options:

    --os_type (required)                    The OS type.  One of centos|centos7|ubuntu|ubuntu14|ubuntu16.
    --irods-version                         The version of irods - example 4.2.11, 4.3, etc.
    -h, --help                              This message

_EOF_
    exit
}

# TODO rename to *.Dockerfile

while [ -n "$1" ]; do
    case "$1" in
        --os_type )
            shift
            case "$1" in
                ubuntu | ubuntu18 )
                    dockerfile=globus.ubuntu18.Dockerfile
                    image=ubuntu_18_with_globus_irods
                    version_extension="-1~bionic"
                    globus_package_version_extension="-1"
                    ;;
                ubuntu20 )
                    dockerfile=globus.ubuntu20.Dockerfile
                    image=ubuntu_20_with_globus_irods
                    version_extension="-1~focal"
                    globus_package_version_extension="-1"
                    ;;
                centos | centos7 )
                    dockerfile=globus.centos7.Dockerfile
                    image=centos7_with_globus_irods
                    version_extension="-1"
                    globus_package_version_extension="-1"
                    ;;
                * )
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
    4.2.11 | 4.3.0 )
        irods_repo_version=${irods_version}${version_extension}
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

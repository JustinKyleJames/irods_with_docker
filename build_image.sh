#!/bin/bash

usage() {
cat <<_EOF_
Usage: ./build_image.sh [OPTIONS]...

Builds a new docker image with irods

Example:

    ./build_image.sh --os-type <arg> --irods-version <arg> ...

Available options:

    --os-type (required)                    The OS type.  One of centos|centos7|ubuntu|ubuntu14|ubuntu16.
    --irods-version                         The version of irods - example 4.2.11, 4.3.0, etc.
    -h, --help                              This message

_EOF_
    exit
}

while [ -n "$1" ]; do
    case "$1" in
        --os-type )
            shift
            case "$1" in
                ubuntu | ubuntu18 )
                    echo "os-type is " $1
                    dockerfile=ubuntu18.Dockerfile
                    image=ubuntu_18_with_irods
                    version_extension="~bionic"
                    ;;
                ubuntu20 )
                    dockerfile=ubuntu20.Dockerfile
                    image=ubuntu_20_with_irods
                    version_extension="~focal"
                    ;;
                ubuntu22 )
                    dockerfile=ubuntu22.Dockerfile
                    image=ubuntu_22_with_irods
                    version_extension="~jammy"
                    ;;
                centos | centos7 )
                    dockerfile=centos7.Dockerfile
                    image=centos7_with_irods
                    version_extension="-1"
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
    irods_version="4.3.2"
fi

case "$irods_version" in
    4.2.8 | 4.2.9 | 4.2.10 )
        irods_repo_version=$irods_version
        ;;
    4.2.11 | 4.2.12 | 4.3.0 )
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

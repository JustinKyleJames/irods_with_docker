#!/bin/bash

usage() {
cat <<_EOF_
Usage: ./create_test_instance_globus.sh [OPTIONS]...

Creates a docker instance with globus installed and configured

Example:

    ./create_test_instance_globus.sh --os-type <arg> --irods-version <arg> ...

Available options:

    --os-type (required)                    The OS type.  One of centos|centos7|ubuntu|ubuntu18|ubuntu20|ubuntu22|alma|alma8|almalinux8|debian11|debian12|el9
    --irods-version                         The version of irods - example 4.2.11, 4.3, etc.
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
                    image=ubuntu_18_with_globus_irods
                    ;;
                ubuntu20 )
                    image=ubuntu_20_with_globus_irods
                    ;;
                ubuntu22 )
                    image=ubuntu_22_with_globus_irods
                    ;;
                debian11 )
                    image=debian_11_with_globus_irods
                    ;;
                debian12 )
                    image=debian_12_with_globus_irods
                    ;;
                centos | centos7 )
                    image=centos7_with_globus_irods
                    ;;
                alma | alma8 | almalinux8 )
                    image=almalinux8_with_globus_irods
                    ;;
                el9 )
                    image=el9_with_globus_irods
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

if [ -z "${image}" ]; then
    usage
fi

if [ -z "${irods_version}" ]; then
    irods_version="4.3.0"
fi

#irods_version_cleaned=`echo $irods_version | sed 's|\([^~]\+\).*|\1|g'`
image="${image}_${irods_version}"

id=`docker run --name testing_$image -dti -v /home/diskb:/diskb -v /home/jjames/github:/github -v /var/run/docker.sock:/var/run/docker.sock $image`
docker exec -it $id /bin/bash

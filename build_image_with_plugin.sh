#!/bin/bash

usage() {
cat <<_EOF_
Usage: ./build_image_with_plugin.sh [OPTIONS]...

Builds a new docker image with a plugin installed 

Example:

    ./build_image_with_plugin.sh --os_type <arg> --plugin-repo <arg> --plugin-branch <arg> ...

Available options:

    --os_type (required)                    The OS type.  One of centos|centos7|ubuntu|ubuntu14|ubuntu16.
    --plugin-repo                           Repo for the iRODS plugin 
    --plugin-branch (requires plugin-repo)  Branch for the iRODS plugin 
    -h, --help                              This message

_EOF_
    exit
}


while [ -n "$1" ]; do
    case "$1" in
        --os_type )
            shift
            case "$1" in
                ubuntu | ubuntu16 )
                    dockerfile=Dockerfile.ubuntu16
                    image=ubuntu_16_with_irods_42
                    ;;
                ubuntu14 )
                    dockerfile=Dockerfile.ubuntu14
                    image=ubuntu_14_with_irods_42
                    ;;
                centos | centos7 )
                    dockerfile=Dockerfile.centos7
                    image=centos7_with_irods_42
                    ;;
                * )
                    usage
                    ;;
            esac
            ;;
        --plugin-repo )
            shift
            plugin_repo=${1}
            ;;
        --plugin-branch )
            shift
            plugin_branch=${1}
            ;;
        -h | --help)
            usage
            ;;
    esac
    shift
done

if [ ! -z "$plugin_repo" ]; then
    repo_type=`echo $plugin_repo | sed 's|.*/||'`
    build_args="$build_args --build-arg plugin_repo=${plugin_repo}"
    if [ ! -z "$plugin_branch" ]; then
        build_args="$build_args --build-arg plugin_branch=${plugin_branch}"
        image="${image}_${repo_type}_${plugin_branch}"
    else 
        build_args="$build_args --build-arg plugin_branch=master"
        image="${image}_${repo_type}_master"
    fi
else
    if [ ! -z "$plugin_branch" ]; then
        usage
    fi
fi

if [ -z "$dockerfile" ]; then
    usage
fi

set -x
docker build -f $dockerfile -t $image $build_args .
set +x

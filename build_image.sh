case $1 in
    ubuntu | ubuntu16 )
        dockerfile=Dockerfile.ubuntu16
        image=ubuntu_16_with_irods_42
        ;;
    ubuntu14 )
        dockerfile=Dockerfile.ubuntu14
        image=ubuntu_14_with_irods_42
        ;;
    ubuntu18 )
        dockerfile=Dockerfile.ubuntu18
        image=ubuntu_18_with_irods_42
        ;;
    centos | centos7 )
        dockerfile=Dockerfile.centos7
        image=centos7_with_irods_42
        ;;
    *)
        echo "First arg must be centos|centos7|ubuntu|ubuntu14|ubuntu16."
        exit 1
        ;;
esac

docker build -f $dockerfile -t $image .

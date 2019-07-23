case $1 in
    ubuntu | ubuntu16 )
        image=ubuntu_16_with_irods_42
        ;;
    ubuntu14 )
        image=ubuntu_14_with_irods_42
        ;;
    centos | centos7 )
        image=centos7_with_irods_42
        ;;
    *)
        echo "First arg must be centos|centos7|ubuntu|ubuntu16, others coming soon..."
        exit 1
        ;;
esac

id=`docker run -dti -v /home/jjames/github:/github $image`
docker exec -it $id /bin/bash


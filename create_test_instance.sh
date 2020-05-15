case $1 in
    ubuntu | ubuntu16 )
        image=ubuntu_16_with_irods_42
        ;;
    ubuntu14 )
        image=ubuntu_14_with_irods_42
        ;;
    ubuntu18 )
        image=ubuntu_18_with_irods_42
        ;;
    centos | centos7 )
        image=centos7_with_irods_42
        ;;
    *)
        image=$1
        ;;
esac

id=`docker run -dti -v /home/jjames/github:/github $image`
docker exec -it $id /bin/bash


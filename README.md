# irods_with_docker
Scripts to create instances of iRODS with docker

## Steps

1.  Put keys in amazon.keypair
2.  Build Image: 
```
./build_image.sh <ubuntu14|ubuntu16|centos7>
```

3.  To create test instances:  
```
./create_test_instances.sh <ubuntu14|ubuntu16|centos7>
```

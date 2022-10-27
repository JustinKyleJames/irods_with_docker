# irods_with_docker
Scripts to create instances of iRODS with docker

## Steps

1.  Put keys in amazon.keypair
2.  Build Image:
```
./build_image.sh --os_type <arg> --irods-version <arg>
```

3.  To create test instances:
```
./create_test_instance.sh --os_type <arg> --irods-version <arg>
```

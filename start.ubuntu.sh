#! /bin/bash

# Start the Postgres database.
service postgresql start
counter=0
until pg_isready -q
do
    sleep 1
    ((counter += 1))
done
echo Postgres took approximately $counter seconds to fully start ...

# Set up iRODS.
python /var/lib/irods/scripts/setup_irods.py < /var/lib/irods/packaging/localhost_setup_postgres.input

cp /setup_s3_resc.sh /var/lib/irods/setup_s3_resc.sh
chown irods:irods /var/lib/irods/setup_s3_resc.sh
chmod u+x /var/lib/irods/setup_s3_resc.sh

cp /cleanup.sh /var/lib/irods/cleanup.sh
chown irods:irods /var/lib/irods/cleanup.sh
chmod u+x /var/lib/irods/cleanup.sh

cp /amazon.keypair /var/lib/irods
chown irods:irods /var/lib/irods/amazon.keypair

#dpkg -i /irods-resource-plugin-s3*.deb

if [ ! -z "$PLUGIN_REPO" ]; then
    repo_name=`echo $PLUGIN_REPO | sed 's|.*/||'`
    git clone $PLUGIN_REPO
    cd $repo_name
    if [ ! -z "$PLUGIN_BRANCH" ]; then
        git checkout $PLUGIN_BRANCH
    fi
    mkdir bld
    cd bld
    /opt/irods-externals/cmake3.11.4-0/bin/cmake ..
    make -j5 package
    dpkg -i *.deb
fi

cd /

# Keep container running if the test fails.
tail -f /dev/null

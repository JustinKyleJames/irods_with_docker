#! /bin/bash

# Start the Postgres database.
if [ ! -d /run/postgresql ]; then

    mkdir /run/postgresql
    chown postgres:postgres /run/postgresql
fi

# Start the Postgres database.
su - postgres -c 'pg_ctl start'
counter=0
until su - postgres -c "psql ICAT -c '\d'"; do
   sleep 1
   ((counter += 1))
done

echo Postgres took approximately $counter seconds to fully start ...

#### Set up iRODS ####
python3 /var/lib/irods/scripts/setup_irods.py < /var/lib/irods/packaging/localhost_setup_postgres.input

#### Start iRODS ####
su - irods -c '/var/lib/irods/irodsctl start'

#### Create user1 in iRODS ####
sudo -H -u irods bash -c "iadmin mkuser user1 rodsuser"
sudo -H -u irods bash -c "iadmin moduser user1 password user1"

#### Give root an environment to connect to iRODS ####
echo 'localhost
1247
rods
tempZone
rods' | iinit

#### Add user1 as a local user for testing ####
useradd user1 -m

cp /setup_s3_resc.sh /var/lib/irods/setup_s3_resc.sh
chown irods:irods /var/lib/irods/setup_s3_resc.sh
chmod u+x /var/lib/irods/setup_s3_resc.sh

cp /cleanup.sh /var/lib/irods/cleanup.sh
chown irods:irods /var/lib/irods/cleanup.sh
chmod u+x /var/lib/irods/cleanup.sh

mkdir -p /projects/irods/vsphere-testing/externals/
cp /amazon.keypair /projects/irods/vsphere-testing/externals/amazon_web_services-CI.keypair
cp /amazon.keypair /var/lib/irods/amazon.keypair
chown irods:irods /var/lib/irods/amazon.keypair

cd /

#### Keep container running ####
tail -f /dev/null

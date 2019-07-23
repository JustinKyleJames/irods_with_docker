#! /bin/bash

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

rpm -i irods-resource-plugin-s3-2.6.0-1.x86_64.rpm

# Keep container running
exec /usr/sbin/init


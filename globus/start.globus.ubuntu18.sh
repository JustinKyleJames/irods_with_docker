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

#### Set up iRODS ####
irods_version=`apt show irods-server 2>/dev/null | grep Version`
if [[ $irods_version == "Version: 4.3"* ]]; then
    python3 /var/lib/irods/scripts/setup_irods.py < /var/lib/irods/packaging/localhost_setup_postgres.input
else
    python /var/lib/irods/scripts/setup_irods.py < /var/lib/irods/packaging/localhost_setup_postgres.input
fi

#### Start iRODS ####
service irods start

#### Create user1 in iRODS ####
sudo -H -u irods bash -c "iadmin mkuser user1 rodsuser"
sudo -H -u irods bash -c "iadmin moduser user1 password user1"

#### Give root an environment to connect to iRODS ####
echo 'localhost
1247
rods
tempZone
rods' | iinit

iadmin mkresc resc1 unixfilesystem `hostname`:/tmp/resc1
iadmin mkresc resc2 unixfilesystem `hostname`:/tmp/resc2

#### configure globus certs ####
# the folowing seems to be automatic now
# sudo grid-ca-create -noint  # puts files in /etc/grid-security/certificates

# this seems required to run grid-cert-request
mkdir /var/adm
touch /var/adm/wtmp
touch /var/log/messages

HEX_ID=$(ls /etc/grid-security/certificates/*.0 | cut -d/ -f5 | cut -d. -f1)
sed -i 's|= policy_match|= policy_anything|g' /etc/grid-security/certificates/globus-host-ssl.conf.${HEX_ID}
sed -i 's|cond_subjects     globus       .*|cond_subjects     globus       '"'"'"*"'"'"'|g' /etc/grid-security/certificates/${HEX_ID}.signing_policy
grid-cert-request -ca ${HEX_ID} -nopw -cn `hostname` -force # creates ~/.globus/usercert.pem usercert_request.pem userkey.pem
cp ~/.globus/userkey.pem /etc/grid-security/hostkey.pem
cp /etc/grid-security/certificates/${HEX_ID}.0 ~/.globus/${HEX_ID}.0
cp /etc/grid-security/certificates/${HEX_ID}.signing_policy ~/.globus/${HEX_ID}.signing_policy
echo globus  | grid-ca-sign -in ~/.globus/usercert_request.pem -out hostcert.pem  # sign the cert
cp hostcert.pem /etc/grid-security/hostcert.pem
cp hostcert.pem ~/.globus/usercert.pem

#### Set up grid-mapfile ####
subject=`openssl x509 -noout -in /etc/grid-security/hostcert.pem -subject | cut -d'=' -f2- | sed -e 's|,|/|g' | sed -e 's|/ |/|g' | sed -e 's/ = /=/g'`
echo "\"/$subject\" rods" | sudo tee -a /etc/grid-security/grid-mapfile

#### Add user1 as a local user for testing ####
useradd user1 -m

#### Set up /etc/gridftp.conf also allowing user1 to user anonymous ftp ####
echo 'port 2811
$LD_LIBRARY_PATH "$LD_LIBRARY_PATH:/iRODS_DSI"
$irodsConnectAsAdmin "rods"
$spOption irods_client_globus_connector
$numberOfIrodsReadWriteThreads 3
$irodsParallelFileSizeThresholdBytes 33554432
$spOption irods_client_globus_connector
$irodsResourceMap "/etc/resource_mapfile"

load_dsi_module iRODS
auth_level 4

allow_anonymous 1
anonymous_names_allowed user1
anonymous_user user1
' | tee -a /etc/gridftp.conf

#### Create a resource_mapfile ####
echo '/tempZone/home/rods/dir1;resc1
/tempZone/home/rods/dir2;resc2' > /etc/resource_mapfile

#### Start gridftp server ####
/usr/sbin/globus-gridftp-server -allow-root -log-module stdio:buffer=0 -threads 1 -aa -c /etc/gridftp.conf -pidfile /var/run/globus-gridftp-server.pid -log-level trace,info,warn,error -logfile /var/log/gridftp.log -no-detach -config-base-path / &

cd /

#### Keep container running ####
tail -f /dev/null

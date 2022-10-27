set -x

iadmin modresc demoResc host `hostname`

users='issue_3104_user otherrods alice bobby issue_3620_user tmpuser irodsauthuser'

for user in $users; do
    ichmod -M -r own rods /tempZone/home/${user}
    ichmod -M -r own rods /tempZone/trash/home/${user}
done

irm -f /tempZone/home/otherrods/file1.txt
irm -f /tempZone/home/otherrods/f1

users='issue_3104_user otherrods alice bobby issue_3620_user'

for user in $users; do
    files=`ils /tempZone/home/${user} | grep 'C-' | cut -d ' ' -f4`
    for file in $files; do
        irm -rf $file
    done
    iadmin rmuser $user
done

for user in $users; do
    files=`ils /tempZone/trash/home/${user} | grep 'C-' | cut -d ' ' -f4`
    for file in $files; do
        irm -rf $file
    done
    iadmin rmuser $user
done

files=`ils /tempZone/home/public | tail -n +2`
for file in $files; do
    ichmod -M own rods /tempZone/home/public/$file
    irm -rf /tempZone/home/public/$file
done

iadmin rmresc pydevtest_AnotherResc
iadmin rmresc pydevtest_TestResc
iadmin rmresc TestResc 
iadmin rmresc DemoResc 
iadmin rmresc AnotherResc 

iadmin rmchildfromresc pt_b leaf_b 
iadmin rmchildfromresc pt_c2 leaf_c 
iadmin rmchildfromresc pt_c1 pt_c2 
iadmin rmchildfromresc repl leaf_a 
iadmin rmchildfromresc repl pt_b 
iadmin rmchildfromresc repl pt_c1 
iadmin rmchildfromresc pt repl

iadmin rmchildfromresc demoResc archiveResc
iadmin rmchildfromresc demoResc cacheResc 
iadmin rmresc archiveResc
iadmin rmresc cacheResc


iadmin rmresc pt
iadmin rmresc repl 
iadmin rmresc leaf_a 
iadmin rmresc pt_b
iadmin rmresc leaf_b 
iadmin rmresc pt_c1
iadmin rmresc pt_c2
iadmin rmresc leaf_c 

# if origResc exists delete demoResc and move origResc to demoResc
ilsresc origResc
if [ "$?" -eq "0" ]; then
    iadmin rmresc demoResc
    echo y | iadmin modresc origResc name demoResc
fi

echo y | iadmin modresc origResc name demoResc
set +x


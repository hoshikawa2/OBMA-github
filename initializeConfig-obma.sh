#!/bin/bash
rm -f /flexcube.sh
su - gsh

touch /domainsDetails.properties
echo "ds.jdbc.new.1=$1" > domainsDetails.properties
echo "ds.password.new.1=$2" >> domainsDetails.properties

# download Flexcube-Package
wget https://objectstorage.us-ashburn-1.oraclecloud.com/p/PovKu2TRLV0wjcwABGxMu4FzOYEEtbB_wuaP9maFTAWebpN-go-3Z9pOjYvcO85l/n/id3kyspkytmr/b/bucket_banco_conceito/o/Flexcube-Package-obma.zip
mv Flexcube-Package-obma.zip /
cd /
unzip /Flexcube-Package-obma.zip
sh /flexcube.sh
chown gsh:gsh /config.xml
mv /config.xml /scratch/gsh/obma144/user_projects/domains/obma/config/config.xml

sh /JDBCReplace.sh /JDBCList $1 $2
sh /ExecuteWebLogic.sh
sleep 180
sh /StartApps.sh


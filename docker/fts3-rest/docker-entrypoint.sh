#!/bin/bash -e

if ! whoami &> /dev/null; then
  if [ -w /etc/passwd ]; then
    echo "${USER_NAME:-default}:x:$(id -u):0:${USER_NAME:-default} user:${HOME}:/sbin/nologin" >> /etc/passwd
  fi
fi

# Mounting the secrets that we have as files
echo ">> Secrets and Configs Manipulation <<"
cp /opt/fts3/fts3-host-pems/hostcert.pem /etc/grid-security/
cp /opt/fts3/fts3-host-pems/hostcert.pem /etc/pki/tls/certs/localhost.crt
chmod 644 /etc/grid-security/hostcert.pem
chmod 644 /etc/pki/tls/certs/localhost.crt
chown root:root /etc/grid-security/hostcert.pem
chown root:root /etc/pki/tls/certs/localhost.crt

cp /opt/fts3/fts3-host-pems/hostkey.pem /etc/grid-security/
cp /opt/fts3/fts3-host-pems/hostkey.pem /etc/pki/tls/private/localhost.key
chmod 400 /etc/grid-security/hostkey.pem
chmod 400 /etc/pki/tls/private/localhost.key
chown root:root /etc/grid-security/hostkey.pem
chown root:root /etc/pki/tls/private/localhost.key

# Process configs using envsubst to keep configs public
#envsubst < /opt/fts3/fts3-configs/fts3config > /etc/fts3/fts3config
envsubst < /opt/fts3/fts3-configs/fts3restconfig > /etc/fts3/fts3restconfig
#envsubst < /opt/fts3/fts3-configs/fts-activemq.conf > /etc/fts3/fts-activemq.conf

chown -R fts3:fts3 /var/log/fts3rest


if [[ ! -z "${DATABASE_UPGRADE}" ]]; then
   echo ">> Database Upgrade <<"
   yes Y | python /usr/share/fts/fts-database-upgrade.py
fi
if [[ ! -z "${REST_HOST}" ]]; then
   echo ">> Replace Host <<"
   replaceCommand="sed -i -e 's/*/${REST_HOST}/g' /etc/httpd/conf.d/fts3rest.conf"
   eval $replaceCommand
fi
if [[ -z "${WEB_INTERFACE}" ]]; then
   echo ">> Remove FTS Mon <<"
   rm /etc/httpd/conf.d/ftsmon.conf
else
   echo ">> Set FTS3 Aliases <<"
   python3 /opt/fts3/cluster-hostname-aliasing.py
   #echo "${HOSTNAME} ${WEB_INTERFACE}" > /etc/fts3/host_aliases
fi

# Add a ServerName to the HTTPD configuration
echo ">> Creating /etc/httpd/conf.d/fqdn.conf <<"
echo "ServerName localhost" > /etc/httpd/conf.d/fqdn.conf

#! HERE: Do we need to run again? It fails to execute but this is an init container process already (okd)
# echo ">> START fetch-crl <<"
# fetch-crl  

echo ">> START httpd <<"                                                      
pkill httpd || :
sleep 2
exec httpd -D FOREGROUND

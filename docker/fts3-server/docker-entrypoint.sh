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
envsubst < /opt/fts3/fts3-configs/fts3config > /etc/fts3/fts3config
envsubst < /opt/fts3/fts3-configs/fts-activemq.conf > /etc/fts3/fts-activemq.conf

chown -R fts3:fts3 /var/log/fts3

if [[ ! -z "${DATABASE_UPGRADE}" ]]; then
   echo ">> Database Upgrade <<"
   yes Y | python /usr/share/fts/fts-database-upgrade.py
fi

echo ">> START supervisord <<"
supervisord -c /etc/supervisord.conf --nodaemon

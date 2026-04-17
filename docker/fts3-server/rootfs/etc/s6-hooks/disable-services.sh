#!/command/with-contenv sh

if [ -n "${DISABLE_ACTIVEMQ}" ]; then
  echo "Disabling fts-activemq..."
  rm -rf /etc/s6-overlay/s6-rc.d/user/contents.d/fts-activemq
fi

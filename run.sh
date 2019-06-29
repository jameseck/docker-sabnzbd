#!/bin/bash

CONFIG_FILE=/config/sabnzbd.ini

if [ ! -f $CONFIG_FILE ]; then
  cat <<EOF > $CONFIG_FILE
[main]
api_key = ${API_KEY}
EOF
else
  if [ -z "${API_KEY}" ]; then
    sed -i -e "s/^api_key = .*$/api_key = ${API_KEY}/" $CONFIG_FILE
  fi
fi

exec /usr/bin/python /opt/sabnzbd/SABnzbd.py -f ${CONFIG_FILE} -s 0.0.0.0:8080 -b 0

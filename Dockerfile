FROM alpine:latest

MAINTAINER James Eckersall <james.eckersall@gmail.com>

ENV \
  SABNZBD_VERSION=1.1.0RC3 \
  HOME=/config \
  TEST=1

RUN \
  apk add --update gcc autoconf automake curl git g++ make python-dev openssl-dev libffi-dev && \
  git clone https://github.com/Parchive/par2cmdline /root/par2cmdline && \
  cd /root/par2cmdline && \
  aclocal && automake --add-missing && autoconf && ./configure && make && make install && \
  apk add unrar unzip p7zip py-pip openssl libffi && \
  pip install cheetah configobj feedparser pyOpenSSL && \
  curl http://www.golug.it/pub/yenc/yenc-0.4.0.tar.gz -o /root/yenc-0.4.0.tar.gz && \
  tar -C /root -zxf /root/yenc-0.4.0.tar.gz && \
  cd /root/yenc-0.4.0 && \
  python setup.py build && python setup.py install && \
  mkdir /opt && cd /opt && \
  git clone -b ${SABNZBD_VERSION} https://github.com/sabnzbd/sabnzbd sabnzbd && \
  cd /opt/sabnzbd && \
  apk del gcc autoconf automake git g++ make python-dev openssl-dev libffi-dev && \
  rm -rf /var/cache/apk/* /root/par2cmdline /root/pip.py /root/yenc-0.4.0.tar.gz /root/yenc-0.4.0 /opt/sabnzbd/osx /opt/sabnzbd/win /opt/sabnzbd/.git

# Latest unstable release
#  curl -L \
#    $(curl -s \
#        https://api.github.com/repos/sabnzbd/sabnzbd/releases/latest \
#      | jq -r ".assets[] | select(.name | test(\"Jackett.Binaries.Mono.tar.gz\")) | .browser_download_url" \
#    ) \
#    -o /tmp/Sabnzbd.tar.gz && \

# Latest stable release
# URL=$(curl -s \
#   https://api.github.com/repos/sabnzbd/sabnzbd/releases \
# | jq -r "[ .[] | .assets[] | select(.name | test(\"SABnzbd-[0-9.]+-src.tar.gz\")) ] | first | .browser_download_url")

# Version X
# curl https://api.github.com/repos/sabnzbd/sabnzbd/releases | jq -r " .[] | .assets[] | select(.name | test(\"SABnzbd-${SABNZBD_VERSION}-src.tar.gz\")) | .browser_download_url"

EXPOSE 8080

VOLUME ["/config", "/downloads"]

ENTRYPOINT [ "/usr/bin/python", "/opt/sabnzbd/SABnzbd.py", "-f", "/config/sabnzbd.ini", "-s", "0.0.0.0:8080", "-b", "0" ]

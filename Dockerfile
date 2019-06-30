FROM alpine:latest

MAINTAINER James Eckersall <james.eckersall@gmail.com>

ARG SABNZBD_VERSION=2.3.9
ARG SABNZBD_URL=https://github.com/sabnzbd/sabnzbd/releases/download/2.3.9/SABnzbd-2.3.9-src.tar.gz

ENV \
  HOME=/config \
  TEST=1

RUN \
  apk add --update gcc autoconf automake bash curl git g++ make python-dev openssl-dev libffi-dev && \
  git clone https://github.com/Parchive/par2cmdline /root/par2cmdline && \
  cd /root/par2cmdline && \
  aclocal && automake --add-missing && autoconf && ./configure && make && make install && \
  apk add unrar unzip p7zip py-pip openssl libffi && \
  pip install "cheetah" "configobj" "feedparser" "pyOpenSSL" "babelfish" "deluge-client" "gevent" "guessit==1.0.3" "qtfaststart" "requests-cache" "requests[security]" "sabyenc>3.3.1" "stevedore==1.19.1" "subliminal<2" && \
  apk del gcc autoconf automake git g++ make python-dev openssl-dev libffi-dev && \
  mkdir -p /opt/sabnzbd && \
  curl -L "${SABNZBD_URL}" -o "/root/sabnzbd-${SABNZBD_VERSION}.tar.gz" && \
  tar zxvf "/root/sabnzbd-${SABNZBD_VERSION}.tar.gz" --strip 1 -C /opt/sabnzbd/ && \
  rm -rf /var/cache/apk/* /root/par2cmdline /root/pip.py

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

COPY run.sh /run.sh
RUN chmod 0755 /run.sh

EXPOSE 8080

VOLUME ["/config", "/downloads"]

ENTRYPOINT [ "/run.sh" ]

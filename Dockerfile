FROM jameseckersall/alpine-base

MAINTAINER James Eckersall <james.eckersall@gmail.com>

COPY files /

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

EXPOSE 8080

VOLUME ["/config", "/downloads"]

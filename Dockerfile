FROM centos:7

COPY updateawskeys.sh /usr/local/bin/updateawskeys.sh

RUN yum install -y python3 git \
 && pip3 install awscli \
 && yum install -y epel-release \
 && yum install -y jq \
 && chmod +x /usr/local/bin/updateawskeys.sh \
 && mkdir /opt/python \
 && cd /opt/python \
 && git clone https://github.com/magicalbob/configjsonconfig.git

ENV DO_DEFAULT=""
ENV DO_SECTION=""
ENV UPDATE_DEFAULT="false"

ENTRYPOINT /usr/local/bin/updateawskeys.sh

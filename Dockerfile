FROM centos:7

COPY updateawskeys.sh /usr/local/bin/updateawskeys.sh

RUN yum install -y python3 \
 && pip3 install awscli \
 && yum install -y epel-release \
 && yum install -y jq \
 && chmod +x /usr/local/bin/updateawskeys.sh

ENV DO_DEFAULT=""
ENV DO_SECTION=""

ENTRYPOINT /usr/local/bin/updateawskeys.sh

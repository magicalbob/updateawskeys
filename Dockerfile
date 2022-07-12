FROM centos:8

RUN yum install -y python3 git \
 && pip3 install --trusted-host=files.pythonhosted.org --trusted-host=pypi.python.org awscli \
 && yum install -y epel-release \
 && echo "sslverify=0" >> /etc/yum.conf \
 && yum install -y jq \
 && mkdir /opt/python \
 && cd /opt/python \
 && git clone https://github.com/magicalbob/configjsonconfig.git

COPY updateawskeys.sh /usr/local/bin/updateawskeys.sh
RUN chmod +x /usr/local/bin/updateawskeys.sh

ENV DO_DEFAULT="false"
ENV DO_SECTION=""
ENV UPDATE_DEFAULT="false"
ENV INSECURE_AWS="false"

ENTRYPOINT /usr/local/bin/updateawskeys.sh

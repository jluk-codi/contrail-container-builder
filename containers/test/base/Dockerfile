FROM centos:7.4.1708

RUN yum clean all -y && rm -rf /var/cache/yum

# Setup Chrome Repo
COPY google-chrome.repo /etc/yum.repos.d/google-chrome.repo

RUN yum install -y \
      yum-plugin-priorities \
      https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

RUN yum install -y unzip vim tcpdump ant git ipmitool gcc python-devel \
      patch sshpass bzip2 wget sudo python-pip python-netaddr python-lxml \
      python-testresources python-testrepository python-junitxml pexpect \
      python-linecache2 python-xmltodict python-eventlet python-ncclient \
      python-Fabric python-tabulate python-netifaces python-scp python-yaml \
      python-crypto python-urllib3 python-requests python-jinja2 subunit-filters \
      ant-junit libXpm libXrender gtk2 nss GConf2 google-chrome-stable firefox && \
    yum clean all -y && \
    rm -rf /var/cache/yum

# uncomment this once contrail-fabric-utils requirement is removed
# RUN yum install -y fabric

# Install Chrome Driver
RUN wget -c http://chromedriver.storage.googleapis.com/2.34/chromedriver_linux64.zip && \
    unzip chromedriver_linux64.zip && cp ./chromedriver /usr/bin/ && \
    chmod ugo+rx /usr/bin/chromedriver

# pip install python packages
COPY requirements.txt /requirements.txt
RUN pip install -r /requirements.txt
RUN mkdir -p /images

ARG CONTRAIL_VERSION
ARG OPENSTACK_VERSION
ARG OPENSTACK_SUBVERSION
ARG CONTRAIL_REGISTRY

COPY entrypoint.sh /

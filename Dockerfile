#
# This docker image is just for development and testing purpose - please do NOT use on production
# Credit goes to https://github.com/fabric8io/fabric8-zookeeper-docker/blob/master/Dockerfile
#

# Pull Base Image
FROM zhicwu/java:7

# Set Maintainer Details
MAINTAINER Zhichun Wu <zhicwu@gmail.com>

# Set Environment Variables
ENV ZK_VERSION=3.4.6 ZK_HOME=/zookeeper \
	APACHE_BASE_URL=http://www.apache.org/dyn/closer.lua?action=download&filename=

# Set labels
LABEL zk_version="Apache ZooKeeper $ZK_VERSION" 

# Install Apache ZooKeeper
RUN wget ${APACHE_BASE_URL}/zookeeper/zookeeper-${ZK_VERSION}/zookeeper-${ZK_VERSION}.tar.gz \
	&& tar zxvf *.tar.gz \
	&& rm -f *.tar.gz \
	&& ln -s zookeeper-${ZK_VERSION} ${ZK_HOME} \
	&& mkdir -p ${ZK_HOME}/{data,log}

WORKDIR $ZK_HOME

COPY config-and-run.sh ./bin/
COPY zoo-base.cfg ./conf/

RUN chmod +x ${ZK_HOME}/bin/*.sh

VOLUME ["$ZK_HOME/conf", "$ZK_HOME/data", "$ZK_HOME/log"]

EXPOSE 2181 2888 3888

CMD ["./bin/config-and-run.sh"]

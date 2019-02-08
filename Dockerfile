#
# This docker image is just for development and testing purpose - please do NOT use on production
# Credit goes to https://github.com/fabric8io/fabric8-zookeeper-docker/blob/master/Dockerfile
#

# Base image
FROM zhicwu/java:8-j9

# Maintainer
LABEL maintainer="zhicwu@gmail.com"

# Build arguments
ARG zookeeper_version=3.5.4-beta

# Environment variables
ENV ZK_VERSION=$zookeeper_version ZK_HOME=/zookeeper ZK_ID=1000 ZK_USER=zookeeper \
	APACHE_BASE_URL=http://www.apache.org/dyn/closer.lua?action=download&filename=

# Labels
LABEL app_name="Apache ZooKeeper" app_version="$ZK_VERSION" 

# Update system and install ZooKeeper
RUN apt-get update \
	&& groupadd -r -g $ZK_ID $ZK_USER \
	&& useradd -r -u $ZK_ID -g $ZK_ID $ZK_USER \
	&& wget --progress=dot:giga "$APACHE_BASE_URL/zookeeper/zookeeper-$ZK_VERSION/zookeeper-$ZK_VERSION.tar.gz" \
	&& tar zxf *.tar.gz \
	&& ln -s zookeeper-$ZK_VERSION $ZK_HOME \
	&& mkdir -p $ZK_HOME/{data,log,logs} \
	&& apt-get clean \
	&& rm -rf *.tar.gz /tmp/* /var/cache/debconf /var/lib/apt/lists/* \
		$ZK_HOME/*.xml $ZK_HOME/bin/*.cmd $ZK_HOME/dist-maven $ZK_HOME/docs \
		$ZK_HOME/recipes $ZK_HOME/src

COPY docker-entrypoint.sh /

WORKDIR $ZK_HOME

EXPOSE 2181 2888 3888 8080
VOLUME ["$ZK_HOME/conf", "$ZK_HOME/data", "$ZK_HOME/log", "$ZK_HOME/logs"]

HEALTHCHECK --interval=3m --timeout=3s CMD curl -f http://localhost:8080/commands/ruok || exit 1

ENTRYPOINT ["/sbin/my_init", "--", "/docker-entrypoint.sh"]

# docker-zookeeper
ZooKeeper docker image for development and testing purposes. https://hub.docker.com/r/zhicwu/zookeeper/

## What's inside
```
ubuntu:16.04
 |
 |--- zhicwu/java:8-j9
       |
       |--- zhicwu/zookeeper:3.5
```
* Official Ubuntu Trusty(16.04) docker image
* Open JDK 8 latest release(with Eclipse OpenJ9)
* [Apache ZooKeeper](http://zookeeper.apache.org) 3.5.4-beta

## Usage
- Standalone
```
$ docker run --rm -it zhicwu/zookeeper:3.5
```
- Cluster
```
$ docker-compose up
```

## Environment Variables
All supported environment variables can be found at [here](docker-entrypoint.sh#L62)
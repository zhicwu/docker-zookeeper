# docker-zookeeper
ZooKeeper docker image for development and testing purposes. https://hub.docker.com/r/zhicwu/zookeeper/

## What's inside
```
ubuntu:14.04
 |
 |--- zhicwu/java:8
       |
       |--- zhicwu/zookeeper:latest
```
* Official Ubuntu Trusty(14.04) docker image
* Oracle JDK 8 latest release
* [Apache ZooKeeper](http://zookeeper.apache.org) 3.4.6

## How to use
- Pull the image
```
# docker pull zhicwu/zookeeper
```
- Setup scripts
```
# git clone https://github.com/zhicwu/docker-zookeeper.git
# cd docker-zookeeper
# chmod +x *.sh
```
- Edit zk-cluster-env.sh and zk-node-env.sh as required
- Start ZooKeeper
```
# ./start-zk.sh
# docker logs -f my-zk
```

## How to build
```
# git clone https://github.com/zhicwu/docker-zookeeper.git
# cd docker-zookeeper
# chmod +x *.sh
# docker build -t zhicwu/zookeeper .
```
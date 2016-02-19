#!/bin/bash
# shamelessly copied from https://github.com/fabric8io/fabric8-zookeeper-docker/blob/master/config-and-run.sh
echo "SERVER_ID=[$SERVER_ID] / MAX_SERVERS=[$MAX_SERVERS]"

mkdir -p $ZK_HOME/{data,log}

cp -f $ZK_HOME/conf/zoo-base.cfg $ZK_HOME/conf/zoo.cfg
echo "dataDir=$ZK_HOME/data" >> $ZK_HOME/conf/zoo.cfg
echo "dataLogDir=$ZK_HOME/log" >> $ZK_HOME/conf/zoo.cfg

if [ ! -z "$SERVER_ID" ] && [ ! -z "$MAX_SERVERS" ]; then
  echo "Starting up in clustered mode"
  echo "" >> $ZK_HOME/conf/zoo.cfg
  echo "# Server List" >> $ZK_HOME/conf/zoo.cfg

  for i in $( eval echo {1..$MAX_SERVERS});do
    if [ "$SERVER_ID" = "$i" ];then
      echo "server.$i=0.0.0.0:2888:3888" >> $ZK_HOME/conf/zoo.cfg
    else
      echo "server.$i=zookeeper-$i:2888:3888" >> $ZK_HOME/conf/zoo.cfg
    fi
  done

  cat $ZK_HOME/conf/zoo.cfg

  # Persists the ID of the current instance of Zookeeper
  echo ${SERVER_ID} > $ZK_HOME/data/myid
else
  echo "Starting up in standalone mode"
fi

exec $ZK_HOME/bin/zkServer.sh start-foreground

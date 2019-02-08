#!/bin/bash
set -e

: ${HOST_USER_ID:=""}

# ZooKeeper configuration based on https://clickhouse.yandex/docs/en/operations/tips/#zookeeper
: ${ZK_TICK_TIME:="2000"}
: ${ZK_INIT_LIMIT:="30000"}
: ${ZK_SYNC_LIMIT:="10"}
: ${ZK_MAX_CLIENT_CNXNS:="2000"}
: ${ZK_PREALLOCSIZE:="131072"}
: ${ZK_SNAPCOUNT:="3000000"}
: ${ZK_AUTOPURGE_PURGEINTERVAL:="1"}
: ${ZK_AUTOPURGE_SNAPRETAINCOUNT:="10"}
: ${ZK_LEADERSERVES:="yes"}
: ${ZK_STANDALONE_ENABLED:="false"}

# maximum heap size in MB
: ${ZK_SERVER_HEAP:="512"}
: ${ZK_CLIENT_HEAP:="128"}

load_secrets() {
	# you can define multiple directories, for example: "/run/secrets /my/secrets"
	: ${SECRETS_DIRECTORY:="/run/secrets"}

    # load secrets if any
	for d in $SECRETS_DIRECTORY; do
		[ -d "$d" ] || continue
		for s in $d/*; do
			[ -f "$s" ] || continue
			echo "Loading secret $s..."
			source $s && export $(grep -v '^#' $s 2>/dev/null | cut -d= -f1)
		done
	done
}

fix_permission() {
	# only change when HOST_USER_ID is not empty(and not root)
	if [ "$HOST_USER_ID" != "" ] && [ $HOST_USER_ID != 0 ] && [ $HOST_USER_ID != $ZK_ID ]; then
		echo "Fixing permissions..."
		
		# based on https://github.com/schmidigital/permission-fix/blob/master/tools/permission_fix
		UNUSED_USER_ID=21338

		# Setting User Permissions
		DOCKER_USER_CURRENT_ID=`id -u $ZK_USER`

		if [ "$DOCKER_USER_CURRENT_ID" != "$HOST_USER_ID" ]; then
			DOCKER_USER_OLD=`getent passwd $HOST_USER_ID | cut -d: -f1`

			if [ ! -z "$DOCKER_USER_OLD" ]; then
				usermod -o -u $UNUSED_USER_ID $DOCKER_USER_OLD
			fi

			usermod -o -u $HOST_USER_ID $ZK_USER || true
		fi
	fi

	chown -Rf $ZK_USER $ZK_HOME/conf $ZK_HOME/data $ZK_HOME/log $ZK_HOME/logs || true
}

init_config() {
	sed -i -e 's|^\(ZK_SERVER_HEAP=\).*|\1"'"$ZK_SERVER_HEAP"'"|' \
		-e 's|^\(ZK_CLIENT_HEAP=\).*|\1"'"$ZK_CLIENT_HEAP"'"|' $ZK_HOME/bin/zkEnv.sh
	
	sed -i -e 's|\(^[[:space:]]*\).*HeapDumpOnOutOfMemoryError.*|\1'"'${JAVA_TOOL_OPTIONS}'"' \\|' \
		$ZK_HOME/bin/zkServer.sh

	local CONFIG="$ZK_HOME/conf/zoo.cfg"

	if [ ! -f "$CONFIG" ]; then
		echo "clientPort=2181" >> "$CONFIG"

		echo "dataDir=$ZK_HOME/data" >> "$CONFIG"
		echo "dataLogDir=$ZK_HOME/log" >> "$CONFIG"

		echo "tickTime=$ZK_TICK_TIME" >> "$CONFIG"
		echo "initLimit=$ZK_INIT_LIMIT" >> "$CONFIG"
		echo "syncLimit=$ZK_SYNC_LIMIT" >> "$CONFIG"

		echo "autopurge.snapRetainCount=$ZK_AUTOPURGE_SNAPRETAINCOUNT" >> "$CONFIG"
		echo "autopurge.purgeInterval=$ZK_AUTOPURGE_PURGEINTERVAL" >> "$CONFIG"

		echo "preAllocSize=$ZK_PREALLOCSIZE" >> "$CONFIG"
		echo "snapCount=$ZK_SNAPCOUNT" >> "$CONFIG"

		echo "maxClientCnxns=$ZK_MAX_CLIENT_CNXNS" >> "$CONFIG"

		echo "leaderServes=$ZK_LEADERSERVES" >> "$CONFIG"
		echo "standaloneEnabled=$ZK_STANDALONE_ENABLED" >> "$CONFIG"
		echo "dynamicConfigFile=$CONFIG.dynamic" >> "$CONFIG"

		if [ "$ZK_SERVERS" = "" ]; then
			ZK_SERVERS="server.1=`hostname`:2888:3888;2181"
		fi

		if [ ! -f "$CONFIG.dynamic" ]; then
			for server in $ZK_SERVERS; do
				echo "$server" >> "$CONFIG.dynamic"
			done
		fi
	fi

	# Write myid only if it doesn't exist
	if [ ! -f "$ZK_HOME/data/myid" ]; then
		echo "${ZK_MY_ID:-1}" > "$ZK_HOME/data/myid"
	fi
}

# start clickhouse server
if [ $# -eq 0 ]; then
	load_secrets
	init_config
	fix_permission

	# now start the server
	exec /sbin/setuser $ZK_USER $ZK_HOME/bin/zkServer.sh start-foreground
else
	exec "$@"
fi
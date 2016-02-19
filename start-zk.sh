#!/bin/bash
ZK_ALIAS="my-zk"
ZK_TAG="latest"

cdir="`dirname "$0"`"
cdir="`cd "$cdir"; pwd`"

[[ "$TRACE" ]] && set -x

_log() {
  [[ "$2" ]] && echo "[`date +'%Y-%m-%d %H:%M:%S.%N'`] - $1 - $2"
}

info() {
  [[ "$1" ]] && _log "INFO" "$1"
}

warn() {
  [[ "$1" ]] && _log "WARN" "$1"
}

setup_env() {
  info "Load environment variables from $cdir/zk-cluster-env.sh..."
  if [ -f $cdir/zk-cluster-env.sh ]
  then
    . "$cdir/zk-cluster-env.sh"
  else
    warn "Skip zk-cluster-env.sh as it does not exist"
  fi

  info "Load environment variables from $cdir/zk-node-env.sh..."
  if [ -f $cdir/zk-node-env.sh ]
  then
    . "$cdir/zk-node-env.sh"
  else
    warn "Skip zk-node-env.sh as it does not exist"
  fi


  # check environment variables and set defaults as required
  : ${SERVER_ID:=""}
  : ${MAX_SERVERS:=""}

  info "Loaded environment variables:"
  info "	SERVER_ID   = $SERVER_ID"
  info "	MAX_SERVERS = $MAX_SERVERS"
}

start_zk() {
  info "Stop and remove \"$ZK_ALIAS\" if it exists and start new one"
  # stop and remove the container if it exists
  docker stop "$ZK_ALIAS" >/dev/null 2>&1 && docker rm "$ZK_ALIAS" >/dev/null 2>&1

  # use --privileged=true has the potential risk of causing clock drift
  # references: http://stackoverflow.com/questions/24288616/permission-denied-on-accessing-host-directory-in-docker
  docker run -d --name="$ZK_ALIAS" --net=host --restart=always \
    -e SERVER_ID="$SERVER_ID" -e MAX_SERVERS="$MAX_SERVERS" \
    zhicwu/zookeeper:$ZK_TAG

  info "Try 'docker logs -f \"$ZK_ALIAS\"' to see if this works"
}

main() {
  setup_env
  start_zk
}

main "$@"

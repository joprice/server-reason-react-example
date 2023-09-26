#!/usr/bin/env bash

_build/default/server/server_dev.exe &
pid=$!

trap 'kill "${pid}"; wait "${pid}"' SIGINT SIGTERM

pending=true
while $pending; do 
  curl -o /dev/null -s --fail localhost:8080
  if [[ "$?" == 0 ]]; then
    pending=false
  fi
done
date > .processes/server-start.txt

wait $pid

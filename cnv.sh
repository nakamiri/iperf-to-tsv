#!/bin/bash

FILE=test.log

START_NUM=($(grep -e "connected" -n ${FILE} | sed -e 's/:.*//g'))
END_NUM=($(grep -e "- - - - -" -n ${FILE} | sed -e 's/:.*//g'))

INTERVAL="sec"
TRANSFER="MBytes"
BANDWIDTH="Gbits/sec"
CWND="KBytes"

for i in `seq 1 ${#START_NUM[@]}`; do
  _start=${START_NUM[$i-1]}
  _end=${END_NUM[$i-1]}

  echo "=== start ==="
  ORG_IFS=$IFS
  IFS=$'\n'
  _data=($(cat ${FILE} | head -${_end} | tail -`expr ${_end} - ${_start} + 1` | grep ${INTERVAL}))
  for j in `seq 1 ${#_data[@]}`; do
    _interval=$(echo ${_data[$j-1]} | awk "{sub(\"${INTERVAL}.*\", \"\");print \$0;}" | awk '{print substr($0, index($0, "-"))}' | tr -d ' ' | cut -c 2-)
    _transfer=$(echo ${_data[$j-1]} | awk "{sub(\"${TRANSFER}.*\", \"\");print \$0;}" | awk "{print substr(\$0, index(\$0, \"${INTERVAL}\"))}" | tr -d ' ' | cut -c `expr ${#INTERVAL} + 1`-)
    _bandwidth=$(echo ${_data[$j-1]} | awk "{sub(\"${BANDWIDTH}.*\", \"\");print \$0;}" | awk "{print substr(\$0, index(\$0, \"${TRANSFER}\"))}" | tr -d ' ' | cut -c `expr ${#TRANSFER} + 1`-)
    _cwnd=$(echo ${_data[$j-1]} | rev | awk "{print substr(\$0, index(\$0, \"`echo ${CWND} | rev`\"), index(\$0, \"  \") -1 )}" | cut -c `expr ${#CWND} + 1`- | rev)
    printf "${_interval}\t${_transfer}\t${_bandwidth}\t${_cwnd}\n"
  done
  IFS=$ORG_IFS
  echo "=== end ==="
done

#!/bin/bash
#
VIP=10.14.1.140
CPORT=80
FAIL_BACK=127.0.0.1
FBSTATUS=0
RS=("10.14.1.131" "10.14.1.132")
RSTATUS=("1" "1")
RW=("2" "1")
RPORT=80
TYPE=g

add() {
  ipvsadm -a -t $VIP:$CPORT -r $1:$RPORT -$TYPE -w $2
  [ $? -eq 0 ] && return 0 || return 1
}

del() {
  ipvsadm -d -t $VIP:$CPORT -r $1:$RPORT
  [ $? -eq 0 ] && return 0 || return 1
}

while :; do
  let COUNT=0
  for I in ${RS[*]}; do
    if curl --connect-timeout 1 http://$I &> /dev/null; then
      if [ ${RSTATUS[$COUNT]} -eq 0 ]; then
         add $I ${RW[$COUNT]}
         [ $? -eq 0 ] && RSTATUS[$COUNT]=1
      fi
    else
      if [ ${RSTATUS[$COUNT]} -eq 1 ]; then
         del $I
         [ $? -eq 0 ] && RSTATUS[$COUNT]=0
      fi
    fi
    let COUNT++
  done
  sleep 5
done



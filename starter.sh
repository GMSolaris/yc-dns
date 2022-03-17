#!/bin/bash

  PHD=$(readlink -f $0)
  PHD=$(dirname $PHD)
  cd $PHD
  export PATH=$PATH:/home/kvazik/yandex-cloud/bin

########## variables #############
LOGFILE="./logs/yc-dns-server.log"
attempts_default=3
command=$1

attempts_fail=$attempts_default
attempts_success=$attempts_default


function startup 
{
########## Login to yc ###########
yc config profile create my-robot-profile >> $LOGFILE
yc config set cloud-id b1g14lt2g1e8mgfftilg
yc config set folder-id b1gbtvt18s1l7gc5ommr

echo "-----------------------------------------------------------" >> $LOGFILE
echo "`date "+%Y-%m-%d %H:%M:%S"` Start working script..........." >> $LOGFILE
echo "-----------------------------------------------------------" >> $LOGFILE

bash -c "exec -a mxgroup ./check_aviability.sh mxgroup.ru mxgroup &"
bash -c "exec -a showa1 ./check_aviability.sh showa1.ru showa1 &"
bash -c "exec -a showa-russia ./check_aviability.sh showa-russia.ru showa-russia &"
bash -c "exec -a vicfilter ./check_aviability.sh vicfilter.ru vicfilter &"

bash -c "exec -a watchdog ./watchdog.sh &"
}

function stopdown
{
sudo pkill -f mxgroup
sudo pkill -f showa1
sudo pkill -f showa-russia
sudo pkill -f vicfilter

sudo pkill -f watchdog
rm watchdog_alive > /dev/null 2>&1
echo "-----------------------------------------------------------" >> $LOGFILE
echo "`date "+%Y-%m-%d %H:%M:%S"` Stop working script..........." >> $LOGFILE
echo "-----------------------------------------------------------" >> $LOGFILE
}



########### main code ##############


if [[ "$command" == "start" ]] 
then
 sudo pkill -f mxgroup
 sudo pkill -f showa1
 sudo pkill -f showa-russia
 sudo pkill -f vicfilter
 
 sudo pkill -f watchdog
 rm watchdog_alive > /dev/null 2>&1
 startup
else
  if [[ "$command" == "stop" ]] 
  then
	
	stopdown
	exit 0
  else
  
  echo "start\stop command required"
  exit 1
  fi
fi
 


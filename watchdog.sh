#!/bin/bash

  PHD=$(readlink -f $0)
  PHD=$(dirname $PHD)
  

  cd $PHD

########## variables #############
LOGFILE="./logs/yc-dns-server.log"

function check_zone_state
{
state=$(ps -f | grep mxgroup | grep -wv "grep" | wc -l)
if [[ "$state" > 0 ]]
then 
 sleep 1
 echo "`date "+%Y-%m-%d %H:%M:%S"` watchdog mxgroup ok" >> $LOGFILE
else
 echo "`date "+%Y-%m-%d %H:%M:%S"` watchdog restarting mxgroup" >> $LOGFILE
 bash -c "exec -a mxgroup ./check_aviability.sh mxgroup.ru mxgroup &" 
fi

state=$(ps -f | grep showa1 | grep -wv "grep" | wc -l)
if [[ "$state" > 0 ]]
then 
 sleep 1
 echo "`date "+%Y-%m-%d %H:%M:%S"` watchdog showa1 ok" >> $LOGFILE
else
 echo "`date "+%Y-%m-%d %H:%M:%S"` watchdog restarting showa1" >> $LOGFILE
 bash -c "exec -a showa1 ./check_aviability.sh showa1.ru showa1 &"
fi

state=$(ps -f | grep showa-russia | grep -wv "grep" | wc -l)
if [[ "$state" > 0 ]]
then 
 sleep 1
 echo "`date "+%Y-%m-%d %H:%M:%S"` watchdog showa-russia ok" >> $LOGFILE
else
 echo "`date "+%Y-%m-%d %H:%M:%S"` watchdog restarting showa-russia" >> $LOGFILE
 bash -c "exec -a showa-russia ./check_aviability.sh showa-russia.ru showa-russia &"
fi

state=$(ps -f | grep vicfilter | grep -wv "grep" | wc -l)
if [[ "$state" > 0 ]]
then 
 sleep 1
 echo "`date "+%Y-%m-%d %H:%M:%S"` watchdog vicfilter ok" >> $LOGFILE
else
 echo "`date "+%Y-%m-%d %H:%M:%S"` watchdog restarting vicfilter" >> $LOGFILE
 bash -c "exec -a vicfilter ./check_aviability.sh vicfilter.ru vicfilter &"
fi

echo "`date "+%Y-%m-%d %H:%M:%S"` watchdog working" > watchdog_alive
}

########### main code ##############
echo "-----------------------------------------------------------" >> $LOGFILE
echo "`date "+%Y-%m-%d %H:%M:%S"` Watchdog started..............." >> $LOGFILE
echo "-----------------------------------------------------------" >> $LOGFILE


while ((1==1))
do
	check_zone_state
	sleep 60
done
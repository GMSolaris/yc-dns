#bash

  PHD=$(readlink -f $0)
  PHD=$(dirname $PHD)
  

  cd $PHD


########## variables #############
LOGFILE="./yc-dns.log"
attempts_default=3
list=$1
yc_zone_name=$2
readarray -t server_list < $list
attempts_fail=$attempts_default
attempts_success=$attempts_default


function first_start 
{
for (( i=0;  i < ${#server_list[*]} ; i++ ))
	do
	   	echo "`date "+%Y-%m-%d %H:%M:%S"` host ${server_list[$i]} enabled" > /var/tmp/${list}_tmp/${server_list[$i]}
		
		#yc dns zone add-records --name ${yc_zone_name} --record "${list}. 60 A ${server_list[$i]}"
	done
}


function check_state 
{
	for (( i=0;  i < ${#server_list[*]} ; i++ ))
	do
	state=$(nc -z -v -w3 ${server_list[$i]} 80 2>&1 | grep 'succeeded\|open' | wc -l)
	if [[ $state -eq "0" ]] 
		then
			disable_host ${server_list[$i]}
	    else
		    enable_host ${server_list[$i]}
		fi
	sleep 1
	done
}

function disable_host
{
host=${1}
attempts_fail=$((attempts_fail-1))
if (( attempts_fail > 0 )) 
 then 
	  sleep 1
	  #echo "`date "+%Y-%m-%d %H:%M:%S"` host ${host} is failed, trying ${attempts_fail} times again...." 
 else
	  host_disabled=$(grep /var/tmp/${list}_tmp/${host} -e 'disabled' | wc -l)
	  if [[ $host_disabled -eq "1" ]]
	  then 
		  sleep 1
		  #echo "`date "+%Y-%m-%d %H:%M:%S"` host ${host} already disabled, do nothing" 
	  else
		 # echo "`date "+%Y-%m-%d %H:%M:%S"` Host ${host} check state failed, disabling in zone ${list} on Yandex Cloud DNS" 
		 # echo "`date "+%Y-%m-%d %H:%M:%S"` attempts ends, disable host ${host} in zone ${list} on Yandex Cloud DNS" 
		  echo "`date "+%Y-%m-%d %H:%M:%S"` host ${host} disabled" > /var/tmp/${list}_tmp/${host}
		  check_failed_state
		  if [[ $failed_state -eq "0" ]] 
		  then 
			sleep 1
			#echo "delete record"
			#yc dns zone delete-records --name ${yc_zone_name} --record "${list}. 60 A ${host}"
		  else
		  #  echo "`date "+%Y-%m-%d %H:%M:%S"` all hosts disabled (((!!!))), can't disable last one host ${host} in zone ${list} on Yandex Cloud DNS"  
			echo "${host}" > alert_${yc_zone_name} 
			echo "`date "+%Y-%m-%d %H:%M:%S"` host ${host} enabled" > /var/tmp/${list}_tmp/${host}
		  fi
		  attempts_fail=$attempts_default
	  fi
	  attempts_fail=$attempts_default
 fi
}

function enable_host
{
host=${1}
host_enabled=$(grep /var/tmp/${list}_tmp/${host} -e 'enabled' | wc -l)
if [[ $host_enabled -eq "1" ]] 
then 
sleep 1
#echo "`date "+%Y-%m-%d %H:%M:%S"` host ${host} avilable" 
else 
	attempts_success=$((attempts_success-1))
	if (( attempts_success > 0 )) 
	 then 
		  sleep 1
		  #echo "`date "+%Y-%m-%d %H:%M:%S"` host ${host} is up, trying ${attempts_success} times again...." 
	 else
			  #echo "`date "+%Y-%m-%d %H:%M:%S"` Host ${host} check state success, enabling in zone ${list} on Yandex Cloud DNS" 
			 # echo "`date "+%Y-%m-%d %H:%M:%S"` attempts ends, enable host ${host} in zone ${list} on Yandex Cloud DNS" 
			  echo "`date "+%Y-%m-%d %H:%M:%S"` host ${host} enabled" > /var/tmp/${list}_tmp/${host}
			  #yc dns zone add-records --name ${yc_zone_name} --record "${list}. 60 A ${host}"
			  rm alert_${yc_zone_name}
			  attempts_fail=$attempts_default
	 fi
fi
}

function check_failed_state
{
for (( i=0;  i < ${#server_list[*]} ; i++ ))
	do
	   	failed_state=$(grep /var/tmp/${list}_tmp/${server_list[$i]} -e 'disabled' | wc -l)
		#echo "${server_list[$i]} ${failed_state}"
		if [[ $failed_state -eq "0" ]] 
		then 
		 break
		fi 
	done
}


########### main code ##############
#echo "-----------------------------------------------------------" 
#echo "`date "+%Y-%m-%d %H:%M:%S"` Running script for zone ${list}" 
#echo "-----------------------------------------------------------" 

# create temp dir to zone
rm -r /var/tmp/${list}_tmp 
mkdir /var/tmp/${list}_tmp

# first initialize state of hosts

first_start

# loop checking states

while ((1==1))
do
	check_state
done
exit 0
#!/bin/bash

# Original script from Max Knorr
# http://1234max.co.uk/

base_socks_port=9060
base_control_port=15060
base_data_dir="/var/lib/tor/data"
HashedControlPassword="16:59D8CA6C7C7EE84660D829AF8EEBE48F434E194DDE54232CA1CB91F6D2"
default_torrc="/etc/tor/torrcall"
Run_As_User="debian-tor"
Enable_privoxy="1"
line="*****************************"
privoxycfg="/etc/privoxy/config"
privoxycfgbase="/etc/privoxy/cfgbase"
my_mkdir="sudo -u $User  $(which mkdir)"
PidFileTest="pids"
TOR_INSTANCES=5
Enable_privoxy="$2"
KILLTOR="$3"
tg=137

pt=""
quiet=""
# Create data directory if it doesn't exist
if [ ! -d "$base_data_dir" ]; then
    sudo -u $Run_As_User mkdir -p $base_data_dir
fi

TOR_INSTANCES="$1"

if [ ! $TOR_INSTANCES ] || [ $TOR_INSTANCES -lt 1 ]; then
    echo "You could supply an instance count"
    echo "Example: ./multi-tor.sh --TOR_INSTANCES=5"
    echo "Starting five instances as default"

fi


if [ ! $Enable_privoxy ] ; then

    echo "You could disable privoxy"
    echo "Example: ./multi-tor.sh 5 0"
    exit 1
fi
cp "$privoxycfgbase"  "$privoxycfg"
>$PidFileTest
clear
if [ $KILLTOR -eq "1" ] ;  then
rn=$(ps -ef|grep -F "tor --ControlPort") ##ps -ef|grep -F "tor --ControlPort

 while    [ ps -ef|grep -F "tor --ControlPort" -ne ]
 do

echo "***************************************************************************************"
echo "****************** Waiting for all tor processes to terminate *********************"
echo "***************************************************************************************"
killall tor
done
fi
sudo -u $Run_As_User mkdir -p /var/run/tor/
for i in $(seq $TOR_INSTANCES)
do
    j=$((i+1))
    Instance="$base_data_dir/tor$i"
    socks_port=$((base_socks_port+i))
    control_port=$((base_control_port+i))
    if [ ! -d "$base_data_dir/tor$i" ]; then
        echo "Creating directory $Instance"

        sudo -u $Run_As_User mkdir $Instance
        chown $Run_As_User:$Run_As_User -R $Instance
    fi
    echo " "
    echo "***************************************************************************************"
    echo "$line Starting TOR Instance No. $i $line"
    echo "***************************************************************************************"
    echo " "
    if [  $Enable_privoxy  ]; then
    echo "forward-socks5          /           127.0.0.1:$socks_port .">>$privoxycfg
    echo "***************************************************************************************"
    echo "$line Altered privoxy config file $line "
    echo "***************************************************************************************"
    echo " "
    fi
    tor --ControlPort $control_port --SocksPort $socks_port --DataDirectory $Instance --RunAsDaemon 1 --CookieAuthentication 0 --HashedControlPassword $HashedControlPassword  --PidFile /var/run/tor/tor$i.pid   -f $default_torrc --User $Run_As_User $quiet ;
    success=$(ps -ef|grep -F "tor --ControlPort"| awk "{print$ 10}"|tail -n 2|head -n 1)
    if [ ! $quiet ] || [ $success=$Instance ]; then
    echo "$line Tor Instance No. $i started $line"
    echo "***************************************************************************************"
    fi
    done
if [  $Enable_privoxy ] ; then
service privoxy restart
fi

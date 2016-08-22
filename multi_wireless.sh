#!/bin/sh

source ./func.inc

echo 1 > /proc/sys/net/ipv4/ip_forward

if_num=$1 #how many interfaces you want to create?
if_prefix=mv
if_phy=wlp3s0 #your physical wireless interface name
wpa_supplicant_cmd="wpa_supplicant -B"
rule_prefix=100


########## Function ##########

init_env() {
    killall wpa_supplicant
    killall dhclient
    ip addr flush ${if_phy}
    ip link set dev ${if_phy} down up
}

chk_all_connect() {
    while [ 1 ]; do
        [ $(iw dev | grep -i channe[l] | wc -l) -lt ${if_num} ] && echo -n "." || break
        sleep 1
    done
}

get_ip() {
    dhclient $1 --no-pid
}

get_default_gw() {
    echo $(ip ro show | grep defaul[t] | grep $1 | awk '{print $3}')
}

del_default_gw() {
    ip ro del default
}

get_ip_info() {
    echo $(ip addr show dev $1 | grep -w inet | awk '{print $2}')
}
########## Main ##########

init_env

for((i=1;i<=if_num;i++)); do
    idx=$((rule_prefix+i))
    vif=${if_prefix}${idx}
    vmac=$(gen_mac)
    ip link set dev ${vif} down
    iw dev ${vif} del
    iw dev ${if_phy} interface add ${vif} type managed
    ip link set dev ${vif} down
    ip link set dev ${vif} address ${vmac}
    ip link set dev ${vif} up
    if [ ${i} -eq 1 ]; then
        wpa_supplicant_cmd="${wpa_supplicant_cmd} -i ${vif} -D nl80211 -c /etc/wpa_supplicant/wpa.conf"
    else
        wpa_supplicant_cmd="${wpa_supplicant_cmd} -N -i ${vif} -D nl80211 -c /etc/wpa_supplicant/wpa.conf"
    fi
done

#echo ${wpa_supplicant_cmd}
${wpa_supplicant_cmd}

chk_all_connect
[ ! -f /etc/iproute2/rt_tables.org ] && cp /etc/iproute2/rt_tables /etc/iproute2/rt_tables.org
cp /etc/iproute2/rt_tables.org /etc/iproute2/rt_tables

for((i=0;i<=if_num;i++)); do
    if [ $i -eq 0 ]; then
        continue
        get_ip ${if_phy}
        wip=$(get_ip_info ${if_phy})
        wip=$(echo ${wip%/*})
        ip ru del pref 11${i}
        ip ru add from ${wip}/32 ta mv${i} pref 11${i}
        ip ru add to ${wip}/32 ta mv${i} pref 11${i}
        defGW=$(get_default_gw ${if_phy})
        ip ro add default via $defGW dev ${if_phy} ta mv${i}
        del_default_gw
    else
        r_idx=$((rule_prefix+i))
        echo "${r_idx}	mv${r_idx}" >> /etc/iproute2/rt_tables
        get_ip ${if_prefix}${r_idx}
        defGW=$(get_default_gw ${if_prefix}${r_idx})
        del_default_gw
        #Doing ip route for each WiFi interface
        wip=$(get_ip_info ${if_prefix}${r_idx})
        wip=$(echo ${wip%/*})
        ip ru del pref ${r_idx}
        ip ru del pref ${r_idx}
        ip ru add from ${wip}/32 ta mv${r_idx} pref ${r_idx}
        ip ru add oif mv${r_idx} ta mv${r_idx} pref ${r_idx}
        ip ro add default via $defGW dev mv${r_idx} ta mv${r_idx}
    fi
done

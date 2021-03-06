#!/bin/bash

source /common.sh

echo "INFO: ip address show:"
ip address show

IFS=' ' read -r phys_int phys_int_mac <<< $(get_physical_nic_and_mac)
echo "INFO: Physical interface: $phys_int, mac=$phys_int_mac"

# Probe vhost0
vrouter_cidr="$(get_cidr_for_nic vhost0)"

# Load kernel module
kver=`uname -r | awk -F "-" '{print $1}'`
echo "INFO: Load kernel module for kver=$kver"
modfile=`ls -1rt /opt/contrail/vrouter-kernel-modules/$kver-*/vrouter.ko | tail -1`
if ! lsmod | grep -q vrouter; then
    echo "INFO: Modprobing vrouter "$modfile
    insmod $modfile
    if ! lsmod | grep -q vrouter ; then
        echo "ERROR: Failed to insert vrouter kernel module"
        exit 1
    fi
else
    echo "INFO: vrouter.ko already loaded in the system"
    # TODO: handle upgrade
fi

# VRouter specific code starts here
function pkt_setup () {
    for f in /sys/class/net/$1/queues/rx-*
    do
        q="$(echo $f | cut -d '-' -f2)"
        r=$(($q%32))
        s=$(($q/32))
        ((mask=1<<$r))
        str=(`printf "%x" $mask`)
        if [ $s -gt 0 ]; then
            for ((i=0; i < $s; i++))
            do
                str+=,00000000
            done
        fi
        echo $str > $f/rps_cpus
    done
    ip link set dev $1 up
}

function insert_vrouter() {
    if [ -f /sys/class/net/pkt1/queues/rx-0/rps_cpus ]; then
        pkt_setup pkt1
    fi
    if [ -f /sys/class/net/pkt2/queues/rx-0/rps_cpus ]; then
        pkt_setup pkt2
    fi
    if [ -f /sys/class/net/pkt3/queues/rx-0/rps_cpus ]; then
        pkt_setup pkt3
    fi
    vif --create vhost0 --mac $phys_int_mac
    vif --add $phys_int --mac $phys_int_mac --vrf 0 --vhost-phys --type physical
    vif --add vhost0 --mac $phys_int_mac --vrf 0 --type vhost --xconnect $phys_int
    ip link set vhost0 up
    return 0
}

if [[ "$vrouter_cidr" == '' ]] ; then
    echo "INFO: creating vhost0"
    vrouter_cidr=$(get_cidr_for_nic $phys_int)
    VROUTER_GATEWAY=${VROUTER_GATEWAY:-$(get_default_gateway_for_nic $phys_int)}
    insert_vrouter

    # TODO: switch off dhcp on phys_int
    echo "INFO: Changing physical interface to vhost in ip table"
    ip address delete $vrouter_cidr dev $phys_int
    ip address add $vrouter_cidr dev vhost0
    if [[ $VROUTER_GATEWAY ]]; then
        echo "INFO: set default gateway"
        ip route add default via $VROUTER_GATEWAY
    fi
else
    echo "INFO: vhost0 is already up"
fi

exec "$@"

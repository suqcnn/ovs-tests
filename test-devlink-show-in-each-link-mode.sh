#!/bin/bash
#
# Bug SW #1056223: kernel oops when calling devlink show and hca is in
# infiniband mode
#
# Requires CX-5 (MT4121)
#

NIC=${1:-ens5f0}
my_dir="$(dirname "$0")"
. $my_dir/common.sh

# TODO exit if nic not supporting link type
require_mlxconfig


function set_link_type() {
    local mode=$1
    mlxconfig -y -d $PCI set LINK_TYPE_P1=$mode LINK_TYPE_P2=$mode
}

function set_link_type_ib() {
    set_link_type IB
}

function set_link_type_eth() {
    set_link_type ETH
}

function fw_reset() {
    mlxfwreset -y -d $PCI reset
}

function devlink_eswitch_show() {
    devlink dev eswitch show pci/$PCI
}


start_check_syndrome

title "Test devlink show in IB mode"
set_link_type IB || fail
fw_reset
devlink_eswitch_show
success

title "Test devlink show in ETH mode"
set_link_type ETH || fail
fw_reset
devlink_eswitch_show
success

set_macs 2
check_syndrome
check_kasan
test_done

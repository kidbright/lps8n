#!/bin/sh

echo "==========================================="
echo "KidBright Net installation script for lps8n"
echo "==========================================="

KBNET_DIR=/root/kbnet
TMP_DIR=/tmp/kbnet_install
MOSQUITTO_CONF=/etc/mosquitto/mosquitto.conf

# create kbnet directory
mkdir -p $KBNET_DIR
rm -rf $TMP_DIR
mkdir -p $TMP_DIR

# set default VERBOSE if not defined
if [ "$VERBOSE" != "0" ] && [ "$VERBOSE" != "1" ]; then
	VERBOSE=0
fi

# run command function
run_cmd() {
	[ "$VERBOSE" != "0" ] && $1 || $1>/dev/null 2>&1
}

# internet check
echo -ne "internet check... "
run_cmd "ping -c 1 www.google.com"
RES=$?
if [ $RES -ne 0 ]; then
	echo "no internet"
	exit 1
fi
echo "ok"

# download files
echo -ne "download files... "
cd $TMP_DIR
wget -q https://github.com/kidbright/lps8n/raw/main/kbnet_install_lps8n_files.tgz
tar xf kbnet_install_lps8n_files.tgz >/dev/null 2>&1
echo "done"

# check kbnet_sub service
run_cmd "pgrep kbnet_sub"
RES=$?
if [ $RES -eq 0 ]; then
	# stop kbnet_sub service
	/etc/init.d/kbnet_sub stop
	/etc/init.d/kbnet_sub disable
	# remove kbnet_sub initd
	rm -f /etc/init.d/kbnet_sub
fi

# check kbnet_fwd service
run_cmd "pgrep kbnet_fwd"
RES=$?
if [ $RES -eq 0 ]; then
	# stop kbnet_fwd service
	/etc/init.d/kbnet_fwd stop
	/etc/init.d/kbnet_fwd disable
	# remove kbnet_fwd initd
	rm -f /etc/init.d/kbnet_fwd
fi

# install kbnet
echo -ne "kbnet install... "
rm -rf $KBNET_DIR
cp -r $TMP_DIR/kbnet_install_lps8n_files/kbnet /root
echo "done"

# opkg update
echo -ne "opkg update... "
run_cmd "opkg update"
RES=$?
if [ $RES -ne 0 ]; then
	echo "error($RES)"
	exit 1
fi
echo "done"

# install mosquitto-nossl
echo -ne "mosquitto-nossl install... "
run_cmd "pgrep mosquitto"
RES=$?
if [ $RES -eq 0 ]; then
	# uninstall mosquitto-nossl
	run_cmd "opkg remove mosquitto-nossl"
fi
run_cmd "opkg install mosquitto-nossl"
RES=$?
if [ $RES -eq 0 ]; then
	echo "done"
else
	echo "error($RES)"
fi

# config mqtt firewall
echo -ne "mqtt config... "
run_cmd "uci show firewall | grep mqtt"
if [ $RES -eq 0 ]; then
	echo "configure... "
	uci add firewall redirect >/dev/null
	uci set firewall.@redirect[-1].name='mqtt'
	uci set firewall.@redirect[-1].src='wan'
	uci set firewall.@redirect[-1].src_dport='1883'
	uci set firewall.@redirect[-1].dest_port='11883'
	uci set firewall.@redirect[-1].proto='tcp'
	uci set firewall.@redirect[-1].dest='lan'
	uci set firewall.@redirect[-1].target='DNAT'
	uci commit firewall
fi
echo "" >> $MOSQUITTO_CONF
echo "port 11883" >> $MOSQUITTO_CONF
echo "max_connections 16" >> $MOSQUITTO_CONF
echo "protocol mqtt" >> $MOSQUITTO_CONF
echo "done"

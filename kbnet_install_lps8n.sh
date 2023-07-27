#!/bin/sh

sleep 1
echo "==========================================="
echo "KidBright Net installation script for lps8n"
echo "==========================================="

KBNET_DIR=/root/kbnet
TMP_DIR=/tmp/kbnet_install

# create kbnet directory
mkdir -p $KBNET_DIR
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

# opkg update
echo -ne "opkg update... "
run_cmd "opkg update"
RES=$?
if [ $RES -ne 0 ]; then
	echo "error($RES)"
	exit 1
fi
echo "ok"

# check kbnet_sub service
echo -ne "kbnet_sub check... "
run_cmd "pgrep kbnet_sub"
RES=$?
if [ $RES -eq 0 ]; then
	echo "found"
	# uninstall kbnet_sub
	echo -ne "uninstall kbnet_sub... "
	# stop kbnet_sub service
	/etc/init.d/kbnet_sub stop
	/etc/init.d/kbnet_sub disable
	# remove kbnet_sub initd
	rm -f /etc/init.d/kbnet_sub
	# uninstall kbnet_sub service
	rm -f $KBNET_DIR/kbnet_sub
	echo "done"
else
	echo "not found"
fi
# install kbnet_sub service

# check kbnet_fwd service
echo -ne "kbnet_fwd check... "
run_cmd "pgrep kbnet_fwd"
RES=$?
if [ $RES -eq 0 ]; then
	echo "found"
	# uninstall kbnet_fwd
	echo -ne "uninstall kbnet_fwd... "
	# stop kbnet_fwd service
	/etc/init.d/kbnet_fwd stop
	/etc/init.d/kbnet_fwd disable
	# remove kbnet_fwd initd
	rm -f /etc/init.d/kbnet_fwd
	# uninstall kbnet_fwd service
	rm -f $KBNET_DIR/kbnet_fwd
	echo "done"
else
	echo "not found"
fi
# install kbnet_fwd service

# check mosquitto-nossl
echo -ne "mosquitto-nossl check... "
run_cmd "pgrep mosquitto"
RES=$?
if [ $RES -eq 0 ]; then
	echo "found"
	# uninstall mosquitto-nossl
	echo -ne "uninstall mosquitto-nossl... "
	run_cmd "opkg remove mosquitto-nossl"
	echo "done"
else
	echo "not found"
fi
# install mosquitto-nossl service

\#!/bin/sh
vpn_config="$(echo $OPENVPN_CONFIG | tr '[A-Z]' '[a-z]')"

echo "Starting OpenVPN using config ${OPENVPN_CONFIG}"
OPENVPN_CONFIG=${OPENVPN_CONFIG}

TRANSMISSION_CONTROL_OPTS="--script-security 2 --down /transmission/stop.sh"

if [ -n "${LOCAL_NETWORK-}" ]; then
  eval $(/sbin/ip r l m 0.0.0.0 | awk '{if($5!="tun0"){print "GW="$3"\nINT="$5; exit}}')
  if [ -n "${GW-}" -a -n "${INT-}" ]; then
    echo "adding route to local network $LOCAL_NETWORK via $GW dev $INT"
    /sbin/ip r d "$LOCAL_NETWORK" via "$GW" dev "$INT"
    /sbin/ip r a "$LOCAL_NETWORK" via "$GW" dev "$INT"
  fi
fi

# create unpriv-ip command
touch /usr/local/sbin/unpriv-ip
echo "#!/bin/sh\n\nsudo /sbin/ip \$*" > /usr/local/sbin/unpriv-ip
chmod 755 /usr/local/sbin/unpriv-ip

# sudoers modification openvpn user to user /sbin/ip

echo "openvpn ALL=(ALL) NOPASSWD: /sbin/ip" >> /etc/sudoers
echo "Defaults:openvpn !requiretty" >> /etc/sudoers

echo "removing tun0..."
openvpn --rmtun --dev tun0
echo "creating tun0..."
openvpn --mktun --dev tun0 --dev-type tun --user openvpn --group openvpn
su openvpn -s /bin/sh --command="/usr/sbin/openvpn $TRANSMISSION_CONTROL_OPTS --config $OPENVPN_CONFIG" &
sleep 15
/transmission/start.sh

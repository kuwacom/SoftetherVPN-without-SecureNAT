TAP_ADDR=192.168.10.1
TAP_DHCP_RANGE=192.168.10.10,192.168.10.200
TAP_INTERFACE=tap_vpn
VPN_SUBNET=192.168.10.0/24
NET_INTERFACE=eth0
VPNEXTERNALIP=$(ip -f inet -o addr show "${NET_INTERFACE}" | cut -d\  -f 7 | cut -d/ -f 1)

apt update
apt install nano
sudo yes | apt install net-tools
sudo yes | apt install iptables-persistent
sudo yes | apt install dnsmasq
apt install make
sudo yes | apt install gcc

#iptables setting
iptables -F && iptables -X
/sbin/ifconfig $TAP_INTERFACE $TAP_ADDR

iptables -t nat -A POSTROUTING -s $VPN_SUBNET -j SNAT --to-source $VPNEXTERNALIP

iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT

iptables -A INPUT -s $VPN_SUBNET -m state --state NEW -j ACCEPT
iptables -A OUTPUT -s $VPN_SUBNET -m state --state NEW -j ACCEPT
iptables -A FORWARD -s $VPN_SUBNET -m state --state NEW -j ACCEPT


wget https://github.com/SoftEtherVPN/SoftEtherVPN_Stable/releases/download/v4.29-9680-rtm/softether-vpnserver-v4.29-9680-rtm-2019.02.28-linux-x64-64bit.tar.gz
tar -xzvf softether-vpnserver-v4.29-9680-rtm-2019.02.28-linux-x64-64bit.tar.gz
cd vpnserver
yes 1 | make
cd ../
sudo mv vpnserver /usr/local
cd /usr/local/vpnserver
sudo chmod 600 *
sudo chmod 700 vpncmd vpnserver

/usr/local/vpnserver/vpnserver start
#Login to vpncmd
echo "===== Please enter the following code to vpncmd =====
ServerPasswordSet <Your admin password>
HubDelete DEFAULT
HubCreate vpn-hub /PASSWORD:<hub password>
BridgeCreate vpn-hub /DEVICE:vpn /TAP:yes
Hub vpn-hub
GroupCreate Admin /REALNAME:none /NOTE:none
UserCreate <user name> /GROUP:Admin /NOTE:none /REALNAME:none
UserPasswordSet <user name> /password:<user password>
exit
*if doesn't open vpncmd, when please enter \"/usr/local/vpnserver/vpncmd /server localhost\"*
"
/usr/local/vpnserver/vpncmd /server localhost

echo "if finish to first script, please run second script..."

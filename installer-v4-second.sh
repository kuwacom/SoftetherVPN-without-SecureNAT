TAP_ADDR=192.168.10.1
TAP_DHCP_RANGE=192.168.10.10,192.168.10.200
TAP_INTERFACE=tap_vpn
VPN_SUBNET=192.168.10.0/24
NET_INTERFACE=eth0
VPNEXTERNALIP=$(ip -f inet -o addr show "${NET_INTERFACE}" | cut -d\  -f 7 | cut -d/ -f 1)


echo -e "[Unit]
Description=SoftEther VPN Server
After=network.target
[Service]
Type=forking
User=root
ExecStart=/usr/local/vpnserver/vpnserver start
ExecStop=/usr/local/vpnserver/vpnserver stop
ExecStartPost=/bin/sleep 05
ExecStartPost=/sbin/ifconfig ${TAP_INTERFACE} ${TAP_ADDR}
ExecStartPost=/bin/sleep 03
ExecStartPost=/bin/systemctl start dnsmasq.service
ExecReload=/bin/sleep 05
ExecReload=/sbin/ifconfig ${TAP_INTERFACE} ${TAP_ADDR}
ExecReload=/bin/sleep 03
ExecReload=/bin/systemctl restart dnsmasq.service
ExecStopPost=/bin/systemctl stop dnsmasq.service
Restart=always
Restart=on-failure
RestartSec=3s
[Install]
WantedBy=multi-user.target" > /etc/systemd/system/vpnserver.service
sudo systemctl daemon-reload

#DHCPsetting
echo -e "# In this case it is the Softether bridge
interface=${TAP_INTERFACE}

# Don't ever listen to anything on eth0, you wouldn't want that.
except-interface=${NET_INTERFACE}

listen-address=${TAP_ADDR}
bind-interfaces

# Let's give the connecting clients an internal IP
dhcp-range=${TAP_INTERFACE},${TAP_DHCP_RANGE},720h

# Default route and dns
dhcp-option=${TAP_INTERFACE},3,${TAP_ADDR}

# enable dhcp
dhcp-authoritative

# enable IPv6 Route Advertisements
enable-ra

#  have your simple hosts expanded to domain
expand-hosts

# Let dnsmasq use the dns servers in the order you chose.
strict-order

# Let's try not giving the same IP to all, right?
dhcp-no-override

# The following directives prevent dnsmasq from forwarding plain names (without any dots)
# or addresses in the non-routed address space to the parent nameservers.
domain-needed

# Never forward addresses in the non-routed address spaces
bogus-priv


# blocks probe-machines attack
stop-dns-rebind
rebind-localhost-ok

# Set the maximum number of concurrent DNS queries. The default value is 150. Adjust to your needs.
dns-forward-max=300

# stops dnsmasq from getting DNS server addresses from /etc/resolv.conf
# but from below
no-resolv
no-poll

# Prevent Windows 7 DHCPDISCOVER floods
dhcp-option=252,\"\"

# Use this DNS servers for incoming DNS requests
server=1.1.1.1
server=8.8.4.4

# Use these IPv6 DNS Servers for lookups/ Google and OpenDNS
server=2620:0:ccd::2
server=2001:4860:4860::8888
server=2001:4860:4860::8844

# Set IPv4 DNS server for client machines # option:6
dhcp-option=option:dns-server,${TAP_ADDR},176.103.130.130

# Set IPv6 DNS server for clients
dhcp-option=option6:dns-server,[2a00:5a60::ad2:0ff],[2a00:5a60::ad1:0ff]

# How many DNS queries should we cache? By defaults this is 150
# Can go up to 10k.
cache-size=10000

neg-ttl=80000
local-ttl=3600

# TTL
dhcp-option=23,64

# value as a four-byte integer - that's what microsoft wants. See
dhcp-option=vendor:MSFT,2,1i

dhcp-option=44,${TAP_ADDR} # set netbios-over-TCP/IP nameserver(s) aka WINS server(s)
dhcp-option=45,${TAP_ADDR} # netbios datagram distribution server
dhcp-option=46,8         # netbios node type
dhcp-option=47

read-ethers

log-facility=/var/log/dnsmasq.log
log-async=5

log-dhcp
quiet-dhcp6

# Gateway
dhcp-option=3,${TAP_ADDR}" > /etc/dnsmasq.conf


#NATsetting
echo -e "net.core.somaxconn=4096
net.ipv4.ip_forward=1
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.all.accept_redirects = 1 
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.send_redirects = 1
net.ipv4.conf.default.proxy_arp = 0

net.ipv6.conf.all.forwarding=1
net.ipv6.conf.default.forwarding = 1
net.ipv6.conf.tap_softether.accept_ra=2
net.ipv6.conf.all.accept_ra = 1
net.ipv6.conf.all.accept_source_route=1
net.ipv6.conf.all.accept_redirects = 1
net.ipv6.conf.all.proxy_ndp = 1" > /etc/sysctl.conf
sysctl -f


sudo systemctl enable vpnserver
systemctl enable dnsmasq
sudo systemctl start vpnserver
systemctl start dnsmasq

reboot

Description
===========
Install and configure a DHCP3 server, optionally configuring it to automatically
register hosts with a Bind9 name server.

Installation
===========
sudo apt install isc-dhcp-server


Requirements
============
Ubuntu. Other platforms were not tested.

Attributes
==========
+ `domain` - The domain name to update.
+ `subnets` - Subnets to use for allocating IP addresses. See example below.
+ `subnet` - A specific subnet from `subnets` to use on this node.
+ `conf_dif` - Location to place configuration files (defaults to `/etc/dhcp3`).

Usage
=====
*Configure:*
~~~
nano /etc/dhcp/dhcpd.conf
~~~
~~~
ddns-update-style none;
authoritative;
log-facility local7;
subnet 192.168.0.0 netmask 255.255.255.0 {
range 192.168.0.100 192.168.0.200;
option domain-name-servers 8.8.8.8;
option routers 192.168.1.1;
option broadcast-address 192.168.1.255;
default-lease-time 600;
max-lease-time 7200;
}
~~~
add INTERFACESv4="eth0"
~~~
nano /etc/init.d/isc-dhcp-server
~~~
~~~
# use already specified config file or fallback to defaults
DHCPDv4_CONF=${DHCPDv4_CONF:-/etc/dhcp/dhcpd.conf}
DHCPDv6_CONF=${DHCPDv6_CONF:-/etc/dhcp/dhcpd6.conf}
INTERFACESv4="eth0"
~~~

The `subnets` attribute needs to describe a subnet to alloacate IP addresses
from, like this:
~~~
    "subnets": {
        "secure": {
            "network": "10.1.0.0",
            "netmask": "255.255.0.0",
            "broadcast": "10.1.255.255",
            "range_start": "10.1.13.50",
            "range_end": "10.1.255.200",
            "router": "10.1.0.1",
            "iface": "eth0"
        },
        "dmz": {
            "network": "10.2.0.0",
            "netmask": "255.255.0.0",
            "broadcast": "10.2.255.255",
            "range_start": "10.2.14.1",
            "range_end": "10.2.255.200",
            "router": "10.2.0.1",
            "iface": "eth0"
        }
    }
~~~
Additionally, a zone file similar to the one used by the Bind9 cookbook is
needed, with the following attributes under the domain name matching the DHCP
node's domain attribute:
~~~
    "dhcp": {
        "ttl": 60,
        "lease-time": 3600,
        "max-lease-time": 3600
    }
~~~
TODO
====
+ `subnets` is currently expected to be found on the node itself, leading to it
  being placed on the environment (as a default attribute). Need to change it to
  be read from a separate data bag item.

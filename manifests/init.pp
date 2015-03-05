#
# == Class: dnsmasq
#
# Install and configure dnsmasq
#
# == Parameters
#
# [*listen_interface*]
#   Network interface to listen on. Currently only one interface is supported, 
#   even though dnsmasq could manage several. Use special value 'any' to listen 
#   to all interfaces.
# [*lan_domain*]
#   Domain name for the LAN. Defaults to 'local'.
# [*lan_broadcast*]
#   Broadcast address for the LAN.
# [*lan_dhcp_range_start*]
#   First IP address in the DHCP address range. Addresses in this range will be 
#   given for hosts that don't have a static IP assigned to them using the 
#   dhcp-hosts parameter.
# [*lan_dhcp_range_end*]
#   Last IP address in the DHCP address range.
# [*mail_server*]
#   Hostname of the LAN's SMTP server. For example 'smtp.domain.com'.
# [*ignore_resolvconf*]
#   Do not read /etc/resolv.conf on the dnsmasq host. This is useful if you want 
#   to use dnsmasq's DNS on the dnsmasq host itself. Valid values 'yes' 
#   (default) and 'no'. Note that if this is set to 'yes', you need to have one 
#   or more upstream servers defined in $upstream_dns_servers parameter.
# [*dhcp_hosts*]
#   An array of dhcp-host entries in the dnsmasq.conf format. For example
#   [ '00:17:F2:3D:41:31,alice,10.94.99.2',
#     '54:52:00:2A:2E:8b,joe,10.94.99.3' ]
# [*default_router*]
#   The IP address of the default router to announce to DHCP clients.
# [*dns_server*]
#   The DNS server to announce to DHCP clients. Typically the IP address of the 
#   dnsmasq server.
# [*upstream_dns_servers*]
#   An array of upstream server definitions in dnsmasq.conf format. For example
#   ['1.2.3.4', '/google.com/2.3.4.5'].
# [*dns_allow_address_ipv4*]
#   An IPv4 address/subnet from which to allow connections. Defaults to '127.0.0.1'.
# [*dns_allow_address_ipv6*]
#   An IPv6 address/subnet from which to allow connections. Defaults to '::1'.
# [*monitor_email*]
#   Server monitoring email. Defaults to $::servermonitor.
#
# == Authors
#
# Samuli Seppänen <samuli.seppanen@gmail.com>
#
# == License
#
# BSD-license. See file LICENSE for details.
#
class dnsmasq
(
    $listen_interface,
    $lan_domain = 'local',
    $lan_broadcast,
    $lan_dhcp_range_start,
    $lan_dhcp_range_end,
    $mail_server,
    $ignore_resolvconf = 'yes',
    $dhcp_hosts = '',
    $default_router,
    $dns_server,
    $upstream_dns_servers = '',
    $dns_allow_ipv4_address = '127.0.0.1',
    $dns_allow_ipv6_address = '::1',
    $monitor_email = $::servermonitor
)
{
    include dnsmasq::install

    class { 'dnsmasq::config':
        listen_interface => $listen_interface,
        lan_domain => $lan_domain,
        lan_broadcast => $lan_broadcast,
        lan_dhcp_range_start => $lan_dhcp_range_start,
        lan_dhcp_range_end => $lan_dhcp_range_end,
        mail_server => $mail_server,
        dhcp_hosts => $dhcp_hosts,
        default_router => $default_router,
        dns_server => $dns_server,
        ignore_resolvconf => $ignore_resolvconf,
        upstream_dns_servers => $upstream_dns_servers,
    }

    include dnsmasq::service

    if tagged('packetfilter') {
        class { 'dns::packetfilter':
            allow_address_ipv4 => $dns_allow_address_ipv4,
            allow_address_ipv6 => $dns_allow_address_ipv6,
        }
    }

    if tagged('monit') {
        class { 'dnsmasq::monit':
            monitor_email => $monitor_email,
        }
    }
}

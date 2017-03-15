#
# == Class: dnsmasq
#
# Install and configure dnsmasq
#
# == Parameters
#
# [*manage*]
#   Manage dnsmasq with Puppet. Valid values are true (default) and false.
# [*manage_packetfilter*]
#   Manage packet filtering rules. Valid values are true (default) and false.
# [*manage_monit*]
#   Manage monit rules. Valid values are true (default) and false.
# [*listen_interfaces*]
#   An array of network interfaces to listen on. Valid values 'local' (default, 
#   listen on localhost addresses only), 'any' (listen on all interfaces) and 
#   any array of valid interface names. Note that if 'any' is defined, DNS 
#   requests may still get blocked by the --local-service option in dnsmasq.
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
# [*dhcp_allow_iface*]
#   Allow inbound DHCP requests throuh the firewall from the specified network 
#   interface. Use special value 'any' to allow DHCP requests from any 
#   interface. Defaults to the value of $listen_interfaces. 
# [*hosts*]
#   A hash "host" resources to materialize. This allows dnsmasq to resolve hosts 
#   that have static IPs.
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
    $manage = true,
    $manage_packetfilter = true,
    $manage_monit = true,
    $listen_interfaces = 'local',
    $lan_domain = 'local',
    $lan_broadcast,
    $lan_dhcp_range_start,
    $lan_dhcp_range_end,
    $mail_server,
    $ignore_resolvconf = 'yes',
    $dhcp_hosts = undef,
    $default_router,
    $dns_server,
    $upstream_dns_servers = undef,
    $dns_allow_address_ipv4 = '127.0.0.1',
    $dns_allow_address_ipv6 = '::1',
    $dhcp_allow_iface = undef,
    $hosts = {},
    $monitor_email = $::servermonitor
)
{
    if $manage {

    include ::dnsmasq::install

    class { '::dnsmasq::config':
        listen_interfaces    => $listen_interfaces,
        lan_domain           => $lan_domain,
        lan_broadcast        => $lan_broadcast,
        lan_dhcp_range_start => $lan_dhcp_range_start,
        lan_dhcp_range_end   => $lan_dhcp_range_end,
        mail_server          => $mail_server,
        dhcp_hosts           => $dhcp_hosts,
        default_router       => $default_router,
        dns_server           => $dns_server,
        ignore_resolvconf    => $ignore_resolvconf,
        upstream_dns_servers => $upstream_dns_servers,
    }

    include ::dnsmasq::service

    create_resources('host', $hosts)

    if $manage_packetfilter {

        $dhcp_iniface = $dhcp_allow_iface ? {
            undef   => $listen_interfaces,
            default => $dhcp_allow_iface,
        }

        class { '::dhcp::packetfilter':
            iniface => $dhcp_iniface,
        }

        class { '::dns::packetfilter':
            allow_address_ipv4 => $dns_allow_address_ipv4,
            allow_address_ipv6 => $dns_allow_address_ipv6,
        }
    }

    if $manage_monit {
        class { '::dnsmasq::monit':
            monitor_email => $monitor_email,
        }
    }
    }
}

#
# == Class: dnsmasq::config
#
# Configure dnsmasq
#
class dnsmasq::config
(
    $listen_interface,
    $lan_domain,
    $lan_broadcast,
    $lan_dhcp_range_start,
    $lan_dhcp_range_end,
    $mail_server,
    $ignore_resolvconf,
    $dhcp_hosts,
    $upstream_dns_servers

) inherits dnsmasq::params
{
    # Get this node's IP based on DNS query done on the puppetmaster. The 
    # ipaddress fact is worthless on nodes with several active interfaces. 
    # Google "puppet facter ipaddress" for details.
    $ipv4_address = generate("/usr/local/bin/getip.sh", "-4", "$fqdn")

    # We can't use the $dhcp_hosts and $upstream_dns_servers variables as is, or 
    # the logic in the ERB template breaks.
    unless $dhcp_hosts == '' {
        $hosts = $dhcp_hosts
    }
    unless $upstream_dns_servers == '' {
        $servers = $upstream_dns_servers
    }

    if $ignore_resolvconf == 'yes' {
        $no_resolv_line = 'no-resolv'
    }

    file { 'dnsmasq-dnsmasq.conf':
        name => $::dnsmasq::params::config_name,
        content => template('dnsmasq/dnsmasq.conf.erb'),
        ensure => present,
        owner => $::os::params::adminuser,
        group => $::os::params::admingroup,
        require => Class['dnsmasq::install'],
        notify => Class['dnsmasq::service'],
    }
}

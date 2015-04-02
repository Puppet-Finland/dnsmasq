#
# == Class: dnsmasq::config
#
# Configure dnsmasq
#
class dnsmasq::config
(
    $listen_interfaces,
    $lan_domain,
    $lan_broadcast,
    $lan_dhcp_range_start,
    $lan_dhcp_range_end,
    $mail_server,
    $ignore_resolvconf,
    $dhcp_hosts,
    $default_router,
    $dns_server,
    $upstream_dns_servers

) inherits dnsmasq::params
{

    # Define which interfaces to listen on
    $interfaces = $listen_interfaces ? {
        'local' => [''],
        'any' => ['*'],
        default => $listen_interfaces,
    }

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

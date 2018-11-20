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
    $auth_zones,
    $mail_server,
    $ignore_resolvconf,
    $dhcp_hosts,
    $default_router,
    $dns_server,
    $localise_queries,
    $upstream_dns_servers

) inherits dnsmasq::params
{

    # Ensure that auth_zones is an array when it gets to the template
    $auth_zone_list = any2array($auth_zones)

    # Define which interfaces to listen on
    $interfaces = $listen_interfaces ? {
        'local' => [''],
        'any' => ['*'],
        default => $listen_interfaces,
    }

    # We can't use the $dhcp_hosts and $upstream_dns_servers variables as is, or 
    # the logic in the ERB template breaks.
    if $dhcp_hosts {
        $hosts = $dhcp_hosts
    }
    if $upstream_dns_servers {
        $servers = $upstream_dns_servers
    }

    if $ignore_resolvconf == 'yes' {
        $no_resolv_line = 'no-resolv'
    }

    $localise_queries_line = $localise_queries ? {
        true  => 'localise_queries',
        false => '#localise_queries',
        default => '#localise_queries',
    }

    file { 'dnsmasq-dnsmasq.conf':
        ensure  => present,
        name    => $::dnsmasq::params::config_name,
        content => template('dnsmasq/dnsmasq.conf.erb'),
        owner   => $::os::params::adminuser,
        group   => $::os::params::admingroup,
        require => Class['dnsmasq::install'],
        notify  => Class['dnsmasq::service'],
    }
}

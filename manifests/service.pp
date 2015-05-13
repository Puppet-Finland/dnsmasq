#
# == Class: dnsmasq::service
#
# Enable dnsmasq service on boot
#
class dnsmasq::service inherits dnsmasq::params {

    service { 'dnsmasq-dnsmasq':
        name    => $::dnsmasq::params::service_name,
        enable  => true,
        require => Class['dnsmasq::config'],
    }
}

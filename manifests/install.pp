#
# == Class: dnsmasq::install
#
# Install dnsmasq
#
class dnsmasq::install inherits dnsmasq::params
{
    package { 'dnsmasq-dnsmasq':
        ensure => installed,
        name   => $::dnsmasq::params::package_name,
    }
}

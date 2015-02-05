#
# == Class: dnsmasq::install
#
# Install dnsmasq
#
class dnsmasq::install inherits dnsmasq::params
{
    package { 'dnsmasq-dnsmasq':
        name => $::dnsmasq::params::package_name,
        ensure => installed,
    }
}

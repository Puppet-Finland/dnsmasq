#
# == Class: dnsmasq::params
#
# Defines some variables based on the operating system
#
class dnsmasq::params {

    include os::params  

    case $::osfamily {
        'Debian': {
            $package_name = 'dnsmasq'
            $config_name = '/etc/dnsmasq.conf'
            $service_name = 'dnsmasq'
            $pidfile = '/var/run/dnsmasq/dnsmasq.pid'
            $service_start = "/usr/sbin/service $service_name start"
            $service_stop = "/usr/sbin/service $service_name stop"
        }
        default: {
            fail("Unsupported OS: ${::osfamily}")
        }
    }
}

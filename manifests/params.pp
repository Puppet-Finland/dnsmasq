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
        }
        default: {
            fail("Unsupported OS: ${::osfamily}")
        }
    }

    if $::has_systemd == 'true' {
        $service_start = "${::os::params::systemctl} start ${service_name}"
        $service_stop = "${::os::params::systemctl} stop ${service_name}"
    } else {
        $service_start = "${::os::params::service_cmd} ${service_name} start"
        $service_stop = "${::os::params::service_cmd} ${service_name} stop"
    }
}

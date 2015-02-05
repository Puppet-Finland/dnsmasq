class dnsmasq::monit
(
    $monitor_email

) inherits dnsmasq::params
{
    monit::fragment { 'dnsmasq-dnsmasq.monit':
        modulename => 'dnsmasq',
    }
}

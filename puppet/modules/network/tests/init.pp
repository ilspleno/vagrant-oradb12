# The baseline for module testing used by Puppet Labs is that each manifest
# should have a corresponding test manifest that declares that class or defined
# type.
#
# Tests are then run by using puppet apply --noop (to check for compilation
# errors and view a log of events) or by fully applying the test in a virtual
# environment (to compare the resulting system state to the desired state).
#
# Learn more about module testing here:
# http://docs.puppetlabs.com/guides/tests_smoke.html
#
#
#
# You can execute this manifest as follows in your vagrant box:
#
#      sudo puppet apply -t /vagrant/tests/init.pp
#
node default {

    include network

    network::interface { 'tap0':
        ensure          => 'present',
        address         => '10.20.30.40',
        netmask         => '255.255.0.0',
        network         => '10.20.0.0',
        broadcast       => '10.20.255.255',
        gateway         => '10.20.0.1',
        dns_nameservers => [ '10.20.0.254', '10.21.0.254'],
        dns_search      => 'uni.lu'
    }

}

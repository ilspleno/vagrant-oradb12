# File::      <tt>debian.pp</tt>
# Author::    Sebastien Varrette (Sebastien.Varrette@uni.lu)
# Copyright:: Copyright (c) 2011 Sebastien Varrette
# License::   GPLv3
#
# ------------------------------------------------------------------------------
# = Class: network::common::debian
#
# Specialization class for Debian systems
class network::common::debian inherits network::common {

    concat { $network::params::interfacesfile:
        owner   => $network::params::interfacesfile_owner,
        group   => $network::params::interfacesfile_group,
        mode    => $network::params::interfacesfile_mode,
        warn    => true,
        require => File[$network::params::configdir],
        notify  => Service[$network::params::servicename]
    }

    # Header of the file
    concat::fragment { 'network_interfaces_header':
        ensure  => 'present',
        target  => $network::params::interfacesfile,
        content => template('network/01-interfaces_header.erb'),
        order   => 01,
    }

}

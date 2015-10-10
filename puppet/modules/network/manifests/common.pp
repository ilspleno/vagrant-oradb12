# File::      <tt>common.pp</tt>
# Author::    Sebastien Varrette (Sebastien.Varrette@uni.lu)
# Copyright:: Copyright (c) 2011 Sebastien Varrette
# License::   GPLv3
#
# ------------------------------------------------------------------------------
# = Class: network::common
#
# Base class to be inherited by the other network classes
#
# Note: respect the Naming standard provided here[http://projects.puppetlabs.com/projects/puppet/wiki/Module_Standards]
class network::common {

    # Load the variables used in this module. Check the network-params.pp file
    require network::params

    file { $network::params::configdir:
        ensure => 'directory',
        owner  => $network::params::configdir_owner,
        group  => $network::params::configdir_group,
        mode   => $network::params::configdir_mode,
    }

    service { $network::params::servicename:
        ensure     => running,
        enable     => true,
        pattern    => $network::params::processname,
        hasrestart => $network::params::hasrestart,
        hasstatus  => $network::params::hasstatus,
    }

}

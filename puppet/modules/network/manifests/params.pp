# File::      <tt>params.pp</tt>
# Author::    Sebastien Varrette (Sebastien.Varrette@uni.lu)
# Copyright:: Copyright (c) 2011 Sebastien Varrette
# License::   GPL v3
#
# ------------------------------------------------------------------------------
# = Class: network::params
#
# In this class are defined as variables values that are used in other
# network classes.
# This class should be included, where necessary, and eventually be enhanced
# with support for more OS
#
# == Warnings
#
# /!\ Always respect the style guide available
# here[http://docs.puppetlabs.com/guides/style_guide]
#
# The usage of a dedicated param classe is advised to better deal with
# parametrized classes, see
# http://docs.puppetlabs.com/guides/parameterized_classes.html
#
# [Remember: No empty lines between comments and class definition]
#
class network::params {

    ######## DEFAULTS FOR VARIABLES USERS CAN SET ##########################
    # (Here are set the defaults, provide your custom variables externally)
    # (The default used is in the line with '')
    ###########################################


    #### MODULE INTERNAL VARIABLES  #########
    # (Modify to adapt to unsupported OSes)
    #######################################

    $servicename = $::operatingsystem ? {
        /(?i-mx:ubuntu|debian)/ => 'networking',
        default                 => 'network'
    }

    $processname = $::operatingsystem ? {
        /(?i-mx:ubuntu|debian)/ => 'networking',
        default                 => 'network'
    }

    $hasstatus = $::operatingsystem ? {
        /(?i-mx:ubuntu|debian)/        => false,
        /(?i-mx:centos|fedora|redhat)/ => true,
        default => true,
    }
    $hasrestart = $::operatingsystem ? {
        default => true,
    }

    $configdir = $::operatingsystem ? {
        /(?i-mx:ubuntu|debian)/ => '/etc/network',
        default => '/etc/sysconfig/network-scripts'
    }
    $configdir_mode = $::operatingsystem ? {
        default => '0755',
    }
    $configdir_owner = $::operatingsystem ? {
        default => 'root',
    }
    $configdir_group = $::operatingsystem ? {
        default => 'root',
    }

    # This is the interface file
    # TODO: adapt later for centos etc...
    $interfacesfile = $::operatingsystem ? {
        /(?i-mx:ubuntu|debian)/ => '/etc/network/interfaces',
        default => ''
    }
    $ifcfg_prefix = $::operatingsystem ? {
        /(?i-mx:centos|fedora|redhat)/ => 'ifcfg-',
        default => ''

    }
    $interfacesfile_mode = $::operatingsystem ? {
        default => '0644',
    }
    $interfacesfile_owner = $::operatingsystem ? {
        default => 'root',
    }
    $interfacesfile_group = $::operatingsystem ? {
        default => 'root',
    }

    # Prefix used in the concat-fragment resource when configuring a network interface
    $config_interface_label = 'configure_network_interface'

    # $pkgmanager = $::operatingsystem ? {
    #     /(?i-mx:ubuntu|debian)/	       => [ '/usr/bin/apt-get' ],
    #     /(?i-mx:centos|fedora|redhat)/ => [ '/bin/rpm', '/usr/bin/up2date', '/usr/bin/yum' ],
    #     default => []
    # }


}


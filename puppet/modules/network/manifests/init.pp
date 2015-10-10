# File::      <tt>init.pp</tt>
# Author::    Sebastien Varrette (Sebastien.Varrette@uni.lu)
# Copyright:: Copyright (c) 2011 Sebastien Varrette
# License::   GPLv3
#
# ------------------------------------------------------------------------------
# = Class: network
#
# Configure various network aspects (interfaces etc.)
#
# == Parameters:
#
# $ensure:: *Default*: 'present'. Ensure the presence (or absence) of network
#
# == Actions:
#
# Install and configure network
#
# == Requires:
#
# n/a
#
# == Sample Usage:
#
#     import network
#
# You can then specialize the various aspects of the configuration,
# for instance:
#
#         class { 'network':
#             ensure => 'present'
#         }
#
# == Warnings
#
# /!\ Always respect the style guide available
# here[http://docs.puppetlabs.com/guides/style_guide]
#
#
# [Remember: No empty lines between comments and class definition]
#
class network inherits network::params
{
    info ('Configuring network interfaces')


    case $::operatingsystem {
        debian, ubuntu:         { include network::common::debian }
        redhat, fedora, centos: { include network::common::redhat }
        default: {
            fail("Module ${module_name} is not supported on ${::operatingsystem}")
        }
    }
}

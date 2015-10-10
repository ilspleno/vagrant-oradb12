# File::      <tt>params.pp</tt>
# Author::    S. Varrette, H. Cartiaux, V. Plugaru, S. Diehl aka. UL HPC Management Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2015 S. Varrette, H. Cartiaux, V. Plugaru, S. Diehl aka. UL HPC Management Team
# License::   Gpl-3.0
#
# ------------------------------------------------------------------------------
# You need the 'future' parser to be able to execute this manifest (that's
# required for the each loop below).
#
# Thus execute this manifest in your vagrant box as follows:
#
#      sudo puppet apply -t --parser future /vagrant/tests/params.pp
#
#

include 'network::params'

$names = ['servicename', 'processname', 'hasstatus', 'hasrestart', 'configdir', 'configdir_mode', 'configdir_owner', 'configdir_group', 'interfacesfile', 'ifcfg_prefix', 'interfacesfile_mode', 'interfacesfile_owner', 'interfacesfile_group', 'config_interface_label']

notice("network::params::servicename = ${network::params::servicename}")
notice("network::params::processname = ${network::params::processname}")
notice("network::params::hasstatus = ${network::params::hasstatus}")
notice("network::params::hasrestart = ${network::params::hasrestart}")
notice("network::params::configdir = ${network::params::configdir}")
notice("network::params::configdir_mode = ${network::params::configdir_mode}")
notice("network::params::configdir_owner = ${network::params::configdir_owner}")
notice("network::params::configdir_group = ${network::params::configdir_group}")
notice("network::params::interfacesfile = ${network::params::interfacesfile}")
notice("network::params::ifcfg_prefix = ${network::params::ifcfg_prefix}")
notice("network::params::interfacesfile_mode = ${network::params::interfacesfile_mode}")
notice("network::params::interfacesfile_owner = ${network::params::interfacesfile_owner}")
notice("network::params::interfacesfile_group = ${network::params::interfacesfile_group}")
notice("network::params::config_interface_label = ${network::params::config_interface_label}")

#each($names) |$v| {
#    $var = "network::params::${v}"
#    notice("${var} = ", inline_template('<%= scope.lookupvar(@var) %>'))
#}

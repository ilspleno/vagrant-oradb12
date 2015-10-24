node 'ora12.thewoodruffs.org'  {

   include oradb_os
   include oradb_12c
   
   Class['oradb_os']->Class['oradb_12c']
 
} 

# operating settings for Database & Middleware
class oradb_os {

#  $default_params = {}
#  $host_instances = hiera('hosts', [])
#  create_resources('host',$host_instances, $default_params)

#  network::interface { 'eth1':
#	address => '10.0.1.31',
#	netmask => '255.255.255.0',
#        gateway => '10.0.1.1',
#  }  

  service { iptables:
    enable    => false,
    ensure    => false,
    hasstatus => true,
  }


  group { 'dba' :
    ensure      => present,
  }
                                                              
  user { 'oracle' :      
    ensure      => present,
    gid         => 'dba',  
    groups      => 'dba',
    shell       => '/bin/bash',
    password    => '$6$dS2srX/l$FRqEwopSvWwbWMaoPji0jihsim9GSTRSvnuVU.bIijSzcN01iWKgy7TpepUU9yJMzWlhr/xmwJ7dxBC06niGv.',
    home        => "/home/oracle",
    comment     => "This user oracle was created by Puppet",
    require     => Group['dba'],
    managehome  => true,
  }
  
  # N.B. templates do NOT lookup in hiera; need puppet variables
  $oracleBase = hiera('oracle_base_dir')
  $oracleHome = hiera('oracle_home_dir')
  $dbName     = hiera('oracle_database_name')           
  
  file { "/home/oracle/.bash_profile" :
    ensure      => present,
    mode        => "0755",
    owner       => 'oracle',
    group       => 'dba',
    content     => template("oradb/bash_profile.erb"),
    require     => User['oracle'],
  }
  
  file { "/u01":
	ensure => directory,
	owner  => "oracle",
	group  => "dba",
	mode   => "0775",
  }

  file { "/u01/app":
	ensure => directory,
	owner  => "oracle",
	group  => "dba",
	mode   => "0775",
  }


  sysctl { 'kernel.sem':                    ensure => 'present', permanent => 'yes', value => '250 32000 100 128',}
  sysctl { 'kernel.shmall':                 ensure => 'present', permanent => 'yes', value => '2097152',}
  sysctl { 'kernel.shmmax':                 ensure => 'present', permanent => 'yes', value => '4588483584',}
  sysctl { 'kernel.shmmni':                 ensure => 'present', permanent => 'yes', value => '4096', }
  sysctl { 'fs.file-max':                   ensure => 'present', permanent => 'yes', value => '6815744',}
  sysctl { 'fs.aio-max-nr':                 ensure => 'present', permanent => 'yes', value => '1048576',}
  sysctl { 'net.ipv4.ip_local_port_range':  ensure => 'present', permanent => 'yes', value => '9000 65500',}
  sysctl { 'net.core.rmem_default':         ensure => 'present', permanent => 'yes', value => '262144',}
  sysctl { 'net.core.rmem_max':             ensure => 'present', permanent => 'yes', value => '4194304', }
  sysctl { 'net.core.wmem_default':         ensure => 'present', permanent => 'yes', value => '262144',}
  sysctl { 'net.core.wmem_max':             ensure => 'present', permanent => 'yes', value => '1048576',}
  sysctl { 'kernel.panic_on_oops':          ensure => 'present', permanent => 'yes', value => '1',}
  






  $install = [ 'binutils.x86_64', 'compat-libstdc++-33.x86_64', 'glibc.x86_64','ksh.x86_64','libaio.x86_64',
               'libgcc.x86_64', 'libstdc++.x86_64', 'make.x86_64','compat-libcap1.x86_64', 'gcc.x86_64',
               'gcc-c++.x86_64','glibc-devel.x86_64','libaio-devel.x86_64','libstdc++-devel.x86_64', 'ruby',
               'sysstat.x86_64','unixODBC-devel','glibc.i686','libXext','libXtst', 'libXtst.i686','libXext.i686']

  package { $install:
    ensure  => latest,
  }

  limits::fragment {
	"*/soft/nofile":
		value => "2048";
	"*/hard/nofile":
		value => "8192";
	"oracle/soft/nofile":
		value => "65536";
	"oracle/hard/nofile":	
		value => "65536";
	"oracle/soft/nproc":
		value => "2048";
	"oracle/hard/nproc":
		value => "16384";
	"oracle/soft/stack":
		value => "10240";
  }

	file { '/root/asm_provision.rb':
		ensure => 'file',
		source => '/vagrant/scripts/asm_provision.rb',
		owner  => 'root',
		group  => 'root',
		mode   => '0744',
		notify => Exec['asm_provision'],
		require => Package[$install],
	}

	exec { 'asm_provision':
		command => '/root/asm_provision.rb',
		refreshonly => true,
	}
 

}



class oradb_12c {
  require oradb_os    

  oradb::installasm{ 'db_linux-x64':
	  version                   => hiera('grid_version'),
	  file                      => hiera('grid_file'),
	  grid_type                 => 'HA_CONFIG',
	  grid_base                 => hiera('grid_base_dir'),
	  grid_home                 => hiera('grid_home_dir'),
	  ora_inventory_dir         => hiera('oraInventory_dir'),
	  user_base_dir             => '/home',
	  user                      => hiera('grid_os_user'),
	  group                     => 'dba',
	  group_install             => 'dba',
	  group_oper                => 'dba',
	  group_asm                 => 'dba',
	  sys_asm_password          => hiera('ora_password'),
	  asm_monitor_password      => hiera('ora_password'),
	  asm_diskgroup             => 'OCRVOTE',
	  disk_discovery_string     => "/dev/oracleasm/*",
	  disks                     => "/dev/oracleasm/ocrvote1,/dev/oracleasm/ocrvote2,/dev/oracleasm/ocrvote3",
	  disk_redundancy           => "EXTERNAL",
	  download_dir              => hiera('oracle_download_dir'),
	  remote_file               => false,
	  puppet_download_mnt_point => hiera('grid_source'),
  }

  exec { 'asm_diskgroups':
                command => '/vagrant/scripts/asm_diskgroup.sh',
		user    => 'oracle',
                require => Oradb::Installasm['db_linux-x64'],
        }



	oradb::installdb{ '12.1.0.2_Linux-x86-64':
	  version                   => '12.1.0.2',
	  file                      => 'linuxamd64_12102_database',
	  database_type             => 'EE',
	  oracle_base               => '/u01/app/oracle',
	  oracle_home               => '/u01/app/oracle/product/12.1.0/dbhome_1',
	  bash_profile              => true,
	  user                      => 'oracle',
	  group                     => 'dba',
	  group_install             => 'dba',
	  group_oper                => 'dba',
	  download_dir              => '/install',
	  zip_extract               => true,
	  puppet_download_mnt_point => '/software/12cR1/12.1.0.2',
	  require		    => Exec['asm_diskgroups'],
	}

	oradb::database{ 'create_db_wibble':
  oracle_base               => '/u01/app/oracle',
  oracle_home               => '/u01/app/oracle/product/12.1.0/dbhome_1',
  version                   => '12.1',
  user                      => 'oracle',
  group                     => 'dba',
  download_dir              => '/install',
  action                    => 'create',
  db_name                   => 'wibble',
  db_domain                 => 'thewoodruffs.org',
  db_port                   => '1521',
  sys_password              => 'delphi',
  system_password           => 'delphi',
  data_file_destination     => "+DATA",
  recovery_area_destination => "+RECO",
  character_set             => "AL32UTF8",
  nationalcharacter_set     => "UTF8",
  init_params               => {'open_cursors'        => '1000',
                                'processes'           => '600',
                                'job_queue_processes' => '4' },
  sample_schema             => 'FALSE',
  memory_percentage         => "40",
  memory_total              => "2048",
  database_type             => "MULTIPURPOSE",
  em_configuration          => "NONE",
  require                   => Oradb::Installdb['12.1.0.2_Linux-x86-64'],
}
}

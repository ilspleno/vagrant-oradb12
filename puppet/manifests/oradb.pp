node 'ora12.thewoodruffs.org'  {

   include oradb_os
   include oradb_12c
   
   Class['oradb_os']->Class['oradb_12c']
 
} 

# operating settings for Database & Middleware
class oradb_os {

  $default_params = {}
  $host_instances = hiera('hosts', [])
  create_resources('host',$host_instances, $default_params)

  network::interface { 'eth1':
	address => '10.0.1.31',
	netmask => '255.255.255.0',
        gateway => '10.0.1.1',
  }  

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

#  class { 'limits':
#         config => {
#                    '*'       => { 'nofile'  => { soft => '2048'   , hard => '8192',   },},
#                    'oracle'  => { 'nofile'  => { soft => '65536'  , hard => '65536',  },
#                                    'nproc'  => { soft => '2048'   , hard => '16384',  },
#                                    'stack'  => { soft => '10240'  ,},},
#                    },
#         use_hiera => false,
#  }

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

  ora_asm_diskgroup{ 'DATA@+ASM':
	  ensure          => 'present',
	  au_size         => '1',
	  compat_asm      => '12.2.0.0.0',
	  compat_rdbms    => '11.2.0.0.0',
	  diskgroup_state => 'MOUNTED',
	  disks           => {'DATA_0000' => {'diskname' => 'DATA_0001', 'path' => '/dev/oracleasm/disk1'},
			      'DATA_0001' => {'diskname' => 'DATA_0002', 'path' => '/dev/oracleasm/disk2'},
			      'DATA_0002' => {'diskname' => 'DATA_0003', 'path' => '/dev/oracleasm/disk3'},
                             },
	  redundancy_type => 'EXTERNAL',
  }
  ora_asm_diskgroup{ 'RECO@+ASM':
	  ensure          => 'present',
	  au_size         => '1',
	  compat_asm      => '12.2.0.0.0',
	  compat_rdbms    => '11.2.0.0.0',
	  diskgroup_state => 'MOUNTED',
	  disks           => {'RECO_0000' => {'diskname' => 'RECO_0001', 'path' => '/dev/oracleasm/disk4'},
			      'RECO_0001' => {'diskname' => 'RECO_0002', 'path' => '/dev/oracleasm/disk5'},
                             },
	  redundancy_type => 'EXTERNAL',
  }

}                    



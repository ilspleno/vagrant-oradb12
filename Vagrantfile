# -*- mode: ruby -*-
# vi: set ft=ruby :

# User variables - change these as you want

# These variables set how many ASM disks should be allocated, and at what size. udev rules will be created and these disks will be named ocrvote1,ocrvote2 etc.
# or disk001, disk002 etc in /dev/oracleasm
ASM_DISKS=5
ASM_DISK_SIZE=10

OCR_DISKS=3
OCR_DISK_SIZE=3

# The name the VM will be assigned
HOSTNAME="ora12.thewoodruffs.org"

# If PUBLIC_NETWORK is true, the vm will use the host's network interface and get an ip via dhcp, using PUBLIC_INTERFACE as the interface,
# else it uses a vm private network (no access to physical network)
PUBLIC_NETWORK 	 = true
PUBLIC_INTERFACE = "enp4s0f0"

# Bring in some code to verify plugins and create asm disks
require_relative 'lib/plugin_manager.rb'
require_relative 'lib/disk_manager.rb'

@disks_complete = false

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
		
	config.hostmanager.enabled = true
	config.hostmanager.ip_resolver = proc do |vm, resolving_vm|
		if vm.id
			`VBoxManage guestproperty get #{vm.id} "/VirtualBox/GuestInfo/Net/1/V4/IP"`.split()[1]
		end
	end

	config.vm.define "oradb" , primary: true do |oradb|
 		oradb.vm.box = "ilspleno/centos-6-7-puppet-oracle-base"
 		oradb.vm.hostname = HOSTNAME

		if PUBLIC_NETWORK
			oradb.vm.network :public_network, bridge: PUBLIC_INTERFACE
		else
			oradb.vm.network :private_network, type: "dhcp"
		end


		oradb.vm.synced_folder ".", "/vagrant", :mount_options => ["dmode=777","fmode=777"]
		oradb.vm.synced_folder "/vagrant/Software", "/software", :mount_options => ["dmode=755","fmode=755"]

		oradb.vm.provider :virtualbox do |vb|
			vb.customize ["modifyvm"     , :id, "--memory" , "8192"]
			vb.customize ["modifyvm"     , :id, "--name"   , "ora12"]
			vb.customize ["modifyvm"     , :id, "--natnet1", "10.0.3/24"]

			# Call the function in disk_manager.rb to provision disks for ASM
			#create_asm_disks(config, vb) if ARGV[0] == "up"
			create_asm_disks(config, vb)

		end


		oradb.vm.provision :shell, :inline => "ln -sf /vagrant/puppet/hiera.yaml /etc/puppetlabs/code/hiera.yaml"
		oradb.vm.provision :shell, :inline => "ln -sf /vagrant/puppet/hiera.yaml /etc/hiera.yaml"

		oradb.vm.provision :puppet do |puppet|
			puppet.module_path       = "puppet/modules"
			puppet.environment	= "production"
			puppet.environment_path   = "puppet/environments"
			puppet.hiera_config_path = "puppet/hiera.yaml"
			puppet.options           = "--verbose"

			puppet.facter = {
				"vm_type"     => "vagrant",
				"ASM_OS_USER" => 'oracle',	
			}
		end
    
		oradb.vm.network :forwarded_port, guest: 22, host: 2222, id: "ssh", disabled: true
		oradb.vm.network :forwarded_port, guest: 22, host: 2200, auto_correct: true
		oradb.vm.network :forwarded_port, guest: 1521, host: 1521

	end

end

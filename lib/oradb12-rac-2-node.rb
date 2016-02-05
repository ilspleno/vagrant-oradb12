# User variables - change these as you want

# These variables set how many ASM disks should be allocated, and at what size. udev rules will be created and these disks will be named ocrvote1,ocrvote2 etc.
# or disk001, disk002 etc in /dev/oracleasm
ASM_DISKS=5
ASM_DISK_SIZE=10

OCR_DISKS=3
OCR_DISK_SIZE=3

@disks_complete = false


Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
		
	config.hostmanager.enabled = true
	config.hostmanager.ip_resolver = proc do |vm, resolving_vm|
		if vm.id
			`VBoxManage guestproperty get #{vm.id} "/VirtualBox/GuestInfo/Net/1/V4/IP"`.split()[1]
		end
	end

	config.vm.define "node1" , primary: true do |oradb|
 		oradb.vm.box = "ilspleno/centos-6-7-puppet-oracle-base"
 		oradb.vm.hostname = 'node1'

		#oradb.vm.network :private_network, type: "dhcp"
		#oradb.vm.network :private_network, type: "dhcp"
		oradb.vm.network "private_network", ip: "10.0.10.11", virtualbox__intnet: "Public"
		oradb.vm.network "private_network", ip: "10.0.11.11", virtualbox__intnet: "Private"


		oradb.vm.synced_folder ".", "/vagrant", :mount_options => ["dmode=777","fmode=777"]
		oradb.vm.synced_folder "c:/Users/brian/Software", "/software", :mount_options => ["dmode=755","fmode=755"]

		oradb.vm.provider :virtualbox do |vb|
			vb.customize ["modifyvm"     , :id, "--memory" , "4096"]
			vb.customize ["modifyvm"     , :id, "--name"   , "node1"]

			# Call the function in disk_manager.rb to provision disks for ASM
			#create_asm_disks(config, vb) if ARGV[0] == "up"
			create_asm_disks(config, vb, "oradb12-rac", true)

		end


		oradb.vm.network :forwarded_port, guest: 22, host: 2200, auto_correct: true
		oradb.vm.network :forwarded_port, guest: 1521, host: 1521

		oradb.vm.provision :shell, :inline => "cp /vagrant/scripts/id_rsa* /home/vagrant/.ssh"
		oradb.vm.provision :shell, :inline => "chown vagrant:vagrant /home/vagrant/.ssh/id_rsa*"
		oradb.vm.provision :shell, :inline => "cat /home/vagrant/.ssh/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys"
		oradb.vm.provision :shell, :inline => "chmod 600 /home/vagrant/.ssh/id_rsa*"
		oradb.vm.provision :shell, :inline => "yum -y install ansible"
		oradb.vm.provision :shell, :inline => "cd /home/vagrant && git clone https://github.com/ilspleno/ansible-oracle.git"
		oradb.vm.provision :shell, :inline => "chown -R vagrant /home/vagrant/ansible-oracle"

	end

	config.vm.define "node2" , primary: true do |oradb|
 		oradb.vm.box = "ilspleno/centos-6-7-puppet-oracle-base"
 		oradb.vm.hostname = 'node2'

		#oradb.vm.network :private_network, type: "dhcp"
		oradb.vm.network "private_network", ip: "10.0.10.12", virtualbox__intnet: "Public"
		oradb.vm.network "private_network", ip: "10.0.11.12", virtualbox__intnet: "Private"


		oradb.vm.synced_folder ".", "/vagrant", :mount_options => ["dmode=777","fmode=777"]
		oradb.vm.synced_folder "c:/Users/brian/Software", "/software", :mount_options => ["dmode=755","fmode=755"]

		oradb.vm.provider :virtualbox do |vb|
			vb.customize ["modifyvm"     , :id, "--memory" , "4096"]
			vb.customize ["modifyvm"     , :id, "--name"   , "node2"]
			#vb.customize ["modifyvm"     , :id, "--natnet1", "10.0.3/24"]

			# Call the function in disk_manager.rb to provision disks for ASM
			#create_asm_disks(config, vb) if ARGV[0] == "up"
			create_asm_disks(config, vb, "oradb12-rac", false)

		end


		oradb.vm.network :forwarded_port, guest: 22, host: 2200, auto_correct: true
		oradb.vm.network :forwarded_port, guest: 1521, host: 1522

		oradb.vm.provision :shell, :inline => "cp /vagrant/scripts/id_rsa* /home/vagrant/.ssh"
		oradb.vm.provision :shell, :inline => "chown vagrant:vagrant /home/vagrant/.ssh/id_rsa*"
		oradb.vm.provision :shell, :inline => "cat /home/vagrant/.ssh/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys"
		oradb.vm.provision :shell, :inline => "chmod 600 /home/vagrant/.ssh/id_rsa*"
	end

end

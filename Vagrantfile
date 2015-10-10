# -*- mode: ruby -*-
# vi: set ft=ruby :

# Disk size in GB
ASM_DISKS=5
ASM_DISK_SIZE=10
ASM_DISK_PATH="/home/brian/disks"

OCR_DISKS=3
OCR_DISK_SIZE=3
OCR_DISK_PATH="/home/brian/disks"
diskport=1

HOSTNAME="ora12.thewoodruffs.org"

PUBLIC_INTERFACE="enp4s0f0"

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

	config.vm.define "oradb" , primary: true do |oradb|
    		oradb.vm.box = "ilspleno/centos-6-7-puppet-oracle-base"
#    		oradb.vm.box = "ubuntu/trusty64"
#		oradb.vm.box = "my_centos_6_7"

    		oradb.vm.hostname = HOSTNAME
    		oradb.vm.network :public_network, bridge: PUBLIC_INTERFACE

    		oradb.vm.synced_folder ".", "/vagrant", :mount_options => ["dmode=777","fmode=777"]
    		oradb.vm.synced_folder "/vagrant/Software", "/software", :mount_options => ["dmode=755","fmode=755"]

    		oradb.vm.provider :virtualbox do |vb|
      			vb.customize ["modifyvm"     , :id, "--memory" , "8192"]
      			vb.customize ["modifyvm"     , :id, "--name"   , "ora12"]
			vb.customize ["modifyvm"     , :id, "--natnet1", "10.0.3/24"]
    		end

    		# Create OCRVOTE disks
    		(1..OCR_DISKS).each do |n|
    			config.vm.provider "virtualbox" do |vb|
				disk = OCR_DISK_PATH + "/ocrdisk_#{HOSTNAME}_#{n}"
        			unless File.exist?(disk)
					puts "Creating disk #{disk}"
            				vb.customize ['createhd', '--filename', disk, '--size', OCR_DISK_SIZE * 1024]
        				vb.customize ['storageattach', :id,  '--storagectl', 'SATA Controller', '--device', 0, '--port', diskport, '--type', 'hdd', '--medium', disk]
					diskport += 1
        			end
    			end
		end

    		# Create ASM disks
    		(1..ASM_DISKS).each do |n|
    			config.vm.provider "virtualbox" do |vb|
				disk = ASM_DISK_PATH + "/asmdisk_#{HOSTNAME}_#{n}"
        			unless File.exist?(disk)
					puts "Creating disk #{disk}"
            				vb.customize ['createhd', '--filename', disk, '--size', ASM_DISK_SIZE * 1024]
        				vb.customize ['storageattach', :id,  '--storagectl', 'SATA Controller', '--device', 0, '--port', diskport, '--type', 'hdd', '--medium', disk]
					diskport += 1
        			end
    			end
		end

		oradb.vm.provision :shell, :inline => "ln -sf /vagrant/puppet/hiera.yaml /etc/puppetlabs/code/hiera.yaml"
		oradb.vm.provision :shell, :inline => "ln -sf /vagrant/puppet/hiera.yaml /etc/hiera.yaml"
#		oradb.vm.provision :shell, :inline => "/opt/puppetlabs/bin/puppet apply --modulepath=/vagrant/puppet/modules --hiera_config=/vagrant/puppet/hiera.yaml /vagrant/puppet/manifests/oradb.pp"

    oradb.vm.provision :puppet do |puppet|
#      puppet.manifests_path    = "puppet/manifests"
#      puppet.module_path       = "puppet/modules"
      puppet.manifest_file     = "oradb.pp"
      puppet.options           = "--verbose --hiera_config /vagrant/puppet/hiera.yaml"

      puppet.facter = {
        "environment" => "development",
        "vm_type"     => "vagrant",
      }


    end
		# NEW - invoke script which  partitions the new disk (/dev/sdb) 
		# and create mount directives in /etc/fstab
    		#config.vm.provision :shell, path: "bootstrap.sh"  
    		#config.vm.provision "shell" do |shell|
		#    shell.inline = "sudo /vagrant/bootstrap.sh"  
		#end

		# vagrant default for SSH forwarding to host starts at port 2222.
		# When collisions are detected it resolves it using "auto_correct" starting at default port 2200 (and incrementing by 1)
		# Here's how to explicitly override those settings:
		oradb.vm.network :forwarded_port, guest: 22, host: 2222, id: "ssh", disabled: true
		oradb.vm.network :forwarded_port, guest: 22, host: 2200, auto_correct: true
		# See: http://vstone.eu/my-improved-vagrantfile/
		# Another useful resource: https://github.com/ashayh/vagrant-multi
		oradb.vm.network :forwarded_port, guest: 1521, host: 1521


	end

#	config.trigger.after :destroy do 
#		run "cleanup_disks.sh"
#		run "echo IM FINISHED NOW!"
#	end

end

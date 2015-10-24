# vi: set ft=ruby :
#
# Called by Vagrantfile, not a standalone script

def create_asm_disks(config, vb)

	diskport = 1
	diskpath=`VBoxManage list systemproperties | grep "Default machine folder" | awk ' { print $4; } '`.chomp

	# Create OCRVOTE disks
	(1..OCR_DISKS).each do |n|
		disk = diskpath + "/ocrdisk_#{HOSTNAME}_#{n}"
	        unless File.exist? disk	
			vb.customize ['createhd', '--filename', disk, '--size', OCR_DISK_SIZE * 1024]
			vb.customize ['storageattach', :id,  '--storagectl', 'SATA Controller', '--device', 0, '--port', diskport, '--type', 'hdd', '--medium', disk]
			diskport += 1
		end
	end

	# Create ASM disks
	(1..ASM_DISKS).each do |n|
		disk = diskpath + "/asmdisk_#{HOSTNAME}_#{n}"
		unless File.exist? disk
			vb.customize ['createhd', '--filename', disk, '--size', ASM_DISK_SIZE * 1024]
			vb.customize ['storageattach', :id,  '--storagectl', 'SATA Controller', '--device', 0, '--port', diskport, '--type', 'hdd', '--medium', disk]
			diskport += 1
		end
	end


end

#!/bin/bash
version="4.9"

InputArg=$1
if [ -z "$InputArg" ] #if no args passed, display menu
then
	echo "hbh7's Linux Automation Script (LAS) Version $version"
	echo "Please pick an option:"
	echo ""
	echo "Group Options:"
	echo "1.1 - Initial VM Setup Tasks"
	echo "1.2 - Disk Cleanup"
	echo "1.3 - Update Script, System, and Software"
	echo ""
	echo "Individual Options:"
	echo "2.0  - Print Version"
	echo "2.1  - Apt Cleanup"
	echo "2.2  - Apt Full Upgrade"
	echo "2.3  - Set do-release-upgrade to normal"
	echo "2.4  - Zero free space"
	echo "2.5  - Install Tools" # and do vnstat config fix
	echo "2.6  - Set up Autologin"
	echo "2.7  - Update script"
	echo "2.8  - Update script and install in /usr/bin"
	echo "2.9  - Install/Update Docker and Compose"
	echo "2.10 - Install Telegraf and configure to connect to Grafana"
	echo "2.11 - Set up SSH keys"
	echo "2.12 - New sudo password"
	echo "2.13 - Passwordless sudo"
	echo "2.14 - Sudo Insults"
	echo "2.15 - Install QEMU Guest Agent" sudo apt-get install qemu-guest-agent
	echo "2.16 - Add bash aliases"
	echo "2.17 - Remove /boot partition"
	echo "2.18 - Set timezone"
	echo "2.19 - Set up APT Cache server"
	echo "2.20 - Disable unattended upgrades"
	echo "2.21 - Set Swappiness to 1"
	echo "2.22 - Prefer IPV4"
	echo "2.23 - Clean up boot process"

	read input_variable
else
      input_variable=$InputArg
fi

#echo $input_variable
input_variable=${input_variable/./-}
#echo $input_variable

# Functions that actually do the options
function f_1_1 { # Initial VM Setup Tasks
	# add groups such as new install autologin, install tools, 
	# guest agent, update, clean
	#f_2_10 # 2.10 - Install Telegraf and configure to connect to Grafana
        f_2_19 # Set up APT Cache server
	f_1_3  # Update Script, System, and Software
	f_2_5  # Install Tools (and fix vnstat config)
	f_2_6  # Set up autologin
	f_2_11 # Set up SSH keys
	f_2_14 # Sudo Insults
	f_2_15 # Install QEMU Guest Agent"
	f_2_16 # Add bash aliases
	f_1_2  # Disk Cleanup and Setting Optomization
	f_2_18 # Set timezone
	f_2_13 # Passwordless sudo
	f_2_20 # Disable unattended upgrades
	f_2_21
	f_2_22
}

function f_1_2 { # Disk Cleanup and Setting Optomization
	f_2_1
	sudo journalctl --vacuum-time=5d
	sudo journalctl --vacuum-size=128M
	sudo fstrim -av
}

function f_1_3 { # 1.3 - Update Script, System, and Software
	f_2_7
	f_2_2
	f_1_2
}

function f_2_0 { # 2.0 - Print Version
	echo "LAS Version $version"
}

function f_2_1 { # 2.1 - Apt Cleanup
	sudo apt-get autoremove -y
	sudo apt-get clean -y
}

function f_2_2 { # 2.2 - Apt Full Upgrade
	sudo apt-get update
	sudo apt-get upgrade -y
	sudo apt-get dist-upgrade -y
	#sudo do-release-upgrade 
	#sudo do-release-upgrade -d
}

function f_2_3 { # 2.3 - Set do-release-upgrade to normal
	sudo sed -i 's/Prompt=lts/Prompt=normal/g' /etc/update-manager/release-upgrades
}

function f_2_4 { # 2.4 - Zero free space
	sudo dd if=/dev/zero of=/zero.img status=progress
	sudo rm -f /zero.img
}

function f_2_5 { # 2.5 - Install Tools (and fix vnstat config)
	sudo apt-get update && sudo apt-get install cifs-utils htop iotop vnstat tmux ncdu dfc rsync unzip zip openssh-server make git vim curl jq cowsay fortune sl cmatrix wget net-tools traceroute -y
	sudo sed -i 's/eth0/ens18/g' /etc/vnstat.conf
}

function f_2_6 { # 2.6 - Set up Autologin
	if [ -f /etc/systemd/system/getty@tty1.service.d/override.conf ]; then
		    echo "Task already appears complete. Nothing to do."
		    return
	fi
	sudo mkdir -p /etc/systemd/system/getty@tty1.service.d/
	sudo touch /etc/systemd/system/getty@tty1.service.d/override.conf
	echo "[Service]" | sudo tee --append /etc/systemd/system/getty@tty1.service.d/override.conf
	echo "ExecStart=" | sudo tee --append /etc/systemd/system/getty@tty1.service.d/override.conf
	echo "ExecStart=-/sbin/agetty -a hbh7 --noclear %I $TERM" | sudo tee --append /etc/systemd/system/getty@tty1.service.d/override.conf
	sudo systemctl daemon-reload
}

function f_2_7 { # 2.7 - Update script
	wget -O las hbh7.com/dl/las
	#mv las.1 las
	#chmod +x las
	echo "Please rerun script to use the new version." 
}

function f_2_8 { # 2.8 - Update script and install in /usr/bin
	wget hbh7.com/dl/las
	mv las.1 las
	sudo chmod +x las
	sudo cp las /usr/bin/
	echo "Please rerun script to use the new version."
}

function f_2_9 { # 2.9 - Install/Update Docker and Compose
	sudo apt-get remove docker docker-engine docker.io
	sudo apt-get update
	sudo apt-get install apt-transport-https ca-certificates curl software-properties-common -y
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
	sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
	sudo apt-get update
	sudo apt-get install docker-ce -y
	sudo docker run hello-world
	curl -L https://github.com/docker/compose/releases/download/1.24.0/docker-compose-`uname -s`-`uname -m` | sudo tee -a /usr/local/bin/docker-compose > /dev/null 
	sudo chmod +x /usr/local/bin/docker-compose
	sudo docker-compose --version
}

function f_2_10 { # 2.10 - Install Telegraf and configure to connect to Grafana
	if [ -f /etc/telegraf/telegraf.conf ]; then
		    echo "Task already appears complete. Nothing to do."
		    return
	fi
	
	curl -sL https://repos.influxdata.com/influxdb.key | sudo apt-key add -
	source /etc/lsb-release
	echo "deb https://repos.influxdata.com/${DISTRIB_ID,,} ${DISTRIB_CODENAME} stable" | sudo tee /etc/apt/sources.list.d/influxdb.list
	sudo apt-get update
	sudo apt-get install telegraf
	sudo scp hbh7@10.20.31.124:/etc/telegraf/telegraf.conf /etc/telegraf/telegraf.conf
	sudo systemctl enable telegraf
	sudo systemctl restart telegraf
}

function f_2_11 { # 2.11 - Set up SSH keys
        if grep -q ICG09r7lDNSKXWnE1Zrm44 ~/.ssh/authorized_keys; then
		echo "Task already appears complete. Nothing to do."
		return	
	fi
	mkdir ~/.ssh
	touch ~/.ssh/authorized_keys
	echo "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAhvIPTbLq6aPGhH7gjTVzWAiQsoM8M1xdbOFZ2ypA/WgqEIEcJXGWCNJzaVcHPO/AJL1qFwNNksRDtjG4HzjGLQzfENABq1GareTQkKt85ss72WvSjYa3asxAWoUY/D/Hm71//L0KlFTUSMKJR3iGcTE33LU/VClnDsIIhbdgHp+zICG09r7lDNSKXWnE1Zrm44BZ/IjmXFXeyrNuaXLWE3+B7UhZwD9vIjqBBgnsnwisi67oE+2MMO3bh4YcViWsB10QqtbrDsCJU/0+4gTiP45GdWIELC6u6tdJSZ7oYVrRztxhYjoqVLL/w7aCLJcjlFaEHB1bI1zjKBjzrBYqow==" >> ~/.ssh/authorized_keys
	echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQClWI/qyEuM3XjAyTakACpj/Q/VMGfssoHGGbVMhNNzvBzmkChwtNyxbADtu1oW+t3jE+MA5oM8C/gnhgtAYN/zAln9jP/A3AWBfsDb3TowdhAInM0g5b53vh+orwDqh7atUJtzd/PPL0TEUPRKvHpRscLxuNM/kINlKEn9eFuVzmRC2UEnep3sYNFNPZeiodjmU75mtzxUyhPapp/8qm8moxQ0BTX8ymuFH1zt7FNBT8GgB1lcsydVFuZi0jE0r/ujcPRxnRfLQUHT16IMto1N9gjJRAdlr31IRH2sR8Zy7+lt3LVVJtwqJDBwJAYj3lQtoIKDo97Qu+PNlihYBE6/ hbh7@vm-mussh" >> ~/.ssh/authorized_keys
}

function f_2_12 { # 2.12 - New sudo password
	sudo passwd
}

function f_2_13 { # 2.13 - Passwordless sudo
	#echo "DANGER! WIP! Consider Control+C. 5s timer started."
	#sleep 5
	#echo '/#includedir \/etc\/sudoers.d /i\' >> changes.sed
	#echo 'hbh7 ALL=(ALL) NOPASSWD: ALL' >> changes.sed
	#sed -f changes.sed < sudoers | more
	echo "hbh7	ALL = (ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers
}

function f_2_14 { # 2.14 - Sudo Insults
        if sudo grep -q insults /etc/sudoers; then
		echo "Task already appears complete. Nothing to do."
		return
	fi

	echo "Defaults 	insults" | sudo tee -a /etc/sudoers
}

function f_2_15 { # 2.15 - Install QEMU Guest Agent"
	sudo apt-get update
	sudo apt-get install qemu-guest-agent
}

function f_2_16 { # 2.16 - Add bash aliases
        if grep -q dfc ~/.bashrc; then
		echo "Task already appears complete. Nothing to do."
		return	
	fi
	
	echo "alias dfc=\"dfc -d\"" | tee -a ~/.bashrc
	echo "Please run \"source ~/.bashrc\" to reload, or log in again"
}

function f_2_17 { # 2.16 - Remove /boot partition
	sudo cp -av /boot /boot-tmp
	sudo umount /boot
	sudo rmdir /boot
	sudo mv /boot-tmp /boot
	echo "Comment out or remove line for /boot in /etc/fstab."
	echo "Continuing in 5s"
	sleep 5
	sudo nano /etc/fstab
	sudo update-grub
}

function f_2_18 { # 2.18 - Set timezone
	 sudo cp /usr/share/zoneinfo/America/New_York /etc/localtime
}

function f_2_19 { # 2.19 - Set up APT Cache server
	echo "Acquire::http::Proxy \"http://10.20.31.117:3142\";" | sudo tee /etc/apt/apt.conf.d/00proxy
}

function f_2_20 { # 2.20 - Disable unattended upgrades
	sudo apt remove unattended-upgrades -y
}

function f_2_21 { # 2.21 - Set swappiness to 1
	cat /proc/sys/vm/swappiness
	echo "vm.swappiness = 10" | sudo tee -a /etc/sysctl.conf
	sudo sysctl vm.swappiness=10
	cat /proc/sys/vm/swappiness
}

function f_2_22 { # 2.22 - Prefer IPV4
	sudo sed -i 's/#precedence ::ffff:0:0\/96  100/precedence ::ffff:0:0\/96  100/g' /etc/gai.conf
}

function f_2_23 { # 2.23 - Clean up boot process
	sudo apt-get purge btrfs-tools btrfs-progs -y
	sudo apt-get purge cryptsetup-initramfs -y
	sudo apt-get purge mdadm -y
	sudo apt autoremove -y
	sudo update-initramfs -ukall
	sudo update-grub
}



# Handle input, calling appropriate functions 
if [ "$input_variable" == "1-1" ]; then
	echo "1.1 - Initial VM Setup Tasks"
	f_1_1	

elif [ "$input_variable" == "1-2" ]; then
	echo "1.2 - Disk Cleanup"
	f_1_2

elif [ "$input_variable" == "1-3" ]; then
	echo "1.3 - Update Script, System, and Software"
	f_1_3

elif [ "$input_variable" == "2-0" ]; then
	#echo "2.0 - LAS Version"
	f_2_0
	
elif [ "$input_variable" == "2-1" ]; then
	echo "2.1  - Apt Cleanup"
	f_2_1
	
elif [ "$input_variable" == "2-2" ]; then
	echo "2.2  - Apt Full Upgrade"
	f_2_2

elif [ "$input_variable" == "2-3" ]; then
	echo "2.3  - Set do-release-upgrade to normal"
	f_2_3	

elif [ "$input_variable" == "2-4" ]; then
	echo "2.4  - Zero free space"
	f_2_4	

elif [ "$input_variable" == "2-5" ]; then
        echo "2.5  - Install Tools" # and do vnstat config fix
	f_2_5

elif [ "$input_variable" == "2-6" ]; then
	echo "2.6  - Set up Autologin"
	f_2_6
	
elif [ "$input_variable" == "2-7" ]; then
	echo "2.7  - Update script"
	f_2_7

elif [ "$input_variable" == "2-8" ]; then
	echo "2.8  - Update script and install in /usr/bin"
	f_2_8
	
elif [ "$input_variable" == "2-9" ]; then
	echo "2.9  - Install/Update Docker and Compose"
	f_2_9
	
elif [ "$input_variable" == "2-10" ]; then
	echo "2.10 - Install Telegraf and configure to connect to Grafana"
	f_2_10
	
elif [ "$input_variable" == "2-11" ]; then
	echo "2.11 - Set up SSH keys"
	f_2_11
	
elif [ "$input_variable" == "2-12" ]; then
	echo "2.12 - New sudo password"
	f_2_12

elif [ "$input_variable" == "2-13" ]; then
	echo "2.13 - Passwordless sudo"
	f_2_13
		
elif [ "$input_variable" == "2-14" ]; then
	echo "2.14 - Sudo Insults"
	f_2_14
	
elif [ "$input_variable" == "2-15" ]; then
	 echo "2.15 - Install QEMU Guest Agent" 
	 f_2_15
	
elif [ "$input_variable" == "2-16" ]; then
	echo "2.16 - Add bash aliases"
	f_2_16
	
elif [ "$input_variable" == "2-17" ]; then
	echo "2.17 - Remove /boot partition"
	f_2_17

elif [ "$input_variable" == "2-18" ]; then
        echo "2.18 - Set timezone"
        f_2_18

elif [ "$input_variable" == "2-19" ]; then
        echo "2.19 - Set up APT Cache server"
        f_2_19

elif [ "$input_variable" == "2-20" ]; then
        echo "2.20 - Disable Unattended Upgrades"
        f_2_20

elif [ "$input_variable" == "2-21" ]; then
        echo "2.21 - Set swappiness to 1"
        f_2_21

elif [ "$input_variable" == "2-22" ]; then
        echo "2.22 - Prefer IPV4"
        f_2_22

elif [ "$input_variable" == "2-23" ]; then
        echo "2.23 - Clean up boot process"
        f_2_23

else
	echo "Invalid Option"

fi

echo "Done!"

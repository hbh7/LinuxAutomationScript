# LinuxAutomationScript
My ./las for lots of common VM tasks. Built for Ubuntu 20.04 but will probably work on many other systems too (I commonly use it with Proxmox and Raspbian as well). 


## Installation
```
wget -O las las.hbh7.com
```
or
```
wget --content-disposition las.hbh7.com
```
then 
```
chmod +x ./las 
./las
```

## Running after installation
`./las (option if desired)`

## Modifications
* This script is based around my needs, so there are some options almost entirely specific to me. For example, one option is for adding my public key for SSH authentication, so you may find yourself giving me access to your machine if you run that command. Therefore, like with any script, you should read it and be aware of what it will do before running it. 
* The autologin portion is also coded to me, so you may find yourself in a slight pickle if you run that unmodified. Use Control+Alt+F(something) to switch to another terminal, and log in and correct the systemd override file that specifies my account name to log into.
* Otherwise, feel free to download/fork and modify to your setup!

## Features/Bugs
Feel free to open an issue for any desired features or bugs you find in the code. 

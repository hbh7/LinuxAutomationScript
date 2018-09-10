# LinuxAutomationScript
My ./las for lots of common VM tasks. Built for Ubuntu 18.04 but probably will work on many other systems too. 


## Installation
```
wget hbh7.com/dl/las
chmod +x ./las 
./las
```

## Running after installation
`./las (option if desired)`

## Modifications
* This script includes some options specific to me, such as my public key for SSH authentication. You may find yourself giving me access to your machine if you run some commands :P 
* The autologin portion is also coded to me, so you may find yourself in a slight pickle if you run that unmodified. Use Control+Alt+F(something) to switch to another terminal, and log in and correct the systemd override file specifying my account name to log into

## Features/Bugs
Feel free to open an issue for any desired features or bugs you find in the code. 

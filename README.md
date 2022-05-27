# SoftetherVPN-without-SecureNAT
Script to build SoftetherVPN server without SecureNAT.

# What you get
direct bridging without secure nets allows for server2client connections.

# HOW TO USE 
> When using v4
  1. **Download the two files and runs**<br>
  ```bash
  cd ~ &&\
  wget https://raw.githubusercontent.com/kuwacom/SoftetherVPN-without-SecureNAT/main/installer-v4-first.sh &&\
  wget https://raw.githubusercontent.com/kuwacom/SoftetherVPN-without-SecureNAT/main/installer-v4-second.sh
  ```
  Run the first script, "installer-v4-first.sh"
  ```bash
  bash installer-v4-first.sh
  ```
  2. **VPN Server Settings**<br>
  ![image](https://user-images.githubusercontent.com/83022348/170528332-52ce9585-2a61-4424-9b29-80931ce1038b.png)<br>
  **If you have come this far and cannot get into VPNcmd, please type the this command**
  ```bash
  /usr/local/vpnserver/vpncmd /server localhost
  ```
  *Please execute the commands as written in the instructions*<br>
  ```
  ===== Please enter the following code to vpncmd =====
  ServerPasswordSet <Your admin password>
  HubDelete DEFAULT
  HubCreate vpn-hub /PASSWORD:<hub password>
  BridgeCreate vpn-hub /DEVICE:vpn /TAP:yes
  Hub vpn-hub
  GroupCreate Admin /REALNAME:none /NOTE:none
  UserCreate <user name> /GROUP:Admin /NOTE:none /REALNAME:none
  UserPasswordSet <user name> /password:<user password>
  exit
  ```
  3. **"installer-v4-second.sh"**<br>
  The second script, "installer-v4-second.sh" is also executed.<br>
  **When all is done, the system will be rebooted*<br>

> use prototype
after building, connect with the Server Administration Manager and create a tap with the bridge name "vpn".
![image](https://user-images.githubusercontent.com/83022348/170460804-25d9f3c9-b711-493f-8391-a2a8aa4a305d.png)

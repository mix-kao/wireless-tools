# wireless-tools
---
Create wireless virtual interfaces from iw command and managed by WPA_Supplicant.
I run the script on Ubuntu 16.04 desktop by "BASH"


[My WiFi adapter information]

sudo lshw -C network

*-network
       description: Wireless interface
       product: AR9485 Wireless Network Adapter
       vendor: Qualcomm Atheros
       physical id: 0
       bus info: pci@0000:03:00.0
       logical name: wlp3s0
       version: 01
       width: 64 bits
       clock: 33MHz
       capabilities: pm msi pciexpress bus_master cap_list rom ethernet physical wireless
       configuration: broadcast=yes driver=ath9k driverversion=4.4.0-53-generic firmware=N/A latency=0 link=no multicast=yes wireless=IEEE 802.11bgn


[Special config for my WiFi adapter]

cat /etc/modprobe.d/ath9k.conf 
options ath9k nohwcrypt=1

Note: if I load the ath9k driver without nohwcrypt=1, some of the virtual wireless interface will not work properly.
For example, I can not get the ARP reply from some virtual interfaces that I created.

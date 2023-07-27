# lps8n configuration

### default http port forwarding
- http port forwarding = 8000 (username=admin, password=dragino)

### turn off wifi
- Network => WiFi => Enable WiFi Access Point = unchecked
- Network => WiFi => Enable WiFi WAN Client = unchecked

### delete abp device
- LoRa => ABP Decryption
	- Delete Key => Select Dev ADDR
    - click button "DELETE"

### enable abp decryption
- LoRa => ABP Decryption
	- check => Enable ABP Decryption
    - click button "SAVE"

### add device abp device
- LoRa => ABP Decryption
	- Dev ADDR = last 4-byte of mac address
	- APP Session Key = 16-byte key
	- Network Session Key = 16-byte key
	- Decoder = ASCII String
	- click ADD_KEY

### config lora mqtt mode
- MQTT => MQTT Client
	- Broker Adderss [-h] = 127.0.0.1
	- Broker Port [-p] = 11883
	- click button "Save & Apply"

### default ssh port forwarding
- ssh port forwarding = 2222 (username=root, password=dragino)

### ssh to lps8n
ssh -p 2222 -o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedKeyTypes=+ssh-rsa root@<lps8n_wan_ip>

### run kbnet installation script
wget --no-proxy --no-check-certificate -O - https://github.com/kidbright/lps8n/raw/main/kbnet_install_lps8n.sh | sh

### reboot lps8n
reboot

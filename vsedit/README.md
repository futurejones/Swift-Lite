# vsedit

## Description

`vsedit` enables live file editing on a remote device using VSCode.

### Setup VSCode for remote editing

`vsedit` needs to be copied to the device that you want to remote edit files on.
After that, you need to setup VSCode to communicate with `vsedit`.

### Install `vsedit` on remote device
#### From Source
```bash
wget https://github.com/futurejones/vs-remote-edit/raw/master/vsedit
chmod a+x vsedit
sudo mv vsedit /usr/bin
```

#### With `apt-get install`

```bash
# install swift-lite repo
curl -s https://packagecloud.io/install/repositories/swift-arm/swift-lite/script.deb.sh | sudo bash
# install vsedit
sudo apt-get install vsedit
```

### Set-up VSCode
* Open VSCode extension mamanger and add `Remote VSCode`.  
* Restart VSCode.
* Open VSCode `Settings`.
* Open `Remote VSCode configuration`.
* Turn on `Launch the server on start up`.
* Change the `Port number to use for connection` to `55555`.
* Restart VSCode.

#### Connect to device

In VSCode open a terminal and use the following command to connect to your device.
```bash
ssh -R 55555:localhost:55555 user@example.com
```

Once you are logged into the remote device, you can now just execute
```bash
vsedit test.txt
```
and your file will be opened in VSCode ready for editing.  
  

*NOTE: If the file doesn't exist, a new blank file will be created and opened.*
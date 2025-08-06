# kiosk_camera_relay_system
lets you take axis camera feed and display them to web browser kiosks

# Setup
- Install [[go2rtc](https://github.com/AlexxIT/go2rtc)]
- Setup your axis cameras with a user that has media rights.  Use those logins an update the go2rtc.yaml file with the login and ips.
- Update Start_Cameras_Broker.ps1 with the proper location of the program.  
- Update/create the camera set scripts with the cameras you want to connect to and the column and rows they should be displayed in.

# Running
- Run Start_Cameras_Broker.ps1
- Start the camera_sets you want to be available.
- Run thru the Debian 12 or windows examples if you want some possible howtos for the kiosks.

# Debian 12.7 quick howto
- in gnome search for users -> turn on "auto login"
- adjust power to turn off suspend, and screen off
- install chrome
-- curl -fSsL https://dl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor | sudo tee /usr/share/keyrings/google-chrome.gpg >> /dev/null
-- echo deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main | sudo tee /etc/apt/sources.list.d/google-chrome.list
-- sudo apt update
-- sudo apt install google-chrome-stable -y
- Disable gnome sleep
-- gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
- Setup kiosk start
-- sudo nano /usr/local/bin/browser-kiosk.sh
#!/bin/bash
export XDG_SESSION_TYPE=x11
export XDG_RUNTIME_DIR=/run/user/$(id -u)
export DISPLAY=:0
google-chrome-stable --kiosk https://192.168.0.10:8081 --ozone-platform-hint=auto --ignore-certificate-errors
-- sudo nano /etc/systemd/system/browser-kiosk.service
[Unit]
Description=Browser Kiosk
After=graphical.target

[Service]
User=biztech
ExecStart=/usr/local/bin/browser-kiosk.sh >> /var/log/browser-kiosk.log 2>&1
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=graphical.target

- enable and cmhmod
-- sudo chmod +x /usr/local/bin/browser-kiosk.sh
-- sudo systemctl enable browser-kiosk

- Fix activities-menu startup
-- Disable wayland
sudo vim /etc/gdm3/daemon.conf
uncomment the WalyandEnable=false line

# A windows kiosk


    Add a guest user to Windows
    Make a C:\Scripts folder.
    Edit a new batch file and put this line in (assuming google chrome)
        “c:\Program Files\Google\Chrome\Application\chrome.exe” –kiosk http:\\strombeckprop.com
        Save it as kiosk.bat
    Start task manager
        Create task
        Give it a name
        Change “when running the task, use the following user account:” to the guest account.
        Goto triggers tab
            Select “at log on”
            Specific user (the guest user)
        Goto actions
            New
            Select “Start a program”

    Browse to the script

<!-- Purpose: Minmized version of the camera kiosk html pages -->
<!-- INSTALL_COMMAND: you need to configure and then run each script you want and the broker. -->
<!-- RUN_COMMAND: see install -->

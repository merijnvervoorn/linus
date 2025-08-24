#! /bin/bash

# Colours
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
RESET='\033[0m'

log_start() {
    echo -e "${CYAN}····················································${RESET}"
}

log_end() {
    echo -e "${CYAN}····················································${RESET}"
    echo
    echo
    echo
    echo
    echo
    tput cup $(stty size|awk '{print int($1-5);}') 0 && tput ed
}

uninstall() {
    log_start
    echo -e "${YELLOW}Uninstalling unnecessary packages...${RESET}"
    
    sudo rm /usr/share/applications/thunderbird.desktop
    sudo rm /usr/share/applications/org.gnome.Totem.desktop
    sudo rm /usr/share/applications/org.gnome.Shotwell-Viewer.desktop
    sudo rm /usr/share/applications/org.gnome.Shotwell.desktop
    sudo rm /usr/share/applications/org.gnome.Shotwell.Auth.desktop
    sudo rm /usr/share/applications/org.gnome.seahorse.Application.desktop
    sudo rm /usr/share/applications/org.gnome.Evolution-alarm-notify.desktop
    sudo rm /usr/share/applications/org.gnome.evolution-data-server.OAuth2-handler.desktop
    sudo rm /usr/share/applications/org.gnome.clocks.desktop
    sudo rm /usr/share/applications/org.gnome.Calendar.desktop
    
    sudo apt autoremove --purge
    
    echo -e "${GREEN}Done installing essentials!${RESET}"
    log_end
}

install_essentials() {
    log_start
    echo -e "${YELLOW}Installing essentials...${RESET}"
    
    # Installing command-line utilities
    sudo apt install curl wget neofetch samba ssh
    
    # Update
    sudo apt update && sudo apt upgrade -y
    
    # Apt
    sudo apt install -y audacity calibre flatpak flathub gimp git gnome-tweaks gnome-shell-extensions kdenlive libreoffice onedrive python3 python3-pip vlc 
    
    # Removing the office applications I don't need
    sudo rm /usr/share/applications/libreoffice-draw.desktop
    sudo rm /usr/share/applications/libreoffice-base.desktop
    sudo rm /usr/share/applications/libreoffice-math.desktop
    
    # Flatpak
    sudo flatpak install flathub app.zen_browser.zen
    sudo flatpak install flathub com.discordapp.Discord
    sudo flatpak install flathub com.spotify.Client
    
    #Internet
    sudo add-apt-repository -y ppa:obsproject/obs-studio
    sudo apt install -y ffmpeg obs-studio
    
    wget -q --content-disposition -O code_latest.deb "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
    sudo apt install -y ./code_latest.deb
    rm -f code_latest.deb
    echo -e "${GREEN}Done installing essentials!${RESET}"
    log_end
}

install_extras() {
    log_start
    echo -e "${YELLOW}Installing extras...${RESET}"
    
    # Apt
    sudo apt install -y steam virtualbox 
    
    #Tailscale and EduVPN
    curl -fsSL https://tailscale.com/install.sh | sh
    curl --proto '=https' --tlsv1.2 https://docs.eduvpn.org/client/linux/install.sh -O
    bash ./install.sh
    
    # Iriun
    DOWNLOAD_URL=$(curl -s https://iriun.gitlab.io/ | grep -oP 'iriunwebcam-\d+\.\d+\.\d+\.deb' | head -n 1)

    if [ -z "$DOWNLOAD_URL" ]; then
        echo "Error: Unable to find the latest .deb link!"
        exit 1
    fi
    DEB_URL="https://iriun.gitlab.io/$DOWNLOAD_URL"
    
    echo "Downloading the latest Iriun Webcam package from $DEB_URL..."
    wget -O iriunwebcam.deb $DEB_URL
    
    echo "Installing Iriun Webcam..."
    sudo dpkg -i iriunwebcam.deb
    
    sudo apt-get install -f
    
    rm iriunwebcam.deb
    
    # Lutris
    GITHUB_RELEASES_URL="https://github.com/lutris/lutris/releases"
    
    LATEST_RELEASE=$(curl -s $GITHUB_RELEASES_URL | grep -oP 'lutris_\d+\.\d+\.\d+_all\.deb' | head -n 1)

    if [ -z "$LATEST_RELEASE" ]; then
        echo "Error: Unable to find the latest .deb link!"
        exit 1
    fi
    
    DEB_URL="https://github.com/lutris/lutris/releases/download/v0.5.18/$LATEST_RELEASE"
    
    wget -O lutris.deb $DEB_URL
    
    sudo dpkg -i lutris.deb
    
    sudo apt-get install -f
    
    rm lutris.deb
    
    # Docker
    sudo apt-get update
	sudo apt-get install ca-certificates curl
	sudo install -m 0755 -d /etc/apt/keyrings
	sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
	sudo chmod a+r /etc/apt/keyrings/docker.asc

	# Add the repository to Apt sources:
	echo \
	  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
	  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
	  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
	sudo apt-get update
	
	sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
	
	wget -O docker-desktop-amd64.deb https://desktop.docker.com/linux/main/amd64/docker-desktop-amd64.deb
	sudo apt install ~/Downloads/docker-desktop-amd64.deb
        
    echo -e "${GREEN}Done installing extras!${RESET}"
    log_end
}

firefox() {
    log_start
    echo -e "${YELLOW}Installing Firefox...${RESET}"
    sudo apt install firefox
    echo -e "${GREEN}Firefox installed!${RESET}"
    log_end
}

brave() {
    log_start
    echo -e "${YELLOW}Installing Brave...${RESET}"
    sudo flatpak install flathub com.brave.Browser
    echo -e "${GREEN}Brave installed!${RESET}"
    log_end
}

verify_installs() {
    log_start
    echo -e "${YELLOW}Verifying installations...${RESET}"
    apt_programs=(audacity calibre firefox gimp git gnome-tweaks gnome-shell-extensions kdenlive libreoffice onedrive python3 python3-pip vlc)
    flatpak_programs=(discord spotify zen)

    for program in "${apt_programs[@]}"; do
        if ! dpkg -l | grep -q "$program"; then
            echo "$program is NOT installed."
        fi
    done

    for program in "${flatpak_programs[@]}"; do
        if ! flatpak list | grep -q "$program"; then
            echo "$program is NOT installed."
        fi
    done
    echo -e "${GREEN}Done verifying!${RESET}"
    log_end
}

updater() {
    log_start
    echo -e "${YELLOW}Updating all installed applications...${RESET}"
    sudo apt update && sudo apt upgrade -y
    snap refresh
    sudo apt-get dist-upgrade -y
    echo -e "${GREEN}Everything updated!${RESET}"
    log_end
}

cleanup() {
    log_start
    echo -e "${YELLOW}Cleaning up the mess from all those installs...${RESET}"
	sudo apt autoremove -y && sudo apt autoclean -y
	echo -e "${GREEN}Fully cleaned up!${RESET}"
    log_end
}

tailscale() {
    log_start
    echo -e "${BLUE}Setting up Tailscale (You might need to login yourself)...${RESET}"
    sudo tailscale up
    echo -e "${GREEN}Tailscale running!${RESET}"
    log_end
}

git_global() {
    log_start
    echo -e "${BLUE}Setting Git username and email...${RESET}"
	git config --global user.name "merijnvervoorn"
	git config --global user.email "161606054+merijnvervoorn@users.noreply.github.com"
	git config --global credential.helper store
	echo -e "${GREEN}Git username and email set!${RESET}"
    log_end
}

dotfiles() {
    log_start
    echo -e "${BLUE}Setting up dotfiles...${RESET}"
    
    # Clone git and add symlinks
    cd ~
    git clone https://github.com/merijnvervoorn/.dotfiles
    bash /.dotfiles/symlink.sh
    
    #Setup settings
    wget -qO /tmp/savedesktop-native-installer.py https://raw.githubusercontent.com/vikdevelop/SaveDesktop/main/native/native_installer.py && python3 /tmp/savedesktop-native-installer.py --install
    ~/.local/bin/savedesktop --import-config ~/.dotfiles/savedesktop.sd.tar.gz
    wget -qO /tmp/savedesktop-native-installer.py https://raw.githubusercontent.com/vikdevelop/SaveDesktop/main/native/native_installer.py && python3 /tmp/savedesktop-native-installer.py --remove
    
    #Change boot logo
    sudo cp /usr/share/plymouth/ubuntu-logo.png{,.bak}
    sudo cp /usr/share/plymouth/themes/spinner/bgrt-fallback.png{,.bak}
    sudo cp /usr/share/plymouth/themes/spinner/watermark.png{,.bak}
    
    sudo cp ~/.dotfiles/logo/ubuntu-logo.png /usr/share/plymouth
    sudo cp ~/.dotfiles/logo/bgrt-fallback.png /usr/share/plymouth/themes/spinner
    sudo cp ~/.dotfiles/logo/watermark.png /usr/share/plymouth/themes/spinner
    
    # if OEM logo shows: https://ubuntuhandbook.org/index.php/2022/10/replace-manufacturer-ubuntu/
    # sudo convert bgrt-fallback.png -gravity center -background none -extent 1440x900 background-tile.png
    
    sudo update-initramfs -u
    sudo update-grub
    
    echo -e "${GREEN}Dotfiles in use!${RESET}"
    log_end
}



winapps() {
	mkdir ~/.config/winapps/
	cd ~/.config/winapps
	wget https://github.com/winapps-org/winapps/blob/main/compose.yaml
	# Print the message
	echo "Now you should change the username and password"

	# Wait for the user to press any key
	read -n 1 -s -r -p "Press any key to open the file..."
	
	nano compose.yaml
	# Check if the user saved the file
	if [ $? -eq 0 ]; then
		echo "File saved successfully. Continuing with the script..."
		# Add further commands here
		
		docker compose --file ./compose.yaml up
		
		    if ask "Is the windows machine set up? (Have you installed the applications you need?)"; then
			   # Add commands
			   sudo apt install -y curl dialog freerdp3-x11 git iproute2 libnotify-bin netcat-openbsd
			   touch ~/.config/winapps/winapps.conf
			   cat << EOF >> winapps.conf
			   ##################################
				#   WINAPPS CONFIGURATION FILE   #
				##################################

				# INSTRUCTIONS
				# - Leading and trailing whitespace are ignored.
				# - Empty lines are ignored.
				# - Lines starting with '#' are ignored.
				# - All characters following a '#' are ignored.

				# [WINDOWS USERNAME]
				RDP_USER="MyWindowsUser"

				# [WINDOWS PASSWORD]
				# NOTES:
				# - If using FreeRDP v3.9.0 or greater, you *have* to set a password
				RDP_PASS="MyWindowsPassword"

				# [WINDOWS DOMAIN]
				# DEFAULT VALUE: '' (BLANK)
				RDP_DOMAIN=""

				# [WINDOWS IPV4 ADDRESS]
				# NOTES:
				# - If using 'libvirt', 'RDP_IP' will be determined by WinApps at runtime if left unspecified.
				# DEFAULT VALUE:
				# - 'docker': '127.0.0.1'
				# - 'podman': '127.0.0.1'
				# - 'libvirt': '' (BLANK)
				RDP_IP="127.0.0.1"

				# [VM NAME]
				# NOTES:
				# - Only applicable when using 'libvirt'
				# - The libvirt VM name must match so that WinApps can determine VM IP, start the VM, etc.
				# DEFAULT VALUE: 'RDPWindows'
				VM_NAME="RDPWindows"

				# [WINAPPS BACKEND]
				# DEFAULT VALUE: 'docker'
				# VALID VALUES:
				# - 'docker'
				# - 'podman'
				# - 'libvirt'
				# - 'manual'
				WAFLAVOR="docker"

				# [DISPLAY SCALING FACTOR]
				# NOTES:
				# - If an unsupported value is specified, a warning will be displayed.
				# - If an unsupported value is specified, WinApps will use the closest supported value.
				# DEFAULT VALUE: '100'
				# VALID VALUES:
				# - '100'
				# - '140'
				# - '180'
				RDP_SCALE="100"

				# [MOUNTING REMOVABLE PATHS FOR FILES]
				# NOTES:
				# - By default, `udisks` (which you most likely have installed) uses /run/media for mounting removable devices.
				#   This improves compatibility with most desktop environments (DEs).
				# ATTENTION: The Filesystem Hierarchy Standard (FHS) recommends /media instead. Verify your system's configuration.
				# - To manually mount devices, you may optionally use /mnt.
				# REFERENCE: https://wiki.archlinux.org/title/Udisks#Mount_to_/media
				REMOVABLE_MEDIA="/run/media"

				# [ADDITIONAL FREERDP FLAGS & ARGUMENTS]
				# NOTES:
				# - You can try adding /network:lan to these flags in order to increase performance, however, some users have faced issues with this.
				# DEFAULT VALUE: '/cert:tofu /sound /microphone +home-drive'
				# VALID VALUES: See https://github.com/awakecoding/FreeRDP-Manuals/blob/master/User/FreeRDP-User-Manual.markdown
				RDP_FLAGS="/cert:tofu /sound /microphone +home-drive"

				# [DEBUG WINAPPS]
				# NOTES:
				# - Creates and appends to ~/.local/share/winapps/winapps.log when running WinApps.
				# DEFAULT VALUE: 'true'
				# VALID VALUES:
				# - 'true'
				# - 'false'
				DEBUG="true"

				# [AUTOMATICALLY PAUSE WINDOWS]
				# NOTES:
				# - This is currently INCOMPATIBLE with 'docker' and 'manual'.
				# - See https://github.com/dockur/windows/issues/674
				# DEFAULT VALUE: 'off'
				# VALID VALUES:
				# - 'on'
				# - 'off'
				AUTOPAUSE="off"

				# [AUTOMATICALLY PAUSE WINDOWS TIMEOUT]
				# NOTES:
				# - This setting determines the duration of inactivity to tolerate before Windows is automatically paused.
				# - This setting is ignored if 'AUTOPAUSE' is set to 'off'.
				# - The value must be specified in seconds (to the nearest 10 seconds e.g., '30', '40', '50', etc.).
				# - For RemoteApp RDP sessions, there is a mandatory 20-second delay, so the minimum value that can be specified here is '20'.
				# - Source: https://techcommunity.microsoft.com/t5/security-compliance-and-identity/terminal-services-remoteapp-8482-session-termination-logic/ba-p/246566
				# DEFAULT VALUE: '300'
				# VALID VALUES: >=20
				AUTOPAUSE_TIME="300"

				# [FREERDP COMMAND]
				# NOTES:
				# - WinApps will attempt to automatically detect the correct command to use for your system.
				# DEFAULT VALUE: '' (BLANK)
				# VALID VALUES: The command required to run FreeRDPv3 on your system (e.g., 'xfreerdp', 'xfreerdp3', etc.).
				FREERDP_COMMAND=""

				# [TIMEOUTS]
				# NOTES:
				# - These settings control various timeout durations within the WinApps setup.
				# - Increasing the timeouts is only necessary if the corresponding errors occur.
				# - Ensure you have followed all the Troubleshooting Tips in the error message first.

				# PORT CHECK
				# - The maximum time (in seconds) to wait when checking if the RDP port on Windows is open.
				# - Corresponding error: "NETWORK CONFIGURATION ERROR" (exit status 13).
				# DEFAULT VALUE: '5'
				PORT_TIMEOUT="5"

				# RDP CONNECTION TEST
				# - The maximum time (in seconds) to wait when testing the initial RDP connection to Windows.
				# - Corresponding error: "REMOTE DESKTOP PROTOCOL FAILURE" (exit status 14).
				# DEFAULT VALUE: '30'
				RDP_TIMEOUT="30"

				# APPLICATION SCAN
				# - The maximum time (in seconds) to wait for the script that scans for installed applications on Windows to complete.
				# - Corresponding error: "APPLICATION QUERY FAILURE" (exit status 15).
				# DEFAULT VALUE: '60'
				APP_SCAN_TIMEOUT="60"

				# WINDOWS BOOT
				# - The maximum time (in seconds) to wait for the Windows VM to boot if it is not running, before attempting to launch an application.
				# DEFAULT VALUE: '120'
				BOOT_TIMEOUT="120"
				EOF
				
				# Print the message
				echo "Now you should change the username and password"

				# Wait for the user to press any key
				read -n 1 -s -r -p "Press any key to open the file..."
				
			   nano winapps.conf
			   if [ $? -eq 0 ]; then
					echo "File saved successfully. Continuing with the script..."
					# Add further commands here
					
					wget ttps://raw.githubusercontent.com/winapps-org/winapps/main/setup.sh
					sudo mkdir /root/.config/winapps
					sudo ln -s ~/.config/winapps/winapps.conf /root/.config/winapps/winapps.conf
					sudo bash ~/.config/winapps/setup.sh
					
				else
					echo "File was not saved. Exiting."
					exit 1
				fi
			   
			fi
			echo
		
		
	else
		echo "File was not saved. Exiting."
		exit 1
	fi
}



ask() {
    local prompt="$1"
    local response
    while true; do
        read -p "   $prompt [Y|n] " response
        case $response in
            [Yy]*|"") return 0 ;;
            [Nn]*) return 1 ;;  
            *) echo -e "${RED}Please answer Yes (Y) or No (n).${RESET}" ;;
        esac
    done
}

main() {
    clear
    echo
    echo -e "${GREEN}   ····················································${RESET}"
    echo -e "${GREEN}      █████        ███                               ${RESET}"
    echo -e "${GREEN}     ░░███        ░░░                                ${RESET}"
    echo -e "${GREEN}      ░███        ████  ████████   █████ ████  █████ ${RESET}"
    echo -e "${GREEN}      ░███       ░░███ ░░███░░███ ░░███ ░███  ███░░  ${RESET}"
    echo -e "${GREEN}      ░███        ░███  ░███ ░███  ░███ ░███ ░░█████ ${RESET}"
    echo -e "${GREEN}      ░███      █ ░███  ░███ ░███  ░███ ░███  ░░░░███${RESET}"
    echo -e "${GREEN}      ███████████ █████ ████ █████ ░░████████ ██████ ${RESET}"
    echo -e "${GREEN}     ░░░░░░░░░░░ ░░░░░ ░░░░ ░░░░░   ░░░░░░░░ ░░░░░░  ${RESET}"
    echo -e "${GREEN}   ····················································${RESET}"
    echo -e "${GREEN}   :Linux Installation and Navigation of User Software:${RESET}"
    echo -e "${GREEN}   ····················································${RESET}"
    echo -e "${CYAN}                                               By Merijn${RESET}"
    
    echo
    
    if ask "Do you want to uninstall the unnecessary packages?"; then
        uninstall 
    fi
    echo
    if ask "Do you want to install essential applications?"; then
        install_essentials
        echo
        
        if ask "Do you also want to install extra applications?"; then
            install_extras
        fi
        echo
        if ask "How about Firefox?"; then
            firefox
        fi
        echo
        if ask "How about a third browser (Brave)?"; then
            brave
        fi
        verify_installs
    fi
    echo
    if ask "Do you want to update the applications?"; then
        updater
    fi
    echo
    if ask "Do you want to clean up the system (remove unnecessary packages)?"; then
        cleanup
    fi
    echo
    if ask "Do you want to set up tailscale?"; then
        tailscale
    fi
    echo
    if ask "Do you want to configure Git globally?"; then
        git_global
    fi
    echo
    
    echo -e "Also get a Personal Access Token: https://github.com/settings/tokens \n"
    
    if ask "Do you want to set up your dotfiles?"; then
        dotfiles
    fi
    echo    

    
    if ask "Do you want to install WinApps (for using Windows-only apps)?"; then
       winapps
    fi
    echo
    
    
    #if ask "question"; then
    #   function
    #fi
    #echo
    

    echo -e "   ${GREEN}··························································${RESET}"
    echo -e "   ${GREEN}:░█░░░▀█▀░█▀█░█░█░█▀▀░░░█▀▀░█▀█░█▄█░█▀█░█░░░█▀▀░▀█▀░█▀▀░█:${RESET}"
    echo -e "   ${GREEN}:░█░░░░█░░█░█░█░█░▀▀█░░░█░░░█░█░█░█░█▀▀░█░░░█▀▀░░█░░█▀▀░▀:${RESET}"
    echo -e "   ${GREEN}:░▀▀▀░▀▀▀░▀░▀░▀▀▀░▀▀▀░░░▀▀▀░▀▀▀░▀░▀░▀░░░▀▀▀░▀▀▀░░▀░░▀▀▀░▀:${RESET}"
    echo -e "   ${GREEN}··························································${RESET}"
    echo
    sleep 5
    neofetch
}

main

#!/bin/bash
#title           :install-omada-controller.sh
#description     :Installer for TP-Link Omada Software Controller
#supported       :Ubuntu 24.04.1 LTS
#author          :monsn0
#date            :2021-07-29
#updated         :2025-01-28

echo -e "\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "TP-Link Omada Software Controller - Installer"
echo "https://github.com/raiubreaksthings/omada-installer"
echo -e "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"

echo "[+] Verifying running as root"
if [ `id -u` -ne 0 ]; then
  echo -e "\e[1;31m[!] Script requires to be ran as root. Please rerun using sudo. \e[0m"
  exit
fi

echo "[+] Verifying supported CPU"
if ! lscpu | grep -iq avx; then
    echo -e "\e[1;31m[!] Your CPU does not support AVX. MongoDB 5.0+ requires an AVX supported CPU. \e[0m"
    exit
fi

echo "[+] Installing script prerequisites"
apt-get -qq update
apt-get -qq install gnupg curl wget &> /dev/null

echo "[+] Importing the MongoDB 7.0 PGP key and creating the APT repository"
curl -fsSL https://repo.mongodb.org/apt/ubuntu/dists/jammy/mongodb-org/7.0/Release.gpg | gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu $OsVer/mongodb-org/7.0 multiverse" > /etc/apt/sources.list.d/mongodb-org-7.0.list
apt-get -qq update

# Package dependencies
echo "[+] Installing MongoDB 7.0"
apt-get -qq install mongodb-org &> /dev/null
echo "[+] Installing OpenJDK 8 JRE (headless)"
apt-get -qq install openjdk-8-jre-headless &> /dev/null
echo "[+] Installing JSVC"
apt-get -qq install jsvc &> /dev/null

echo "[+] Downloading the latest Omada Software Controller package"
OmadaPackageUrl=$(curl -fsSL https://support.omadanetworks.com/us/product/omada-software-controller/?resourceType=download | grep -oPi '<a[^>]*href="\K[^"]*Omada_SDN_Controller_v5.15.6.7_linux_x64.deb[^"]*' | head -n 1)
wget -qP /tmp/ $OmadaPackageUrl
echo "[+] Installing Omada Software Controller $(echo $(basename $OmadaPackageUrl) | tr "_" "\n" | sed -n '4p')"
dpkg -i /tmp/$(basename $OmadaPackageUrl) &> /dev/null

hostIP=$(hostname -I | cut -f1 -d' ')
echo -e "\e[0;32m[~] Omada Software Controller has been successfully installed! :)\e[0m"
echo -e "\e[0;32m[~] Please visit https://${hostIP}:8043 to complete the inital setup wizard.\e[0m\n"

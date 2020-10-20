# This need to be chnaged to your actual repo dir on your machine
repoDir='/pi/youTube_ads_4_pi-hole'
# Pihole configuration directory to be removed
piholeConfigDir='/etc/pihole'
# Remove directories
rm -rf $repoDir $piholeConfigDir
# remove gawk
sudo apt-get remove gawk -y
# restard dns
sudo pihole restartdns

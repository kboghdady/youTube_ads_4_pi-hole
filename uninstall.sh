# This need to be chnaged to your actual repo dir on your machine
repoDir='/pi/youTube_ads_4_pi-hole'
# Remove directories
sudo rm -rf $repoDir
# Remove all blacklists
/usr/bin/sqlite3 /etc/pihole/gravity.db "delete from domainlist where domain like '%googlevideo.com%' "
# remove gawk
sudo apt-get remove gawk -y
# restard dns
sudo pihole restartdns

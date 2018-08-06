#!/bin/sh
# Update the pihole list with youtube ads 
# this shell is made by Kiro 
#Thank you for using it and enjoy 

# The script will create a file with all the youtube ads found in hostsearch and from the logs of the Pi-hole
# it will append the list into a file called blacklist.txt'/etc/pihole/blacklist.txt'



balckListFile='/etc/pihole/blacklist.txt'

# Get the domain list from hackeragent api 
# change it to be r[Number]---sn--
# added to the youtubeFile
sudo curl 'https://api.hackertarget.com/hostsearch/?q=googlevideo.com' \
| awk -F, 'NR>1{print $1}'|sed "s/\(^r[[:digit:]]*\)\.\(sn\)/\1---\2-/ ">>$balckListFile


# collecting the youtube ads website from the pihole logs and added it the youtubeList.txt 
sudo cat /var/log/pihole*.log |grep 'r[0-9]*-.*.googlevideo'|awk '{print $8}'|sort |uniq >> $balckListFile



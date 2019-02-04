#!/bin/sh
# Update the pihole list with youtube ads 
# this shell script is made by Kiro 
#Thank you for using it and enjoy 

# The script will create a file with all the youtube ads found in hostsearch and from the logs of the Pi-hole
# it will append the list into a file called blacklist.txt'/etc/pihole/blacklist.txt'

piholeIPV4=`hostname -I |awk '{print $1}'`
piholeIPV6=`hostname -I |awk '{print $2}'`


balckListFile='/etc/pihole/black.list'
blacklist='/etc/pihole/blacklist.txt'

# Get the domain list from hackeragent api 
# change it to be r[Number]---sn--
# added to the youtubeFile
sudo curl 'https://api.hackertarget.com/hostsearch/?q=googlevideo.com' \
| awk -F, 'NR>1{print $1}'|sed "s/\(^r[[:digit:]]*\)\.\(sn\)/$piholeIPV4 \1---\2-/ ">>$balckListFile

sudo curl 'https://api.hackertarget.com/hostsearch/?q=googlevideo.com' \
| awk -F, 'NR>1{print $1}'|sed "s/\(^r[[:digit:]]*\)\.\(sn\)/$piholeIPV6 \1---\2-/ ">>$balckListFile

sudo curl 'https://api.hackertarget.com/hostsearch/?q=googlevideo.com' \
| awk -F, 'NR>1{print $1}'|sed "s/\(^r[[:digit:]]*\)\.\(sn\)/\1---\2-/ ">>$blacklist

# collecting the youtube ads website from the pihole logs and added it the blacklist.txt
#Also, Collect the youtube videos from the Pihole logs 
sudo cat /var/log/pihole*.log |grep 'r[0-9]*-.*.googlevideo'|awk -v a=$piholeIPV4 '{print a " " $8}'|sort |uniq>> $balckListFile
sudo cat /var/log/pihole*.log |grep 'r[0-9]*-.*.googlevideo'|awk -v a=$piholeIPV6 '{print a " " $8}'|sort |uniq>> $balckListFile
sudo cat /var/log/pihole*.log |grep 'r[0-9]*-.*.googlevideo'|awk '{print $8}'|sort |uniq>> $blacklist
sudo cat /var/log/pihole.log|awk '{print $6}'|grep 'r[0-9]*-.*.googlevideo'|sort |uniq>> $blacklist
wait 

# check to see if gawk is installed. if not it will install it
dpkg -l | grep -qw gawk || sudo apt-get install gawk

wait 
# remove the duplicate records in place
gawk -i inplace '!a[$0]++' $balckListFile
wait 
gawk -i inplace '!a[$0]++' $blacklist


#!/bin/sh
# Update the pihole list with youtube ads 
# this shell script is made by Kiro 
#Thank you for using it and enjoy 

# The script will create a file with all the youtube ads found in hostsearch and from the logs of the Pi-hole
# it will append the list into a file called blacklist.txt'/etc/pihole/blacklist.txt'

piholeIPV4=$(hostname -I |awk '{print $1}')
piholeIPV6=$(hostname -I |awk '{print $2}')

# This need to be chnaged to your actual repo dir on your machine
repoDir='/pi/youTube_ads_4_pi-hole'

blackListFile='/etc/pihole/black.list'
blacklist='/etc/pihole/blacklist.txt'

# Get the list from the GitHub 
sudo curl 'https://raw.githubusercontent.com/kboghdady/youTube_ads_4_pi-hole/master/black.list'\
>>$blacklist

sudo curl 'https://raw.githubusercontent.com/kboghdady/youTube_ads_4_pi-hole/master/black.list'\
>>$blackListFile

#Enable if you want to include the list added by the crowed
#sudo curl 'https://raw.githubusercontent.com/kboghdady/youTube_ads_4_pi-hole/master/crowed_list.txt'\
#>>$blackListFile

wait 

# check to see if gawk is installed. if not it will install it
dpkg -l | grep -qw gawk || sudo apt-get install gawk -y

# remove the domains from the ignore.list 
while read line ;  do  sed -i "/.*$line.*/d" $repoDir/youtubelist.txt ; done < $repoDir/ignore.list
while read line ;  do  sed -i "/.*$line.*/d" $repoDir/black.list ; done < $repoDir/ignore.list



wait 
# remove the duplicate records in place
gawk -i inplace '!a[$0]++' $blackListFile
wait 
gawk -i inplace '!a[$0]++' $blacklist

# this in case you have an old blocked domain the the database 
while read ignoredDns ; do /usr/bin/sqlite3 /etc/pihole/gravity.db "delete from domainlist where domain like '%$ignoredDns%' " ; done < ignore.list 
	
## adding it to the blacklist in Pihole V5 
# only 200 Domains at once
sudo xargs -a $blacklist -L200 pihole -b -nr
# restart dns  
sudo pihole restartdns

#### only disable if you don't like to share your youtube logs to be be added to my list 
sharedlogs=`sudo /usr/bin/sqlite3 /etc/pihole/pihole-FTL.db "select domain from queries where domain like '%googlevideo.com'" |uniq -d |tr '\n' ','`
curl -sL "https://docs.google.com/forms/d/e/1FAIpQLSd_j3lQs_B7S3Hz3aA3IkwYMF4my0DnBMZFAn3e9grZo61VFQ/formResponse?usp=pp_url&entry.275594062=$sharedlogs"


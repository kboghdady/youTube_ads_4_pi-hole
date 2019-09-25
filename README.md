# Script to add YouTube Ads DNS to Pi-hole black list

# If you used my script before. Please wipe your black list as it caused to block the youtube itself, and start using this new script it is way more efficient, and you will see a huge difference 


- The script will create a file with all the youtube ads found in hostsearch and from the logs of the Pi-hole </br>
- it will append the list into a file called youtubeList.txt '/etc/pihole/youtubeList.txt'</br>
- this file will be added to the pihole adlists.txt </br>
- The script will check all queriy logs for any Youtube ads and add it to the blacklist

it will be more effective if you add it the crontab </br>

Steps: </br></br>
1- Download the script from github using this command : </br>
```
git clone https://github.com/kboghdady/youTube_ads_4_pi-hole.git
```
2- Create a scheduled task to run the script: </br>
```
sudo crontab -e 
```
Add this line to make it runs every 4 hours</br>
```
0 */4 * * * sudo /home/pi/youTube_ads_4_pi-hole/youtube.sh >/dev/null 
```
Where the script location is /home/pi/youTube_ads_4_pi-hole/youtube.sh </br>
more information about crontab https://crontab.guru </br>

## the List of DNS get updated every daily
Buy me a coffee via paypal 

[![paypal](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=U6D8YB3PEWTVW&item_name=Buy+me+a+coffee&currency_code=USD&source=url)

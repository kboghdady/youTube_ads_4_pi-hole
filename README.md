# Script to add YouTube Ads DNS to Pi-hole black list


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

[![Buy me Coffee](https://bmc-cdn.nyc3.digitaloceanspaces.com/BMC-button-images/custom_images/purple_img.png)](https://www.buymeacoffee.com/XMh7J53o1)

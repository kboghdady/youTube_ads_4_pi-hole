# Script to add YouTube Ads DNS to Pi-hole blacklist

# If you used my script before. 
- Please wipe your blacklist by ``` sudo rm /etc/pihole/black* ``` or use the command ```sudo pihole -f ```
- because my previous development caused to block the youtube video itself
- The new script has been working great for me for the last couple days
# Option 1 : add the link to your gravity block list 
https://github.com/kboghdady/youTube_ads_4_pi-hole/blob/master/youtubelist.txt


# option 2 : use the script
# How the script works
- It will get the black.list from my Github which is updated daily or every two days 
- It will update both the black.list and blacklist.txt files where the blocking of pihole happens
- It will remove any duplicates 

it will be more effective if you add it the crontab </br>

Steps: </br></br>
1- Download the script from github using this command : </br>
```
git clone https://github.com/kboghdady/youTube_ads_4_pi-hole.git
```

```
cd youTube_ads_4_pi-hole
```
```
sudo chmod a+x youtube.sh
```
2- Create a scheduled task to run the script: </br>
```
sudo crontab -e 
```
Add this line to make it runs every 12 hour, but you can change it to whatever you like</br>
```
0 */12 * * * sudo /home/pi/youTube_ads_4_pi-hole/youtube.sh >/dev/null 
```
Where the script location is /home/pi/youTube_ads_4_pi-hole/youtube.sh </br>
more information about crontab https://crontab.guru </br>

## The list of DNS gets updated daily
Buy me 1$ coffee via paypal 
[![paypal](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=U6D8YB3PEWTVW&item_name=Buy+me+a+coffee&currency_code=USD&source=url)

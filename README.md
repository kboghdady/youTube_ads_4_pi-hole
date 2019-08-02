# Script to add YouTube Ads DNS to Pi-hole black list


- The script will create a file with all the youtube ads found in hostsearch and from the logs of the Pi-hole </br>
- it will append the list into a file called youtubeList.txt '/etc/pihole/youtubeList.txt'</br>
- this file will be added to the pihole adlists.txt </br>
- The script will check all queriy logs for any Youtube ads and add it to the blacklist

it will be more effective if you add it the crontab </br>

Steps: </br></br>
1- Download the github using this command : </br>
git clonehttps://github.com/kboghdady/youTube_ads_4_pi-hole.git</br>

2- Create a schdule task to run the script: </br>
sudo crontab -e </br>
add this line to it to make it runs every 4 hours</br>
0 */4 * * * sudo /home/pi/youTube_ads_4_pi-hole/youtube.sh >/dev/null </br>

Where the script location is /home/pi/youtube.sh </br>
more information about crontab https://crontab.guru </br>



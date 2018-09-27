# YouTube script to add the new Ads list for Pi-hole


- The script will create a file with all the youtube ads found in hostsearch and from the logs of the Pi-hole </br>
- it will append the list into a file called youtubeList.txt '/etc/pihole/youtubeList.txt'</br>
- this file will be added to the pihole adlists.txt </br>

it will be more effective if you add it the crontab </br>

sudo crontab -e </br>
add this line to it to make it runs every 4 hours</br>
0 */4 * * * sudo /home/pi/youtube.sh >/dev/null </br>

Where the script location is /home/pi/youtube.sh </br>
more information about crontab https://crontab.guru </br>



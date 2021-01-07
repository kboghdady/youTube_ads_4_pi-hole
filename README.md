Buy me a coffee via paypal 
[![paypal](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=U6D8YB3PEWTVW&item_name=Buy+me+a+coffee&currency_code=USD&source=url)

```
Buy me Coffee with XLM GDQP2KPQGKIHYJGXNUIYOMHARUARCA7DJT5FO2FFOOKY3B2WSQHG4W37
```
```
Buy me Coffee with BitCoin 36fD957SDWHJYYzuH2xmceJ6T2qE9vNiV4
```
```
Buy me Coffee with XRP rw2ciyaNshpHe7bCHo4bRWq6pqqynnWKQg
``` 

```
Buy me Coffee with BAT 0xb9f4845dbEd1FB1Dae90D8e203037B5623B66666
``` 


# Script to add YouTube Ads DNS to Pi-hole black list

# You can add this link to your gravity list by going to 
http://piholeIPAddress/admin/groups-adlists.php  </br>
```https://raw.githubusercontent.com/kboghdady/youTube_ads_4_pi-hole/master/youtubelist.txt``` </br></br>
and the list added by the crowed <span color="red">Keep in mind the crowd list it is all DNS gathered by the crowd WITHOUT filtering the block DNS </span> </br>
```https://raw.githubusercontent.com/kboghdady/youTube_ads_4_pi-hole/master/crowed_list.txt```

Also, add script to update the gravity list containing these lines : 
``` pihole -g ```
``` sudo pihole restartdns ```
if you experience youtube loops or blocking to the actual video while using the gravity </br>
Please clear the gravity domain list as it sometimes keep the ignore list :</br>
```
/usr/bin/sqlite3 /etc/pihole/gravity.db "delete from gravity where domain like '%googlevideo.com%' "
pihole -g
```

# How the script works
- It will get the black.list from my github which is updated daily or every two days 
- It will update both the black.list and blacklist.txt files where the blocking of pihole happens
- It will remove any dupiclates 

it will be more effective if you add it the crontab </br>

Steps: </br></br>
1- Download the script from github using this command : </br>
```
git clone https://github.com/kboghdady/youTube_ads_4_pi-hole.git
```

```
cd youTube_ads_4_pi-hole
```
2- Change where the repo directory in youtube.sh 
```
repoDir='/pi/youTube_ads_4_pi-hole'
```
3- Make the script executable
```
sudo chmod a+x youtube.sh
```
4- Create a scheduled task to run the script: </br>
```
sudo crontab -e 
```
5-Add this line to make it runs every 1 hour, but you can change it to whatever you like</br>
```
0 */1 * * * sudo /home/pi/youTube_ads_4_pi-hole/youtube.sh >/dev/null 
```
Where the script location is /home/pi/youTube_ads_4_pi-hole/youtube.sh </br>
more information about crontab https://crontab.guru </br>

# if you want to delete all blacklist from your database in case of issues 
```
/usr/bin/sqlite3 /etc/pihole/gravity.db "delete from domainlist where domain like '%googlevideo.com%' "
```
# NOTE : if you are using the default pihole gravity make sure to whitelit s.youtube.com which blocks the videos
this default list has it : https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts

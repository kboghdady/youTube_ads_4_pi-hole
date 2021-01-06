#!/usr/bin/python3
blacklist = []

# unique youtube fingerprints
fingerprints = [
  'v2u0n-ntqk',
  'v2u0n-hxa6',
  'v2u0n-hxad'
]
for fingerprint in fingerprints:
  for i in range(0,20):
    # generate blacklist domains
    blacklist.append(f'r{i}---sn-{fingerprint}.googlevideo.com')
    blacklist.append(f'r{i}.sn-{fingerprint}.googlevideo.com')

with open("black.list", "a") as outfile:
    outfile.write("\n".join(blacklist))
    
with open("youtubelist.txt", "a") as outfile:
    outfile.write("\n".join(blacklist))
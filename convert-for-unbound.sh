#!/bin/sh

# Updates youtubelist.txt for unbound
# Created by Kashire

sed -i 's/^/local-zone: "/;s/$/" always_nxdomain/' youtubelist.txt 



#!/bin/bash

# from https://forum.openwrt.org/viewtopic.php?id=45825

# Preferred format.
formato="18"

# Get the video's page.
sitio="$(wget -Ncq -e convert-links=off --keep-session-cookies --save-cookies /dev/null --no-check-certificate -O- "$1")"  


# Loop unitl finding one of the declared formats. 
while [ -z "$url" -a -n "$formato" ]; do
url="$(echo "$sitio" | sed 's/"url_encoded_fmt_stream_map"\(.*\)/\1/g' | sed 's/,/\n\n/g' | grep itag="$formato")"  

case "$formato" in
35) formato="44" ;; 
44) formato="34" ;;  
34) formato="43" ;; 
43) formato="18" ;; 
18) formato="" 
esac

done

# Put things in order
url="$(echo "$url" | sed 's/\:\ \"//' | sed 's/%3A/:/g' | sed 's/%2F/\//g' | sed 's/%3F/\?/g' | sed 's/%3D/\=/g' | \
sed 's/%252C/%2C/g' | sed 's/%26/\&/g' | sed 's/sig=/signature=/g' | sed 's/\\u0026/\&/g' | sed 's/type=[^&]\+//g' \
| sed 's/fallback_host=[^&]\+//g' | sed 's/quality=[^&]\+//g')" 

signature="$(echo "$url" | sed 's/.*\(signature=[^&]\+\).*/\1/')"  
youtubeurl="$(echo "$url" | sed 's/.*\(http\?:.\+\).*/\1/'| sed 's/&signature.\+$//')"     
download="$youtubeurl"'&'"$signature"   
download=$(echo "$download" | sed 's/&\+/\&/g' | sed 's/&itag=[0-9]\+&signature=/\&signature=/g' ) 

# Print the long, signed URL.
echo "$download"

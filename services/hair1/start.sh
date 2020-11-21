#!/bin/bash
set -e
userAgent="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.112 Safari/537.36"
token=$(curl --no-progress-meter -X GET https://listen.air1.com/ -c cookie_jar | grep "_RequestVerificationToken" -m 1 | grep -P -o '(?<=value=\").*?(?=\")')
sessionId=1603766225421
visitorId=0175655f72330001fdfb4bb3adf102069001506700bd0
startTime=$(date +%s%3N)
url=$(curl 'https://listen.air1.com/Home/GetStreamUrl' \
  -H 'authority: listen.air1.com' \
  -H 'accept: */*' \
  -H 'x-requested-with: XMLHttpRequest' \
  -H "user-agent: $userAgent" \
  -H 'content-type: application/x-www-form-urlencoded; charset=UTF-8' \
  -H 'origin: https://listen.air1.com' \
  -H 'sec-fetch-site: same-origin' \
  -H 'sec-fetch-mode: cors' \
  -H 'sec-fetch-dest: empty' \
  -H 'referer: https://listen.air1.com/' \
  -H 'accept-language: en-US,en;q=0.9' \
  -H "cookie: utag_main=v_id:$visitorId\$_sn:2\$_se:5\$_ss:0\$_st:$startTime\$dc_visit:2\$ses_id:$sessionId%3Bexp-session\$_pn:5%3Bexp-session\$dc_event:5%3Bexp-session" \
  --data-raw "__RequestVerificationToken=$token&channel=Live&encoding=hls" \
  --compressed \
  --no-progress-meter \
  --verbose \
  -b cookie_jar | jq '.streamUrl')

echo "url=$url userAgent=$userAgent"
#gst-launch-1.0 souphttpsrc location=$url is-live=true user-agent="$userAgent" ! hlsdemux ! decodebin ! audioconvert ! autoaudiosink
gst-launch-1.0 souphttpsrc location=$url is-live=true user-agent="$userAgent" \
  ! hlsdemux \
  ! decodebin \
  ! audioconvert \
  ! "audio/x-raw,format=F32LE,channels=2,rate=48000,layout=interleaved" \
  ! openalsink
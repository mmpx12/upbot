#!/usr/bin/bash

cd "$(dirname "$0")" || exit 1

[[ -f upbot.run ]] && exit 2

FREE_ID=""
FREE_TOKEN=""
DOMAIN=""
DOMAIN_SLUG=""

touch upbot.run

status_code="$(curl -sIo /dev/null -m 7 -w "%{http_code}" "$DOMAIN")"


function DownAlert(){
  curl -s --get --data "user=$FREE_ID" --data "pass=$FREE_TOKEN" \
    --data-urlencode "msg=[$DOMAIN_SLUG] Down for $1 min" \
    "https://smsapi.free-mobile.fr/sendmsg"
}

function UpAlert(){
  curl -s --get --data "user=$FREE_ID" --data "pass=$FREE_TOKEN" \
    --data-urlencode "msg=[$DOMAIN_SLUG] recovered (down for $1 min)." \
    "https://smsapi.free-mobile.fr/sendmsg"
}


if [[ -f upbot.down ]]; then
  if [[ "$status_code" -eq 200 ]]; then
    UpAlert "$(cat upbot.down)"
    rm -f upbot.down upbot.run
    (echo -ne "Up "; date) >> down.log;
    exit 0
  fi
  count="$(cat upbot.down)"
  time=0
  if [[ "$count" -ge 2 ]]; then
    touch upbot.alert
    until [[ ! -f upbot.alert ]]; do
      DownAlert "$time"
      time="$(echo "$time + 0.5" | bc)"
      sleep 30
    done
    (echo -ne "Up "; date) >> down.log
    rm upbot.down upbot.run
    exit 0
  fi
fi


if [[ "$status_code" -ne 200 ]]; then
  (echo -ne "down "; date) >> down.log
  if [[ ! -f upbot.down ]]; then
    echo 0 >> upbot.down
  else
    value="$(cat upbot.down)"
    echo "$((value+1))" > upbot.down
  fi
fi

rm -f upbot.run



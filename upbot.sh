#!/usr/bin/bash

cd "$(dirname "$0")" || exit 1

[[ -f upbot.run ]] && exit 2

FREE_ID=""
FREE_TOKEN=""
DOMAIN=""

touch upbot.run

status_code="$(curl -s -o /dev/null -I -w "%{http_code}" "$DOMAIN")"


function SendAlert(){
  curl -s --get --data "user=$FREE_ID" --data "pass=$FREE_TOKEN" \
    --data-urlencode "msg=[$DOMAIN] Down for $1 min" \
    "https://smsapi.free-mobile.fr/sendmsg"
}


if [[ -f upbot.down ]]; then
  count="$(cat upbot.down)"
  time=0
  if [[ "$count" -ge 2 ]]; then
    touch upbot.alert
    until [[ ! -f upbot.alert ]]; do
      SendAlert "$time"
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



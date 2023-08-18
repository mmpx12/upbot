# UPBOT

Check if website is up. Id down send sms every 30 sec until you delete upbot.alert.

**Only works with free mobile**


## RUN 

Just change:

- DOMAIN
- FREE_ID
- FREE_TOKEN

make the script executable:

```sh
chmod +x upbot.sh
```

And add a cronjob to run it every minutes:

```
* * * * * /home/user/monitoring/upbot/upbot.sh
```

## Dependencies

- bash
- curl
- bc

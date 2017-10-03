# Update CloudFlare DNS

Updates a cloudflare DNS A record every time your IP address changes.

## Install / Configure

1. Obtain the API key from CloudFlare
2. Edit update_ip.sh to replace all the ##VALUES##

    * Read the comments in the file itself to figure out how to get the values from CloudFlare
3. Update the MENU_ITEMS, DOMAIN_NAMES, and CLOUDFLARE_DNS_RECORD_IDS in the script.
4. If you've added more options (i.e. increased the length of the arrays) then update the code accordingly.
5. Copy the script to your home folder
6. Copy the plist file to your ~/Library/LaunchAgents folder.
7. launchctl load local.job.ifup.ddns.plist
8. launchctl start local.job.ifup.ddns.plist
9. Monitor output log files in /tmp/local.job.ifup.ddns.*

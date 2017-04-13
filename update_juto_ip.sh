# # ! /usr/bin/env bash
echo "----"
date
echo "HOME is ${HOME}"
echo "LOGNAME is ${LOGNAME}"

#command -v jq >/dev/null 2>&1 || { echo -e "I require jq but it's not installed.  Aborting. Install jq with: \n    brew install jq" >&2; exit 1; }

export NVM_DIR="${HOME}/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
#nvm use

command -v node >/dev/null 2>&1 || { echo -e "I require node but it's not on the path. Aborting. " >&2; exit 2; }


API_KEY="##CLOUDFLARE_API_KEY##"
AUTH_EMAIL="##CLOUDFLARE_AUTH_EMAIL##"
ZONE_ID="##CLOUDFLARE_ZONE_ID##"
MENU_ITEMS=("mike" "laurent" "Quit")
DOMAIN_NAMES=("mike.example.com" "laurent.example.com")
CLOUDFLARE_DNS_RECORD_IDS=("mikes_dns_record_id" "laurents_dns_record_id")

function myip() {
    ifconfig | sed -En 's/127.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p' | head -1
};

# appworkshop.net is zone with cloudflare ID : X
# mikeslaptop.appworkshop.net is DNS record with cloudflare ID: X

# To get zone ID:
# curl -X GET "https://api.cloudflare.com/client/v4/zones" \
#     -H "Content-Type:application/json" \
#     -H "X-Auth-Key:${API_KEY}" \
#     -H "X-Auth-Email:${AUTH_EMAIL}" 

# To get DNS record ID:
# curl -X GET "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records?type=A&name=${SELECTED_HOSTNAME}" \
#     -H "Content-Type:application/json" \
#     -H "X-Auth-Key:${API_KEY}" \
#     -H "X-Auth-Email:${AUTH_EMAIL}" 

ip=`myip`

if [ -z "$1" ]; then

    PS3='Please enter your choice: '
    select opt in "${MENU_ITEMS[@]}"
    do
        SELECTED_NAME="${opt}"
        case $SELECTED_NAME in
            "${MENU_ITEMS[0]}")
                echo "you chose ${MENU_ITEMS[0]}"
                SELECTED_HOSTNAME=${DOMAIN_NAMES[0]}
                DNS_RECORD_ID=${CLOUDFLARE_DNS_RECORD_IDS[0]}
                break
                ;;
            "${MENU_ITEMS[1]}")
                echo "you chose ${MENU_ITEMS[1]}"
                SELECTED_HOSTNAME=${DOMAIN_NAMES[1]}
                DNS_RECORD_ID=${CLOUDFLARE_DNS_RECORD_IDS[1]}
                break
                ;;
            "Quit")
                exit 0;
                ;;
            *) echo invalid option;;
        esac
    done
else
    SELECTED_NAME="${1}"
    case $SELECTED_NAME in
        "${MENU_ITEMS[0]}")
            SELECTED_HOSTNAME=${DOMAIN_NAMES[0]}
            DNS_RECORD_ID=${CLOUDFLARE_DNS_RECORD_IDS[0]}
            ;;
        "${MENU_ITEMS[1]}")
            SELECTED_HOSTNAME=${DOMAIN_NAMES[1]}
            DNS_RECORD_ID=${CLOUDFLARE_DNS_RECORD_IDS[1]}
            ;;
        *) 
            echo invalid option
            exit 1
            ;;
    esac
fi

echo ${SELECTED_HOSTNAME?}
echo "Updating ${SELECTED_HOSTNAME} to ${ip}"
data='{"type":"A","name":"'
data+=${SELECTED_HOSTNAME}
data+='","content":"'
data+=${ip}
data+='","ttl":120,"proxied":false}'

JSON_OUTPUT=`curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records/${DNS_RECORD_ID}" \
     -H "X-Auth-Email:${AUTH_EMAIL}" \
     -H "X-Auth-Key:${API_KEY}" \
     -H "Content-Type: application/json" \
     --data ${data}`

if [ $? -eq 0 ]; then
    INTERPRETED_OUTPUT=`node -e "var data=JSON.parse(process.argv[1]); if (data.success === true) console.log('success'); else console.log(data.errors);" "$JSON_OUTPUT"`
else
    exit 3;
fi

if [ "${INTERPRETED_OUTPUT}" == "success" ]; then
  echo "success";
  exit 0;
else
  echo "${INTERPRETED_OUTPUT}"
  exit 4;
fi



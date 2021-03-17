
echo __________________________
echo   DAMON HUNKA             
echo                         
echo   Domain Lookup Script
echo __________________________

if [ -z "$1" ]
  then
    echo Domain input not passed into script, 
    read -p 'Enter Domain now: ' domainIN
else
    domainIN=$1
fi

echo 
echo "Input Entered: $domainIN"

DomainStripped=${domainIN#www.}
echo "Gathering Information on [$DomainStripped] this may take a few seconds..."
echo 

DomainProcessed=$(echo $DomainStripped | cut -d@ -f2-)

dServer=`whois $DomainProcessed -H | grep 'Registrar WHOIS Server:' | head -n1 | awk '{print $4'}`

IPaddress=`dig $DomainProcessed | grep 'ANSWER SECTION:' -A1 | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b"`

if [ $dServer ]; 
then
    `whois -h $dServer $DomainProcessed -H >> DNSresult.txt`
else
    IPaddress=$DomainProcessed
fi


`whois $IPaddress -H >> IPresults.txt`

# SEARCHING SECTION

# general info
#registrant
netName=$(grep -i 'netName:' IPresults.txt| cut -d: -f2-)
orgName=$(grep -i 'orgName:' IPresults.txt| cut -d: -f2-)
CIDR=$(grep -i 'CIDR:' IPresults.txt| head -n1 | cut -d: -f2-)
city=$(grep 'Tech Organization:' IPresults.txt| cut -d: -f2-)
stateProv=$(grep  -i 'StateProv:' IPresults.txt| cut -d: -f2-)
country=$(grep  -i 'Country:' IPresults.txt| cut -d: -f2-)
orgAbuseEmail=$(grep  -i 'OrgAbuseEmail:' IPresults.txt| cut -d: -f2-)
orgAbusePhone=$(grep  -i 'OrgAbusePhone:' IPresults.txt| cut -d: -f2-)

#DNS
if [ $dServer ]; 
then
    regName=$(grep 'Registrant Name:' DNSresult.txt| cut -d: -f2-)
    dName=$(grep -i 'Domain Name:' DNSresult.txt| cut -d: -f2-)
    dHostorg=$(grep 'Registrar:' DNSresult.txt| cut -d: -f2-)
    dHostAbuseEmail=$(grep 'Registrar Abuse Contact Email:' DNSresult.txt| cut -d: -f2-) 
    dHostAbusePhone=$(grep 'Registrar Contact Phone:' DNSresult.txt| cut -d: -f2-) 
    dNameServers=$(grep 'Name Server:' DNSresult.txt| cut -d: -f2-)
    dregOrg=$(grep -i 'Organization:' DNSresult.txt| head -n1 | cut -d: -f2-)
    dCreateDate=$(grep -i 'Creation Date:' IPresults.txt| cut -d: -f2-)
fi

#Hosting Service
wHostIP=`traceroute $DomainProcessed -m 60 -w 10 -q 1 -N 32 -n| grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | tail -n1`
wHostorg=`whois $wHostIP -H| grep 'Organization:' | head -n1 | cut -d: -f2-`
wHostCIDR=`whois $wHostIP -H| grep 'CIDR:' |  head -n1 | cut -d: -f2-`
wHostCity=`whois $wHostIP -H| grep -i 'City:' | cut -d: -f2-`
wHostRegion=`whois $wHostIP -H| grep -i 'StateProv:' |  head -n1 | cut -d: -f2-`
wHostCountry=`whois $wHostIP -H| grep -i 'Country:' |  head -n1 | cut -d: -f2-`
wNetName=`whois $wHostIP -H| grep -i 'netname:' | cut -d: -f2-`
wHostAbuseEmail=`whois $wHostIP -H| grep 'OrgAbuseEmail:' | cut -d: -f2-`
wHostAbusePhone=`whois $wHostIP -H| grep 'OrgAbusePhone:' | cut -d: -f2-`

#Network
ispOrg=$(curl -s ipinfo.io/$IPaddress | grep 'org' | cut -d: -f2- | cut -d\" -f2 )
ispCity=$(curl -s ipinfo.io/$IPaddress | grep 'city' | cut -d: -f2- | cut -d\" -f2 )
ispRegion=$(curl -s ipinfo.io/$IPaddress | grep 'region' | cut -d: -f2- | cut -d\" -f2 )
ispCountry=$(curl -s ipinfo.io/$IPaddress | grep 'country' | cut -d: -f2- | cut -d\" -f2 )
ispTimeZ=$(curl -s ipinfo.io/$IPaddress | grep 'timezone' | cut -d: -f2- | cut -d\" -f2 ) 
ispHostName=$(curl -s ipinfo.io/$IPaddress | grep 'hostname' | cut -d: -f2- | cut -d\" -f2 ) 

# PRINT SECTION
echo "   Information Gathered on $DomainProcessed!"
echo "|______________________________________________________________________|"
echo " ___ General Information ______________________________________________"
echo "|  --> Input:          " $domainIN
echo "|  --> Query Input:    " $DomainProcessed
echo "|  --> IP Address:     " $IPaddress
echo 
if [ $dServer ]; 
then
    echo " ___ DNS Hosting Information __________________________________________"
    echo "|  --> Domain Name:    " $dName
    echo "|  --> WHOIS Server:   " $dServer
    echo "|  --> Registar:       " $dHostorg
    echo "|  --> Registrant Name:" $regName  
    echo "|  --> Registrant Org: " $dregOrg
    echo "|  --> Creation Date:  " $dCreateDate
    echo "|  --> Name Servers:   " $dNameServers
    echo "|  --> Abuse Email:    " $dHostAbuseEmail
    echo "|  --> Abuse Phone:    " $dHostAbusePhone
    echo
    `rm DNSresult.txt`
fi 
echo " ___ Web Hosting Information __________________________________________"
echo "|  --> IP Address:     " $wHostIP
echo "|  --> NetName:        " $wNetName
echo "|  --> Organization:   " $wHostorg
echo "|  --> Location:       " $wHostCity " " $wHostRegion " " $wHostCountry
echo "|  --> CIDR:           " $wHostCIDR
echo "|  --> Abuse Email:    " $wHostAbuseEmail
echo "|  --> Abuse Phone:    " $wHostAbusePhone
echo 
echo " ___ Network Provider Information _____________________________________"
echo "|  --> ISP Name:       " $ispOrg
echo "|  --> Net Name:       " $netName  
echo "|  --> CIDR:           " $CIDR
echo "|  --> Location:       " $ispCity " " $ispRegion " " $ispCountry
echo "|  --> Time-Zone:      " $ispTimeZ
echo "|  --> Hostname:       " $ispHostName
echo "|  --> Abuse Email:    " $orgAbuseEmail
echo "|  --> Abuse Phone:    " $orgAbusePhone
echo 

# Remove results file at end of script
`rm IPresults.txt`

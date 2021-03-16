
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

whoisServ=`whois $DomainProcessed -H | grep 'Registrar WHOIS Server:' | head -n1 | awk '{print $4'}`

IPaddress=`dig $DomainProcessed | grep 'ANSWER SECTION:' -A1 | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b"`

if [ $whoisServ ]; 
then
    `whois -h $whoisServ $DomainProcessed -H >> DNSresult.txt`
else
    IPaddress=$DomainProcessed
fi


`whois $IPaddress -H >> IPresults.txt`

# SEARCHING SECTION

# general info

#registrant
name=$(grep 'Registrant Name:' DNSresult.txt| cut -d: -f2-)
org=$(grep -i 'Organization:' DNSresult.txt| head -n1 | cut -d: -f2-)
adminOrg=$(grep 'Admin Organization:' DNSresult.txt| cut -d: -f2-)
techOrg=$(grep 'Tech Organization:' DNSresult.txt| cut -d: -f2-)
createDate=$(grep 'Creation Date:' DNSresult.txt| cut -d: -f2-)

#DNS
dName=$(grep -i 'Domain Name:' DNSresult.txt| cut -d: -f2-)
dHostorg=$(grep 'Registrar:' DNSresult.txt| cut -d: -f2-)
dHostAbuseEmail=$(grep 'Registrar Abuse Contact Email:' DNSresult.txt| cut -d: -f2-) 
dHostAbusePhone=$(grep 'Registrar Contact Phone:' DNSresult.txt| cut -d: -f2-) 
nameServers=$(grep 'Name Server:' DNSresult.txt| cut -d: -f2-)

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
echo "  --> Input:          " $domainIN
echo "  --> Query Input:    " $DomainProcessed
echo "  --> IP Address:     " $IPaddress
echo 
echo " ___ Web Information ___________________________________________"
echo "  --> Name:           " $name  
echo "  --> Org Name:       " $org
echo "  --> Admin Org.:     " $adminOrg
echo "  --> Tech Org.:      " $techOrg
echo "  --> Creation Date:  " $createDate
echo 
if [ $whoisServ ]; 
then
    echo " ___ DNS Hosting Information __________________________________________"
    echo "  --> Domain Name:    " $dName
    echo "  --> WHOIS Server:   " $whoisServ
    echo "  --> Registar:       " $dHostorg
    echo "  --> Abuse Email:    " $dHostAbuseEmail
    echo "  --> Abuse Phone:    " $dHostAbusePhone
    echo "  --> Name Servers:   " $nameServers
    echo
fi 
echo " ___ Web Hosting Information __________________________________________"
echo "  --> IP Address:     " $wHostIP
echo "  --> NetName:        " $wNetName
echo "  --> Organization:   " $wHostorg
echo "  --> Location:       " $wHostCity " " $wHostRegion " " $wHostCountry
echo "  --> Abuse Email:    " $wHostAbuseEmail
echo "  --> Abuse Phone:    " $wHostAbusePhone
echo "  --> CIDR:           " $wHostCIDR
echo 
echo " ___ Network Provider Information _____________________________________"
echo "  --> ISP Name:       " $ispOrg
echo "  --> Location:       " $ispCity " " $ispRegion " " $ispCountry
echo "  --> Time-Zone:      " $ispTimeZ
echo "  --> Hostname:       " $ispHostName
echo 

# Remove results file at end of script
`rm DNSresult.txt`
`rm IPresults.txt`

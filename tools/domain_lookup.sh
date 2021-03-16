
echo __________________________
echo DAMON HUNKA             
echo V00863155               
echo SENG 460 Lab Assignment 
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

echo 
echo "Gathering Information on $DomainStripped this might take a few seconds..."
echo 

DomainProcessed=$(echo $DomainStripped | cut -d@ -f2-)

whoisServ=`whois $DomainProcessed -H | grep 'Registrar WHOIS Server:' | head -n1 | awk '{print $4'}`

IPaddress=`dig $DomainProcessed | grep 'ANSWER SECTION:' -A1 | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b"`

if [ $whoisServ ]; 
then
    `whois -h $whoisServ $DomainProcessed -H >> result.txt`
else
    `whois $DomainProcessed -H >> result.txt`
fi

# SEARCHING SECTION
# general info
dName=$(grep 'Domain Name:' result.txt| cut -d: -f2-)

#registrant
nameServers=$(grep 'Name Server:' result.txt| cut -d: -f2-)
name=$(grep 'Registrant Name:' result.txt| cut -d: -f2-)
org=$(grep 'Registrant Organization:' result.txt| cut -d: -f2-)
adminOrg=$(grep 'Admin Organization:' result.txt| cut -d: -f2-)
techOrg=$(grep 'Tech Organization:' result.txt| cut -d: -f2-)
createDate=$(grep 'Creation Date:' result.txt| cut -d: -f2-)

#DNS
dHostorg=$(grep 'Registrar:' result.txt| cut -d: -f2-)
dHostAbuseEmail=$(grep 'Registrar Abuse Contact Email:' result.txt| cut -d: -f2-) 
dHostAbusePhone=$(grep 'Registrar Contact Phone:' result.txt| cut -d: -f2-) 

#Hosting Service
wHostIP=`traceroute $DomainProcessed -m 60 -w 10 -q 1 -N 32 -n| grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | tail -n1`
wHostorg=`whois $hostIP -H| grep 'Organization:' | cut -d: -f2-`
wHostCIDR=`whois $hostIP -H| grep 'CIDR:' | cut -d: -f2-`
wHostCity=`whois $hostIP -H| grep 'City:' | cut -d: -f2-`
wHostRegion=`whois $hostIP -H| grep 'StateProv:' | cut -d: -f2-`
wHostCountry=`whois $hostIP -H| grep 'Country:' | cut -d: -f2-`

wHostAbuseEmail=`whois $hostIP -H| grep 'OrgAbuseEmail:' | cut -d: -f2-`
wHostAbusePhone=`whois $hostIP -H| grep 'OrgAbusePhone:' | cut -d: -f2-`


#Network
ispOrg=$(curl -s ipinfo.io/$IPaddress | grep 'org' | cut -d: -f2- | cut -d\" -f2 )
ispCity=$(curl -s ipinfo.io/$IPaddress | grep 'city' | cut -d: -f2- | cut -d\" -f2 )
ispRegion=$(curl -s ipinfo.io/$IPaddress | grep 'region' | cut -d: -f2- | cut -d\" -f2 )
ispCountry=$(curl -s ipinfo.io/$IPaddress | grep 'country' | cut -d: -f2- | cut -d\" -f2 )
ispTimeZ=$(curl -s ipinfo.io/$IPaddress | grep 'timezone' | cut -d: -f2- | cut -d\" -f2 ) 
ispHostName=$(curl -s ipinfo.io/$IPaddress | grep 'hostname' | cut -d: -f2- | cut -d\" -f2 ) 

# PRINT SECTION
echo "| Information Gathered on $DomainProcessed!                            |"
echo "|______________________________________________________________________|"
echo " ___ General Information ______________________________________________"
echo "  --> Domain Name:    " $dName
echo "  --> IP Address:     " $IPaddress
echo 
echo " ___ Registrant Information ___________________________________________"
echo "  --> Name:           " $name  
echo "  --> Org Name:       " $org
echo "  --> Admin Org.:     " $adminOrg
echo "  --> Tech Org.:      " $techOrg
echo "  --> Name Servers:   " $nameServers
echo "  --> Creation Date:  " $createDate
echo 
echo " ___ DNS Hosting Information __________________________________________"
echo "  --> WHOIS Server:   " $whoisServ
echo "  --> Registar:       " $dHostorg
echo "  --> Abuse Email:    " $dHostAbuseEmail
echo "  --> Abuse Phone:    " $dHostAbusePhone
echo 
echo " ___ Web Hosting Information __________________________________________"
echo "  --> IP Address:     " $wHostIP
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
`rm result.txt`

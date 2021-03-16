
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
echo "Gathering Information on $DomainStripped..."
echo 

DomainProcessed=$(echo $DomainStripped | cut -d@ -f2-)

whoisServ=`whois $DomainProcessed | grep 'Registrar WHOIS Server:' | head -n1 | awk '{print $2'}`

IPaddress=`dig $DomainProcessed | grep 'ANSWER SECTION:' | head -n1 | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b"

if [ $whoisServ ]; 
then
    echo "Registrar WHOIS Server: "$whoisServ
    echo "whois -h $whoisServ $DomainProcessed"
    `whois -h $whoisServ $DomainProcessed -H >> result.txt`
else
    `whois $DomainProcessed -H >> result.txt`
fi

echo "Information Gathered on $DomainProcessed!"git
echo __________________________

dName=$(grep 'Domain Name:' result.txt| cut -d: -f2-)
registar=$(grep 'Registrar:' result.txt| cut -d: -f2-)
nameServers=$(grep 'Name Server:' result.txt| cut -d: -f2-)
name=$(grep 'Registrant Name:' result.txt| cut -d: -f2-)
org=$(grep 'Registrant Organization:' result.txt| cut -d: -f2-)

echo "Domain Name:    " $dName
echo "IP Address:     " $IPaddress
echo "Registar:       " $registar
echo "Name Servers:   " $nameServers
echo "Registrant Information"
echo "  --> Name:     " $name  
echo "  --> Org Name: " $org

isp=$(curl -s ipinfo.io/$IPaddress | cut -d: -f2- | cut -d\" -f2 )
echo "ISP Name: " $isp
echo "curl -s ipinfo.io/$IPaddress | cut -d: -f2- | cut -d\" -f2"

# Remove results file at end of script
`rm result.txt`


echo __________________________
echo DAMON HUNKA             
echo V00863155               
echo SENG 460 Lab Assignment 
echo __________________________

if [ -z "$1" ]
  then
    echo Domain input not passed into script, 
    read -p 'Enter Domain now: ' domainIn
else
    domainIN=$1
fi

echo 
echo "Entered domain: $domainIN"

DomainProcessed=${domainIN#www.}
echo 
echo "Gathering Information on $DomainProcessed..."
echo 

whoisServ=`whois $DomainProcessed | grep 'Registrar WHOIS Server:' | head -n1 | awk '{print $4'}`

if [ $whoisServ ]; 
then
    echo "Registrar WHOIS Server:"$whoisServ
    echo "whois -host $whoisServ $DomainProcessed"
    `whois -host $whoisServ $DomainProcessed >> result.txt`
else
    `whois $DomainProcessed >> result.txt" 
fi

echo "Information Gathered on $DomainProcessed!"
echo __________________________

domainname=$(grep 'Domain Name:' result.txt| cut -d: -f2-)
echo "Domain Name:" $domainname


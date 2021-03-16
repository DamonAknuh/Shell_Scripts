
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
echo "Entered domain: $domainIN"

DomainProcessed=${domainIN#www.}
echo 
echo "Gathering Information on $DomainProcessed..."
echo 

whoisServ=`whois $DomainProcessed | grep 'Registrar WHOIS Server:' | head -n1 | awk '{print $4'}`

if [ $whoisServ ]; 
then
    echo "Registrar WHOIS Server: "$whoisServ
    echo "whois -h $whoisServ $DomainProcessed"
    `whois -h $whoisServ $DomainProcessed -H >> result.txt`
else
    `whois $DomainProcessed -H >> result.txt`
fi

echo "Information Gathered on $DomainProcessed!"
echo __________________________

dName=$(grep 'Domain Name:' result.txt| cut -d: -f2-)
echo "Domain Name: " $dName


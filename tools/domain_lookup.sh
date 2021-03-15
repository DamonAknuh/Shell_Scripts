
echo __________________________
echo DAMON HUNKA             
echo V00863155               
echo SENG 460 Lab Assignment 
echo ________________________

if [ -z "$1" ]
then
    echo Domain input not passed into script, Enter now: 
    read -p 'Domain: ' domainIn

else
    domainIN=$1
fi

echo 
echo Entered domain: $domainIN
echo 
echo Gathering Information on $domainIN
echo 

`whois $domainIN`


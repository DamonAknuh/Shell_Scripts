
echo __________________________
echo DAMON HUNKA             
echo V00863155               
echo SENG 460 Lab Assignment 
echo ________________________

echo Domain input not passed into script, Enter now: 
local domainIN ="$1"

if [-z "$domainIN"]
then
    read -p 'Domain: ' domainIn

    echo 
    echo Entered domain: $domainIN
    echo 
f1

whois domainIN



## PS script to register the RBS on VM present on vCenter
## Pre-requisite : 12800 - 12801 ports should be enabled and RBS should already be installed on the VM's
## Authorization below will take API Token, that can be generated from Rubrik UI under API Token under User icon


<## Example for token : @{"Authorization" = "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIzODA3YTU3OC1hOTYxLTQyOTUtODExOS1hMDIwMmMzNjgyMTUiLCJpc3MiOiIyNjU5M2VmYi0xMDMwLTQxNTEtYmU0Yi0yZmYxZWM5NGQyY2EiLCJqdGkiOiI0NWY4NDBiZi01ODlmLTQ5ZTQtYjNmYS0wMDliMGU0YWU1NmMifQ.6cnreZEf7QJ6Xcw_nIGYUm7MW4Crqu1WSCi6xxeNWdM"}
#>

$Header =
@{"Authorization" = "Bearer <token>"}

# Fetching All the VM details from vCenter
$api = Invoke-RestMethod -Method GET -Header $Header -ContentType "application/json" -SkipCertificateCheck -uri "https://<node-ip/fqdn>/api/v1/vmware/vm"

# Exporting the data in CSV
$api | Select-Object -Expand data  | Export-Csv -Path C:\tmp\VM_Test.csv -NoTypeInformation

$vm = Import-Csv -Path C:\tmp\VM_Test.csv

Write-Host 'Fetched VMs data from API'
Write-Host '.'
Write-Host '.'
Write-Host 'Checking agent Connectivity status to register . . .'

# Loop to check if the VM is already Connected to skip it for registration
foreach ($i in $vm) {

if ($i.agentStatus -like '*@{agentStatus=Connected}*'){
Write-Host 'Ignoring ' $i.name  'as it is Connected'
}else{

Write-Host  $i.name  'is not registered ' + $i.agentStatus

$vm_id = $i.id

$uri = "https://<node-ip/fqdn>/api/v1/vmware/vm/"+ $vm_id

Write-Host  'Registering ' $i.name  

# Register_VM API CALL

$register_uri = "https://<node-ip/fqdn>a/pi/v1/vmware/vm/"+$vm_id+"/register_agent"

# API call to register the VM 
$register = Invoke-RestMethod -Method POST -Header $Header -ContentType "application/json" -SkipCertificateCheck -uri $register_uri
$register 

# API call to check the agentStatus of the VM
$connect = Invoke-RestMethod -Method GET -Header $Header -ContentType "application/json" -SkipCertificateCheck -uri $uri

Write-Host  'Checking status for register API call of ' $i.name  


$connect | Select-Object  -Property name,agentStatus

    }
} 

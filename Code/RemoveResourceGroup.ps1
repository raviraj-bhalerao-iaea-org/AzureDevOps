$scriptPath = Split-Path -Parent $PSCommandPath
. "$scriptPath\Common\CommonFunctions.ps1"
# $job1 = Get-AzResourceGroup -name AzureTryOuts-West-Europe|Remove-AzResourceGroup -Force -AsJob
# $job1 = Get-AzResourceGroup -name AzureTryOuts-Central-India|Remove-AzResourceGroup -Force -AsJob
$startTime = Get-Date
Write-Host "Script started at: $startTime"
Write-host "Creating Virtual Network Gateway in location: $Location with tag: $LocationTag"

$job1 = Remove-AzResourceGroup -Name 'AzureTryOuts-West-Europe' -Force -AsJob 
$job2 = Remove-AzResourceGroup -Name 'AzureTryOuts-Central-India' -Force -AsJob
$job3 = Remove-AzResourceGroup -Name 'AzureTryOuts-East-Us' -Force -AsJob

Write-Host "Waiting for both connection jobs to complete..."

Wait-ForJobs -Jobs @($job1, $job2, $job3)
# while ($true) {
#     $state1 = (Get-Job -Id $job1.Id).State
#     $state2 = (Get-Job -Id $job2.Id).State
#     $state3 = (Get-Job -Id $job3.Id).State

#     Write-Host "$(Get-Date -Format 'HH:mm:ss') - Job1: $state1 | Job2: $state2 | Job3: $state3"
#     # Write-Host "$(Get-Date -Format 'HH:mm:ss') - Job2: $state2"

#     if ((IsJobCompleted -JobState $state1) -and (IsJobCompleted -JobState $state2) -and `
#             (IsJobCompleted -JobState $state3)) {
#         Write-Host "All connection creation jobs completed."
#         break
#     }

#     Start-Sleep -Seconds 10
# }

$endTime = Get-Date
$duration = $endTime - $startTime

Write-Host "Script started at: $startTime"
Write-Host "Script ended at:   $endTime"
Write-Host "Total time taken:  $($duration.ToString())"
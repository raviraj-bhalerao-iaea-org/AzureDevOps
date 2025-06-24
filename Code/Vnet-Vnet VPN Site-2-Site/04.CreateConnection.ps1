Clear-Host
$scriptPath = Split-Path -Parent $PSCommandPath
. "$scriptPath\..\Common\CreateVng.ps1"


$startTime = Get-Date
Write-Host "Script started at: $startTime"

#Variables
$location1 = "WestEurope"
$location2 = "CentralIndia"
$location3 = "EastUs"


$location1Tag = "West-Europe"
$location2Tag = "Central-India"
$location3Tag = "East-Us"

$rg1 = "AzureTryOuts-$Location1Tag"
$rg2 = "AzureTryOuts-$Location2Tag"
$rg3 = "AzureTryOuts-$Location3Tag"

$results1 = New-Vng-Connection -Location1 $location1 -Location2 $location2 `
    -Location1Tag $location1Tag -Location2Tag $location2Tag 

$results2 = New-Vng-Connection -Location1 $location2 -Location2 $location3 `
    -Location1Tag $location2Tag -Location2Tag $location3Tag 

Wait-ForJobs -Jobs ($results1 + $results2)

# ($job1, $job2) = $results1
# ($job3, $job4) = $results2

# while ($true) {
#     $state1 = (Get-Job -Id $job1.Id).State
#     $state2 = (Get-Job -Id $job2.Id).State
#     $state3 = (Get-Job -Id $job3.Id).State
#     $state4 = (Get-Job -Id $job4.Id).State

#     Write-Host "$(Get-Date -Format 'HH:mm:ss') - Job1: $state1 | Job2: $state2 | Job3: $state3 | Job4: $state4"
#     # Write-Host "$(Get-Date -Format 'HH:mm:ss') - Job2: $state2"

#     if ((IsJobCompleted -JobState $state1) -and (IsJobCompleted -JobState $state2) -and `
#             (IsJobCompleted -JobState $state3) -and (IsJobCompleted -JobState $state4)) {
#         Write-Host "All connection creation jobs completed."
#         break
#     }
#     if (IsJobCompleted($state1) -and IsJobCompleted($state2) -and `
#             IsJobCompleted($state3) -and IsJobCompleted($state4)) {
#         Write-Host "All connection creation jobs completed."
#         break
#     }

#     Start-Sleep -Seconds 10
# }


# Wait for both connections
Wait-For-Connection -ResourceGroupName $rg1 -ConnectionName "$location1Tag-2-$location2Tag"

Wait-For-Connection -ResourceGroupName $rg2 -ConnectionName "$location2Tag-2-$location3Tag"

Wait-For-Connection -ResourceGroupName $rg2 -ConnectionName "$location2Tag-2-$location1Tag"

Wait-For-Connection -ResourceGroupName $rg3 -ConnectionName "$location3Tag-2-$location2Tag"

$endTime = Get-Date
$duration = $endTime - $startTime

Write-Host "Script started at: $startTime"
Write-Host "Script ended at:   $endTime"
Write-Host "Total time taken:  $($duration.ToString())"
# Import-Module Az.Accounts
$username = "r.bhalerao@iaea.org"
$password = ConvertTo-SecureString "ShreeRamMar2020" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential($username, $password)
$tenateId = "a2f21493-a4d1-4b7f-ad07-819c824f5c4a"
Connect-AzAccount -Credential $cred #-Tenant $tenateId
# [AppDomain]::CurrentDomain.GetAssemblies() | Where-Object { $_.FullName -match "Azure|Az" } | Select FullName, Location
$ExecutionContext.SessionState.LanguageMode

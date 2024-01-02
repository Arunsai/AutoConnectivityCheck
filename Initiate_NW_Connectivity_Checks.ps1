$Script = Read-Host -Prompt 'Specify the script to run:'
$Comp = Read-Host -Prompt 'Specify the Target Host wsapp15263:'
$DestFile = $Comp+"_Telnet_Result.csv"
$User = whoami
Invoke-Command -ComputerName $Comp -FilePath .\$Script.ps1
$Session = New-PSSession -ComputerName $Comp -Credential $User
Copy-Item "C:\Users\$env:username\Documents\Telnet_Result.csv" -Destination $DestFile -FromSession $Session
Write-Host "Copied the results to this host.";

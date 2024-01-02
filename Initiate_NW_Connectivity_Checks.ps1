$SuccessParams = @{ NoNewLine = $true; ForegroundColor = 'Green' }
$FailedParams = @{ NoNewLine = $true; ForegroundColor = 'Red' }
$AllHosts = @((("wsapp15237","wsapp15260"),("wsapp15238","wsapp15261"),("wsapp15239","wsapp15262")),(("wsapp15240","wsapp15263"),("wsapp15241","wsapp15264"),("wsapp15242","wsapp15265")),(("psmpEDN1","psmpEDN2"),("psmpCMN1","psmpCMN2"),("psmpOPNET1","psmpOPNET2")))

$AllHosts = @((("wsapp15260","wsapp15263"),("wsapp15238","wsapp15261"),("wsapp15239","wsapp15262")),(("wsapp15240","wsapp15263"),("wsapp15241","wsapp15264"),("wsapp15242","wsapp15265")),(("psmpEDN1","psmpEDN2"),("psmpCMN1","psmpCMN2"),("psmpOPNET1","psmpOPNET2")))

$ComponentInputValidation = {
    try
    {
        $FromInput = [int](Read-Host -Prompt 'Specify the Component number:')

        if ($FromInput -le 0) {
            Write-Host @FailedParams "Your input has to be a number greater than 0!"
            & $ComponentInputValidation
        }
        elseif ($FromInput -ge 4) {
            Write-Host @FailedParams "Your input has to be a number in above options!"
            & $ComponentInputValidation
        }
        else {
            $FromInput
        }
    }
    catch
    {
        Write-Host @FailedParams "Your input has to be a number."
        & $ComponentInputValidation
    }
}

$NetworkInputValidation = {
    try
    {
        $FromInput = [int](Read-Host -Prompt 'Specify the Network number:')

        if ($FromInput -le 0) {
            Write-Host @FailedParams "Your input has to be a number greater than 0!"
            & $NetworkInputValidation
        }
        elseif ($FromInput -ge 4) {
            Write-Host @FailedParams "Your input has to be a number in above options!"
            & $NetworkInputValidation
        }
        else {
            $FromInput
        }
    }
    catch
    {
        Write-Host @FailedParams "Your input has to be a number."
        & $NetworkInputValidation
    }
}

Write-Host "Select the Component`n1. CPM`n2. PSM`n3. PSMP";
$Target_Component = & $ComponentInputValidation
$Target_Component -=1

Write-Host "Select the Network`n1. EDN`n2. CMN`n3. OPNET";
$Target_Network = & $NetworkInputValidation
$Target_Network -=1

$Script = Read-Host -Prompt 'Specify the script to run:'

$User = whoami
$Creds = Get-Credential

$targets = $AllHosts[$Target_Component][$Target_Network]
if ($targets.count -le 0){
Write-Host @FailedParams "No Hosts detected with these options.. Exiting..";
exit
}
Write-Host "Running the script on $targets";

foreach ($Comp in $targets){
$DestFile = $Comp+"_Telnet_Result.csv"
Write-Host "Copying the input file to $Comp..";
$Session = New-PSSession -ComputerName $Comp -Credential $Creds
Copy-Item "Telnet_Input.csv" -Destination "C:\Users\$env:username\Documents\" -ToSession $Session
Write-Host "Executing script on $Comp..";
Invoke-Command -ComputerName $Comp -FilePath .\$Script.ps1
$Session = New-PSSession -ComputerName $Comp -Credential $Creds
Copy-Item "C:\Users\$env:username\Documents\Telnet_Result.csv" -Destination $DestFile -FromSession $Session
Write-Host "Copied the results from $Comp to this host.";
}
Write-Host @SuccessParams "Script execution completed..";

$TargetType = "Windows"
$TargetPort = "5985"
$Input_File = "Telnet_Input.csv"
$SuccessParams = @{ NoNewLine = $false; ForegroundColor = 'Green' }
$FailedParams = @{ NoNewLine = $false; ForegroundColor = 'Red' }
$ProgressParams = @{ NoNewLine = $true; ForegroundColor = 'Blue' }

#Declare CyberArk Component servers
$M_CPM_EDN = @("wsapp15260","wsapp15263")
#$M_CPM_EDN = @("wsapp15237","wsapp15260")
$M_CPM_CMN = @("wsapp15238","wsapp15261")
$CPM_OPNET = @("wsapp15239","wsapp15262")

$M_PSM_EDN = @("wsapp15240","wsapp15263")
$M_PSM_CMN = @("wsapp15241","wsapp15264")
$M_PSM_OPNET = @("wsapp15242","wsapp15265")

$M_PSMP_EDN = @("lxclpampsmpedn01","lxclpampsmpedn02")
#$M_PSMP_EDN = @("lxclpampsmpedn01","lxexpamnppsmpedn01")
$M_PSMP_CMN = @("lxclpampsmpcmn01","lxexpamnppsmpcmn01")
$M_PSMP_OPNET = @("lxclpamnppsmpopnet01","lxexpamnppsmpopnet01")

$P_CPM_EDN = @("wsapp15223","wsapp15249")
$P_CPM_CMN = @("wsapp15224","wsapp15250")
$P_CPM_OPNET = @("wsapp15225","wsapp15251")

$P_PSM_EDN = @("wsapp15226","wsapp15227","wsapp15252")
$P_PSM_CMN = @("wsapp15228","wsapp15229","wsapp15253")
$P_PSM_OPNET = @("wsapp15230","wsapp15231","wsapp15254")

$P_PSMP_EDN = @("lxclpampsmpedn01","lxclpampsmpedn02","lxexpampsmpedn01")
$P_PSMP_CMN = @("lxclpampsmpcmn01","lxclpampsmpcmn02","lxexpampsmpcmn01")
$P_PSMP_OPNET = @("lxclpampsmpopnet01","lxclpampsmpopnet02","lxexpampsmpopnet01")

#$AllHosts = @((("wsapp15237","wsapp15260"),("wsapp15238","wsapp15261"),("wsapp15239","wsapp15262")),(("wsapp15240","wsapp15263"),("wsapp15241","wsapp15264"),("wsapp15242","wsapp15265")),(("psmpEDN1","psmpEDN2"),("psmpCMN1","psmpCMN2"),("psmpOPNET1","psmpOPNET2")))
#$AllHosts = @((("wsapp15260","wsapp15263"),("wsapp15238","wsapp15261"),("wsapp15239","wsapp15262")),(("wsapp15240","wsapp15263"),("wsapp15241","wsapp15264"),("wsapp15242","wsapp15265")),(("lxclpampsmpedn01","lxclpampsmpedn02","lxexpampsmpedn01"),("psmpCMN1","psmpCMN2"),("psmpOPNET1","psmpOPNET2")))
#$AllHosts = @((("wsapp15230","wsapp15231"),("wsapp15238","wsapp15261"),("wsapp15239","wsapp15262")),(("wsapp15240","wsapp15263"),("wsapp15241","wsapp15264"),("wsapp15242","wsapp15265")),(("lxclpampsmpedn01","lxclpampsmpedn02","lxexpampsmpedn01"),("psmpCMN1","psmpCMN2"),("psmpOPNET1","psmpOPNET2")))

$All_M_Hosts = @(($M_CPM_EDN,$M_CPM_CMN,$M_CPM_OPNET),($M_PSM_EDN,$M_PSM_CMN,$M_PSM_OPNET),($M_PSMP_EDN,$M_PSMP_CMN,$M_PSMP_OPNET))
$All_P_Hosts = @(($P_CPM_EDN,$P_CPM_CMN,$P_CPM_OPNET),($P_PSM_EDN,$P_PSM_CMN,$P_PSM_OPNET),($P_PSMP_EDN,$P_PSMP_CMN,$P_PSMP_OPNET))

$AllHosts = @($All_M_Hosts,$All_P_Hosts)

#Input Validation section
$EnvInputValidation = {
    try
    {
        $FromInput = [int](Read-Host -Prompt 'Specify the Environment number:')

        if ($FromInput -le 0) {
            Write-Host @FailedParams "Your input has to be a number greater than 0!"
            & $EnvInputValidation
        }
        elseif ($FromInput -ge 3) {
            Write-Host @FailedParams "Your input has to be a number in above options!"
            & $EnvInputValidation
        }
        else {
            $FromInput
        }
    }
    catch
    {
        Write-Host @FailedParams "Your input has to be a number."
        & $EnvInputValidation
    }
}

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

#End Input Validation section

#Dynamically prompt for Inputs that are required to run the script:
Write-Host "Select the environment`n1. Model`n2. Production";
$Env = & $EnvInputValidation
$Env -=1

Write-Host "Select the Component`n1. CPM`n2. PSM`n3. PSMP";
$Target_Component = & $ComponentInputValidation
if($Target_Component -eq 3){
	$TargetType = "Unix"
	$TargetPort = "22"
}
else{
	$TargetType = "Windows"
	$TargetPort = "5985"
}
$Target_Component -=1

Write-Host "Select the Network`n1. EDN`n2. CMN`n3. OPNET";
$Target_Network = & $NetworkInputValidation
$Target_Network -=1

$Script = Read-Host -Prompt 'Specify the script to run:'
#$Script = "check_connectivity.sh"
#Input gathhering completed

#Retrieve the component servers based on the inputs:
$targets = $AllHosts[$Env][$Target_Component][$Target_Network]

#Display selected hosts based on the inputs provided
if ($targets.count -le 0){
	Write-Host @FailedParams "No Hosts detected with these options.. Exiting..";
exit
}
else {
	Write-Host @SuccessParams "Selected component servers are: $targets ";
}

if($TargetType -eq "Unix"){
$UnixUser = Read-Host -Prompt 'Provide the Unix user name:'

foreach ($Comp in $targets){
$connection = Test-NetConnection -ComputerName $Comp -Port $TargetPort

if ($connection.TcpTestSucceeded) {
	Write-Host "Connectivity exists to $Comp over Port $TargetPort. Creating a session to the host $Comp";
	$DestFile = $Comp+"_Telnet_Result.csv"
	$Session = New-PSSession -HostName $Comp -UserName $UnixUser

	#Copy the files to the remote host
	Write-Host @FailedParams "Copying the script to $Comp..";
	Copy-Item $Input_File -Destination "\home\$UnixUser\" -ToSession $Session
	Copy-Item $Script -Destination "\home\$UnixUser\" -ToSession $Session
	Write-Host @SuccessParams "COMPLETED";

	Write-Host "ENTERING THE SESSION to $Comp..";
	Enter-PSSession $Session
	Write-Host @SuccessParams "Inside the session of $Comp..";
	Invoke-Command -Session $Session {chmod +x check_connectivity.sh}
	Invoke-Command -Session $Session {./check_connectivity.sh}
	Exit-PSSession
	Copy-Item "\home\$UnixUser\Telnet_Result.csv" -Destination ".\$DestFile" -FromSession $Session
	Write-Host @SuccessParams "Successfully copied the results from $Comp";
	Enter-PSSession $Session
	Invoke-Command -Session $Session {rm -f check_connectivity.sh Telnet_Input.csv Telnet_Result.csv}
	Exit-PSSession

	#copy the hosts.txt file
	#scp hosts.txt check_connectivity.sh $UnixUser@$Comp:/home/$UnixUser/
	#login to server
	#ssh $UnixUser@$Comp
	#chmod 755 check_connectivity.sh hosts.txt
	#sh check_connectivity.sh
	#exit
	#copy the connectivity_output.txt to server
	#scp $UnixUser@$Comp:/home/$UnixUser/connectivity_output.txt.
}
else {
	Write-Host @FailedParams "No Connectivity to $Comp over Port $TargetPort. Skipping the Checks from the host $Comp";
}

}
}

else {
$User = whoami
$Creds = Get-Credential

Write-Host "Running the script on $targets";
foreach ($Comp in $targets){
$connection = Test-NetConnection -ComputerName $Comp -Port $TargetPort

if ($connection.TcpTestSucceeded) {
	Write-Host "Connectivity exists to $Comp over Port $TargetPort. Creating a session to the host $Comp";
	$DestFile = $Comp+"_Telnet_Result.csv"
	$Session = New-PSSession -ComputerName $Comp -Credential $Creds
	Write-Host "Copying the input file to $Comp..";
	Copy-Item $Input_File -Destination "C:\Users\$env:username\Documents\" -ToSession $Session
	Copy-Item $Script -Destination "C:\Users\$env:username\Documents\" -ToSession $Session
	Write-Host "Executing script on $Comp..";
	Invoke-Command -ComputerName $Comp -FilePath .\$Script
	Copy-Item "C:\Users\$env:username\Documents\Telnet_Result.csv" -Destination $DestFile -FromSession $Session
	Write-Host "Copied the results from $Comp to this host.";
}
else {
	Write-Host @FailedParams "No Connectivity to $Comp over Port $TargetPort. Skipping the Checks from the host $Comp";
}
}
}
Write-Host @SuccessParams "Script execution completed..";

#Capabilities to Mature
#1. Improve the authenticaton experience for Unix
#2. Import all hosts from a CSV file and read it into a variable
#3. Add more capabilities to the script like certificate removals, certificate expiry checks, software installations, etc.
#4. Flatten a multi dimentional array using the instructions in https://stackoverflow.com/questions/711991/flatten-array-in-powershell

$TargetType = "Windows"
$TargetPort = "5985"
$Failures = 0

$Input_File = "Telnet_Input.csv"  #<---InputFile is harded coded to "Telnet_Input.csv" to ealisy cleanup the files from component servers after running the scripts.
$SuccessParams = @{ NoNewLine = $false; ForegroundColor = 'Green' }
$FailedParams = @{ NoNewLine = $false; ForegroundColor = 'Red' }
$ProgressParams = @{ NoNewLine = $true; ForegroundColor = 'Blue' }
$QueryParams = @{ NoNewLine = $false; ForegroundColor = 'Yellow' }


$Computers = Import-csv "export.csv"
$Hostname = ""
$count = $x = $y = $z = 0

#Declare CyberArk Component servers
$M_CPM_EDN = @()
$M_CPM_CMN = @()
$M_CPM_OPNET = @()

$M_PSM_EDN = @()
$M_PSM_CMN = @()
$M_PSM_OPNET = @()

$M_PSMP_EDN = @()
$M_PSMP_CMN = @()
$M_PSMP_OPNET = @()

$P_CPM_EDN = @()
$P_CPM_CMN = @()
$P_CPM_OPNET = @()

$P_PSM_EDN = @()
$P_PSM_CMN = @()
$P_PSM_OPNET = @()

$P_PSMP_EDN = @()
$P_PSMP_CMN = @()
$P_PSMP_OPNET = @()

$All_M_Hosts = @(($M_CPM_EDN,$M_CPM_CMN,$M_CPM_OPNET),($M_PSM_EDN,$M_PSM_CMN,$M_PSM_OPNET),($M_PSMP_EDN,$M_PSMP_CMN,$M_PSMP_OPNET))
$All_P_Hosts = @(($P_CPM_EDN,$P_CPM_CMN,$P_CPM_OPNET),($P_PSM_EDN,$P_PSM_CMN,$P_PSM_OPNET),($P_PSMP_EDN,$P_PSMP_CMN,$P_PSMP_OPNET))
$AllHosts = @($All_M_Hosts,$All_P_Hosts)


foreach ($computer in $Computers)
{
    $x = $y = $z = -1
    #Write-Host("$x - $y - $z")
	if($computer.Environment -eq "Model"){
		$x=0
	}
	if($computer.Environment -eq "Production"){
		$x=1
	}

	if($computer.Component -eq "CPM"){
		$y=0
	}
	if($computer.Component -eq "PSM"){
		$y=1
	}
	if($computer.Component -eq "PSMP"){
		$y=2
	}

	if($computer.Network -eq "EDN"){
		$z=0
	}
	if($computer.Network -eq "CMN"){
		$z=1
	}
	if($computer.Network -eq "OPNET"){
		$z=2
	}

    $count += 1
    if (($x -ge 0) -and ($y -ge 0) -and ($z -ge 0)){
        $Hostname = $computer.Hostname
        $AllHosts[$x][$y][$z] += $Hostname
    }
#    if (($x -eq 1) -and ($y -eq 2) -and ($z -eq 2)){
#        $Hostname = $computer.Hostname
#        Write-Output "$x-$y-$z ..$Hostname"
#    }
}
#$targets = $AllHosts[1][2][2]
#Write-Output "Prod PSMP OPNET: $targets"
#exit

# Functions section
function PerformDnsLookup {
    param (
        [string]$hostname
    )

    try {
        $ipAddress = [System.Net.Dns]::GetHostAddresses($hostname)[0].IPAddressToString
        # Write-Output "DNS Lookup successful. IP address: $ipAddress"
        $ipAddress
    } catch {
        Write-Output "$thisHost,$target,DNSFAIL,,"
        exit 1
    }
}

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
Write-Host @QueryParams "Select the environment`n1. Model`n2. Production";
$Env = & $EnvInputValidation
$Env -=1

if($Env -eq 0){
$Domain="TEST-ACCOUNT-01\"
}

Write-Host @QueryParams "Select the Component`n1. CPM`n2. PSM`n3. PSMP";
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

Write-Host @QueryParams "Select the Network`n1. EDN`n2. CMN`n3. OPNET";
$Target_Network = & $NetworkInputValidation
$Target_Network -=1

$Script = Read-Host -Prompt 'Specify the script to run:'

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

if ($Comp -as [ipaddress]) {
    $ipAddress = $Comp
} else {
    $ipAddress = PerformDnsLookup -hostname $Comp
}

$connection = Test-NetConnection -ComputerName $ipAddress -Port $TargetPort

if ($connection.TcpTestSucceeded) {
	Write-Host "Connectivity exists to $Comp over Port $TargetPort. Creating a session to the host $Comp";
	$DestFile = $Comp+"_Telnet_Result.csv"
	$Session = New-PSSession -HostName $ipAddress -UserName $UnixUser

	#Copy the files to the remote host
	Write-Host @FailedParams "Copying the script to $Comp..";
	Copy-Item $Input_File -Destination "\home\$UnixUser\" -ToSession $Session
	Copy-Item $Script -Destination "\home\$UnixUser\" -ToSession $Session
	Write-Host @SuccessParams "COMPLETED";

	Write-Host "ENTERING THE SESSION to $Comp..";
	Enter-PSSession $Session
	#Write-Host @SuccessParams "Inside the session of $Comp..";
	#Invoke-Command -Session $Session {ls -l}
	Invoke-Command -Session $Session {chmod +x Telnet_Unix_connectivity.sh}
	Invoke-Command -Session $Session {./Telnet_Unix_connectivity.sh}
	Exit-PSSession
	Copy-Item "\home\$UnixUser\Telnet_Result.csv" -Destination ".\$DestFile" -FromSession $Session
	Write-Host @SuccessParams "Successfully copied the results from $Comp";
	Enter-PSSession $Session
	Invoke-Command -Session $Session {rm -f Telnet_Unix_connectivity.sh Telnet_Input.csv Telnet_Result.csv}
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
    $Failures += 1
}

}
}

else {
#$User = whoami
$Creds = Get-Credential

Write-Host "Running the script on $targets";
foreach ($Comp in $targets){

if ($Comp -as [ipaddress]) {
    $ipAddress = $Comp
} else {
    $ipAddress = PerformDnsLookup -hostname $Comp
}


$connection = Test-NetConnection -ComputerName $ipAddress -Port $TargetPort

if ($connection.TcpTestSucceeded) {
	Write-Host "Connectivity exists to $Comp over Port $TargetPort. Creating a session to the host $Comp";
	$DestFile = $Comp+"_Telnet_Result.csv"
    #Set-Item WSMan:\\localhost\client\TrustedHosts -Value $ipAddress -Concatenate -Force
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
    $Failures +=1
}
}
}
if ($Failures -gt 0){
Write-Host @FailedParams "Script execution completed..with errors";
}
else {
Write-Host @SuccessParams "Script execution completed..successfully";
}

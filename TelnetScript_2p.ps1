$SourceFile="Telnet_Input.csv"
$ResultFile="Telnet_Result.csv"
$Computers = Import-csv $SourceFile

$SuccessParams = @{ NoNewLine = $false; ForegroundColor = 'Green' }
$FailedParams = @{ NoNewLine = $false; ForegroundColor = 'Red' }
$ProgressParams = @{ NoNewLine = $true; ForegroundColor = 'Blue' }
$QueryParams = @{ NoNewLine = $false; ForegroundColor = 'Yellow' }

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
        #exit 1
    }
}


function TestTcpConnection {
    param (
        [string]$ipAddress,
        [int]$port,
        [int]$timeoutMilliseconds
    )

    
    $tcpClient = New-Object System.Net.Sockets.TcpClient
    $connectTask = $tcpClient.ConnectAsync($ipAddress, $port)
        
    # Wait for the connection to complete or timeout
    if ($connectTask.Wait($timeoutMilliseconds)) {
        $tcpClient.Close()
        Write-Host @SuccessParams "Success"
    } else {
        $tcpClient.Close()
        Write-Host @FailedParams "FAIL"
    }
}


foreach ($computer in $Computers)
{
  $target = $computer.Computer
  $port = $computer.Port1

  if ($computer.Computer -as [ipaddress]) {
    $ipAddress = $computer.Computer
} else {
    $ipAddress = PerformDnsLookup -hostname $target
}

  Write-Host @ProgressParams "Connecting to $target on port $port...."
  try
  {
    $testResult = TestTcpConnection -ipAddress $ipAddress -port $Port -timeoutMilliseconds 100
    #$socket = New-Object System.Net.Sockets.TcpClient($ipAddress, $port)
    $computer.Result1="Success"
  }
  catch [Exception]
  {
    Write-Host $_.Exception.GetType().FullName
    Write-Host $_.Exception.Message
    $computer.Result1="Failed"
  }

  $port = $computer.Port2
  Write-Host @ProgressParams "Connecting to $target on port $port...."
  try
  {
    $testResult = TestTcpConnection -ipAddress $ipAddress -port $Port -timeoutMilliseconds 100
    #$socket = New-Object System.Net.Sockets.TcpClient($ipAddress, $port)
    $computer.Result2="Success"
  }
  catch [Exception]
  {
    Write-Host $_.Exception.GetType().FullName
    Write-Host $_.Exception.Message
    $computer.Result2="Failed"
  }
 

}
Write-host "Done"
$Computers|export-csv $ResultFile

# AutoConnectivityCheck
The PowerShell script to programmatically copy the input file to several servers, initiate connectivity checks from them and copy the results back to a host computer

Prerequisites:
This powershell scrit runs only on version 7.4 and higher. Install it on the jumpserver

Things to Know:
1. The capability to run the connectivity tests from Unix hosts needs further improvement. With the current capability, there is a limitation to enter the password when iterating over each component.
2. The term "Input_file.csv" refers to the csv file with actual target systems and their ports.
3. The term "Script" refers to the powershell/bash program to run from each component server. There are several powershell scripts depends on your requirement(TelnetScript_1p, TelnetScript_2p, TelnetScript_3p) and only one bash script named "Telnet_Unix_connectivity".
4. The file "Hosts.csv" refers to the CyberArk inventory in a csv file. This .csv file should have a minimum of 4 fields in the sheet "Environment", "Component", "Network", "Hostname".

**Input validation**:
Select the environment: 
  Acceptable Values: 1,2

Select the Component: 
  Acceptable Values: 1,2,3

Select the Network: 
  Acceptable Values: 1,2,3

Specify the script to run
  Acceptable Values:
    TelnetScript_1p.ps1
    TelnetScript_2p.ps1
    TelnetScript_3p.ps1
    Telnet_Unix_connectivity.sh

When Credentialos are prompted, provide your authentication to component server.

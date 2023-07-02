Start-Transcript 'C:\scriptlog.txt'
$ErrorActionPreference = 'SilentlyContinue'

New-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\Kerberos\Parameters -Name CloudKerberosTicketRetrievalEnabled -Value 1 -PropertyType DWord -Force

Stop-Transcript

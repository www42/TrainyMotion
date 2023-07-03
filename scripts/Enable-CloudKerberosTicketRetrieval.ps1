Start-Transcript 'C:\scriptlog.txt'
$ErrorActionPreference = 'SilentlyContinue'

# Enable Kerberos Ticket Retrieval from Azure AD
# https://learn.microsoft.com/en-us/azure/storage/files/storage-files-identity-auth-hybrid-identities-enable?tabs=azure-portal#configure-the-clients-to-retrieve-kerberos-tickets
New-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\Kerberos\Parameters -Name CloudKerberosTicketRetrievalEnabled -Value 1 -PropertyType DWord -Force

# Disable NLA (Network Level Authentication) for RDP connections
# https://lazywinadmin.com/2014/04/powershell-getset-network-level.html

# 0 - no NLA required
# 1 - NLA required
(Get-WmiObject -class "Win32_TSGeneralSetting" -Namespace root\cimv2\terminalservices -Filter "TerminalName='RDP-tcp'").SetUserAuthenticationRequired(0)

Stop-Transcript

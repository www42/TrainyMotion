# Connected to domain?
Get-AzureADDomain

# Import module
Import-Module -Name ./Tenant/Tm/Tm.psd1 -Force
Get-Module -Name Tm

# Users
Get-AzureADUser

# $DomainName = ((Get-AzureAdTenantDetail).VerifiedDomains)[0].Name
$DomainName = 'trainymotion.com'
Import-TmAzureADUser -DomainName $DomainName
# Remove-TmImportedAzureADUser -DomainName $DomainName

# Groups
Get-AzureADGroup
Import-TmAzureADGroup
# Remove-TmImportedAzureADGroup

# Group membership
$GroupName = "Quantum Electodynamics"
Get-AzureADGroupMember -ObjectId (Get-AzureADGroup -Filter "DisplayName eq '$GroupName'").ObjectId | ft DisplayName,UserType

# Third level groups
Add-TmAzureADGroupMember -MemberName "Peter Higgs"             -GroupName "Gauge Fields Symmetry"
Add-TmAzureADGroupMember -MemberName "François Englert"        -GroupName "Gauge Fields Symmetry"
Add-TmAzureADGroupMember -MemberName "Sheldon Glashow"         -GroupName "Electoweak Interactions"
Add-TmAzureADGroupMember -MemberName "Abdus Salam"             -GroupName "Electoweak Interactions"
Add-TmAzureADGroupMember -MemberName "Steven Weinberg"         -GroupName "Electoweak Interactions"
Add-TmAzureADGroupMember -MemberName "William Shockley"        -GroupName "Semiconductor Devices"
Add-TmAzureADGroupMember -MemberName "John Bardeen"            -GroupName "Semiconductor Devices"
Add-TmAzureADGroupMember -MemberName "Walter Brattain"         -GroupName "Semiconductor Devices"

# Second level groups
Add-TmAzureADGroupMember -MemberName "Ernst Mach"              -GroupName "General Relativity"
Add-TmAzureADGroupMember -MemberName "Erwin Schrödinger"       -GroupName "Quantum Mechanics"
Add-TmAzureADGroupMember -MemberName "Max Planck"              -GroupName "Quantum Mechanics"
Add-TmAzureADGroupMember -MemberName "Niels Bohr"              -GroupName "Quantum Mechanics"
Add-TmAzureADGroupMember -MemberName "Wolfgang Pauli"          -GroupName "Quantum Mechanics"
Add-TmAzureADGroupMember -MemberName "Max Born"                -GroupName "Quantum Mechanics"
Add-TmAzureADGroupMember -MemberName "Enrico Fermi"            -GroupName "Quantum Mechanics"
Add-TmAzureADGroupMember -MemberName "Johannes Stark"          -GroupName "Quantum Mechanics"
Add-TmAzureADGroupMember -MemberName "Eugene Wigner"           -GroupName "Quantum Mechanics"
Add-TmAzureADGroupMember -MemberName "Hans Bethe"              -GroupName "Quantum Mechanics"
Add-TmAzureADGroupMember -MemberName "Murray Gell-Mann"        -GroupName "Quantum Chromodynamics"
Add-TmAzureADGroupMember -MemberName "Julian Schwinger"        -GroupName "Quantum Electodynamics"
Add-TmAzureADGroupMember -MemberName "Gauge Fields Symmetry"   -GroupName "Quantum Electodynamics"
Add-TmAzureADGroupMember -MemberName "Electoweak Interactions" -GroupName "Quantum Electodynamics"
Add-TmAzureADGroupMember -MemberName "Semiconductor Devices"   -GroupName "Solid State Physics"

# First level groups
Add-TmAzureADGroupMember -MemberName "Albert Einstein"         -GroupName "Theoretical Physics"
Add-TmAzureADGroupMember -MemberName "Lev Landau"              -GroupName "Theoretical Physics"
Add-TmAzureADGroupMember -MemberName "Richard Feynman"         -GroupName "Theoretical Physics"
Add-TmAzureADGroupMember -MemberName "General Relativity"      -GroupName "Theoretical Physics"
Add-TmAzureADGroupMember -MemberName "Quantum Mechanics"       -GroupName "Theoretical Physics"
Add-TmAzureADGroupMember -MemberName "Quantum Chromodynamics"  -GroupName "Theoretical Physics"
Add-TmAzureADGroupMember -MemberName "Quantum Electodynamics"  -GroupName "Theoretical Physics"
Add-TmAzureADGroupMember -MemberName "Solid State Physics"     -GroupName "Theoretical Physics"
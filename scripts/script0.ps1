# Install NuGet in order to install modules
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force

# Install more DSC resources e.g. 'TimeZone'
Install-Module -Name ComputerManagementDsc -Force

# Create temp folder
# (Azure VM custom script extension cannot use user profile as destination, C:\Users\Student does not exist at that time)
New-Item -ItemType Directory -Path C:\temp -Force

# Download zoomit ver 4.50 (works with pen)
$source = 'https://github.com/www42/TrainyMotion/raw/master/tools/ZoomIt.exe'
$destination = 'C:\temp\ZoomIt.exe'
Invoke-WebRequest -Uri $source -OutFile $destination

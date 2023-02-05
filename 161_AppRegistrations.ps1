# App registration
az ad app list
az ad app list --query "length([*])"
az ad app list --query "[*].{displayName:displayName,appId:appId}" --output table
$DisplayName = 'fooApp'
az ad app list --query "[?displayName=='$DisplayName'].{displayName:displayName,appId:appId}" --output table
$AppId = az ad app list --query "[?displayName=='$DisplayName'].appId" --output tsv

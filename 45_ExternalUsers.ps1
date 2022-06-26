# https://docs.microsoft.com/de-de/azure/active-directory/external-identities/google-federation

$ClientID = '1004325268767-o5klnd8p98kd6dftnbpnlu555gplap59.apps.googleusercontent.com'
$ClientSecret = 'xxx'

New-AzureADMSIdentityProvider -Type Google -Name Google -ClientId $ClientID -ClientSecret $ClientSecret


# https://myapps.microsoft.com/trainymotion.com
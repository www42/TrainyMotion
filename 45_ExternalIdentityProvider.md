# Add Google as an identity provider for B2B

[Microsoft Docs](https://docs.microsoft.com/en-us/azure/active-directory/external-identities/google-federation)


## Create a Google App

Go to the Google app [Azure AD B2B](https://console.cloud.google.com/welcome?project=azure-ad-b2b-292013):

<img src="img/Google_App_AzureB2B.png" alt="Google App" width="800"/>


Ajust redirect URLs:

```powershell
Start-Process -FilePath https://console.cloud.google.com/apis/credentials/oauthclient/1004325268767-o5klnd8p98kd6dftnbpnlu555gplap59.apps.googleusercontent.com?project=azure-ad-b2b-292013
```

Tenant ID is
```powershell
Get-AzureADTenantDetail | % ObjectId
```

Initial Domain Name is 

```powershell
$DomainName = Get-AzureADDomain | ? IsInitial -EQ $true | % Name
$DomainName
```

<img src="img\Google_App_RedirectUri.png" alt="Redirect URL" width="800"/>


## Register new identity provider

```powershell
$ClientID = '1004325268767-o5klnd8p98kd6dftnbpnlu555gplap59.apps.googleusercontent.com'
$ClientSecret = 'xxx'

New-AzureADMSIdentityProvider -Type Google -Name Google -ClientId $ClientID -ClientSecret $ClientSecret

Get-AzureADMSIdentityProvider
```

## Test

Invite Max Liebermann 

```powershell
New-AzureADMSInvitation `
    -InvitedUserDisplayName "Max Liebermann" `
    -InvitedUserEmailAddress "maxliebermann5@gmail.com" `
    -SendInvitationMessage $true `
    -InviteRedirectUrl "http://myapps.microsoft.com"
```

Login to https://myapps.microsoft.com/trainymotion.com for the first time:

<img src="img/Login_via_Google-copy.png" alt="login" width="400"/>

<img src="img/Consent-copy.png" alt="consent" width="400"/>

## Login to Azure portal as guest user

Privat browser session:
```
Start-Process -FilePath https://portal.azure.com/@$DomainName
```
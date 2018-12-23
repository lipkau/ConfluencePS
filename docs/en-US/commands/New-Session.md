---
external help file: ConfluencePS-help.xml
layout: documentation
locale: en-US
Module Name: ConfluencePS
online version: https://atlassianps.org/docs/ConfluencePS/commands/New-Session/
permalink: /docs/ConfluencePS/commands/New-Session/
schema: 2.0.0
---

# New-Session

## SYNOPSIS

Authenticate with the Confluence server and store the session.

## SYNTAX

```powershell
New-ConfluenceSession [-ServerName] <String> [-Credential] <PSCredential>
 [[-Headers] <Hashtable>] [<CommonParameters>]
```

## DESCRIPTION

Store an authenticated session with the Confluence server.
This allows the user to use the ConfluencePS commands without having to provide
`-Credential` every time.
The session is only valid inside the current Powershell session.

## EXAMPLES

### Example 1

```powershell
New-ConfluenceSession -ServerName "myWiki" -Credential "john"
```

Stores a session for `john` in the connection for myWiki.

> By providing a String to `-Credential`, Powershell will open a dialog
> requesting the password for the credential.
> It is also possible to send a `PSCredential` object to `-Credential`.

### Example 2

```powershell
New-ConfluenceSession -ServerName "myWiki" -Credential "john"

Get-ConfluenceSpace -ServerName "myWiki"
```

Stores a session for `john` in the connection for myWiki and uses this session
to fetch all Spaces `john` has access to.

## PARAMETERS

### -ServerName

Name of the server registered in AtlassianPS.Configuration.

This parameter supports tab-completion.

> More information on how to authenticate in [about_ConfluencePS_Authentication](../../about/authentication.html)

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Credential

Confluence's credentials for authentication.

> More information on how to authenticate in [about_ConfluencePS_Authentication](../../about/authentication.html)

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Headers

Additional headers that should be used for the HTTP requests.

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: @{}
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: `-Debug`, `-ErrorAction`,
`-ErrorVariable`, `-InformationAction`, `-InformationVariable`, `-OutVariable`,
`-OutBuffer`, `-PipelineVariable`, `-Verbose`, `-WarningAction`, and
`-WarningVariable`.
For more information, see about_CommonParameters
(<http://go.microsoft.com/fwlink/?LinkID=113216>).

## INPUTS

### System.String

## OUTPUTS

## NOTES

## RELATED LINKS

[Connect-ConfluenceServer](../Connect-ConfluenceServer)

[about_ConfluencePS_Authentication](../../about/authentication.html)

[about_AtlassianPS.Configuration](../../../about_AtlassianPS.Configuration)

[AtlassianPS.Configuration\Add-AtlassianServerConfiguration](../../../AtlassianPS.Configuration/commands/Add-ServerConfiguration)

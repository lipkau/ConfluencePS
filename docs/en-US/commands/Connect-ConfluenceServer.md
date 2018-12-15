---
external help file: ConfluencePS-help.xml
layout: documentation
locale: en-US
Module Name: ConfluencePS
online version: https://atlassianps.org/docs/ConfluencePS/commands/Connect-ConfluenceServer/
permalink: /docs/ConfluencePS/commands/Connect-ConfluenceServer/
schema: 2.0.0
---

# Connect-ConfluenceServer

## SYNOPSIS

Establish a connection to a specific Confluence server.

## SYNTAX

```powershell
Connect-ConfluenceServer [-ServerName] <String> [[-Credential] <PSCredential>]
 [<CommonParameters>]
```

## DESCRIPTION

Establish a persistent connection to a Confluence server for the duration of the
Powershell session.
This connection will be used by all ConfluencePS commands unless different
values are explicitly used for `-ServerName`.

## EXAMPLES

### Example 1

```powershell
Add-AtlassianServerConfiguration -Name "myWiki" -Uri "https://wiki.contoso.com" -Type CONFLUENCE

Connect-ConfluenceServer -ServerName "myWiki"
```

Set the default server to be used by ConfluencePS commands to `myWiki`

### Example 2

```powershell
Connect-ConfluenceServer -ServerName "TestServer" -Credential "john"
```

Set the default server to be used by ConfluencePS commands to `myWiki` and
authenticate as `john`.

> By providing a String to `-Credential`, Powershell will open a dialog
> requesting the password for the credential.
> It is also possible to send a `PSCredential` object to `-Credential`.

## PARAMETERS

### -ServerName

Name of the server registered in AtlassianPS.Configuration.

This parameter supports tab-completion.

> More information on how to authenticate in [about_ConfluencePS_Authentication](../../about/authentication.html)

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
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
Position: 1
Default value: None
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

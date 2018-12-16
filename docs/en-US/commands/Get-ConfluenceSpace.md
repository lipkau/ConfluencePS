---
external help file: ConfluencePS-help.xml
layout: documentation
locale: en-US
Module Name: ConfluencePS
online version: https://atlassianps.org/docs/ConfluencePS/commands/Get-ConfluenceSpace/
permalink: /docs/ConfluencePS/commands/Get-ConfluenceSpace/
schema: 2.0.0
---

# Get-ConfluenceSpace

## SYNOPSIS

Retrieve a listing of spaces in your Confluence instance.

## SYNTAX

```powershell
Get-ConfluenceSpace [-Space <Space[]>] [-PageSize <UInt32>] [-ServerName <String>]
 [-Credential <PSCredential>] [-IncludeTotalCount] [-Skip <UInt64>] [-First <UInt64>]
 [<CommonParameters>]
```

## DESCRIPTION

Return all Confluence spaces, optionally filtering by Key.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-ConfluenceSpace
```

Display the info of all spaces on the server.
_Only spaces to which the current user has "read" permissions can be returned._

### EXAMPLE 2

```powershell
Get-ConfluenceSpace -Space Hoth, Naboo | Format-List *
```

Return only the space with key "HOTH" and "NABOO" (case-insensitive).

`Format-List *` displays all of the object's properties.

### EXAMPLE 3

```powershell
Get-ConfluenceSpace -ServerName "myWiki" -Credential $cred
```

List all spaces found on the instance by manually specifying a server and
authentication credentials. Provisioning of `-ServerName` and `-Credential` can
be avoided by using `Connect-ConfluenceServer`.

## PARAMETERS

### -Space

Identifies the Spaces to be looked up.

> This parameter takes Space objects as input.
> But a String can also be passed.
> This will be used as "Key" for the space.

```yaml
Type: Space[]
Parameter Sets: (All)
Aliases: Key

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -PageSize

Maximum number of results to fetch per call.

This setting can be tuned to get better performance according to the load on the server.

> Warning: too high of a PageSize can cause a timeout on the request.

```yaml
Type: UInt32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 25
Accept pipeline input: False
Accept wildcard characters: False
```

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

### -Skip

Controls how many objects will be skipped before starting output.

Defaults to 0.

```yaml
Type: UInt64
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -First

> NOTE: Not yet implemented.

Indicates how many items to return.

```yaml
Type: UInt64
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 18446744073709551615
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeTotalCount

> NOTE: Not yet implemented.

Causes an extra output of the total count at the beginning.

Note this is actually a uInt64, but with a custom string representation.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
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

### ConfluencePS.Space

## OUTPUTS

### ConfluencePS.Space

## NOTES

Piped output into other cmdlets is generally tested and supported.

## RELATED LINKS

[New-ConfluenceSpace](../New-ConfluenceSpace)

[Set-ConfluenceSpace](../Set-ConfluenceSpace)

[Rename-ConfluenceSpace](../Rename-ConfluenceSpace)

---
external help file: ConfluencePS-help.xml
layout: documentation
locale: en-US
Module Name: ConfluencePS
online version: https://atlassianps.org/docs/ConfluencePS/commands/Get-ChildPage/
permalink: /docs/ConfluencePS/commands/Get-ChildPage/
schema: 2.0.0
---
# Get-ChildPage

## SYNOPSIS

Retrieve the child pages of a given wiki page.

## SYNTAX

```powershell
Get-ConfluenceChildPage [-Page] <Page> [-Recurse] [-PageSize <UInt32>]
 [-ServerName <String>] [-Credential <PSCredential>] [-IncludeTotalCount]
 [-Skip <UInt64>] [-First <UInt64>] [<CommonParameters>]
```

## DESCRIPTION

Return all pages directly below the given page.

Optionally, the `-Recurse` parameter will return all child pages, no matter how nested.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-ConfluenceChildPage -Page 123456
Get-ConfluencePage -Page 123456 | Get-ConfluenceChildPage
```

Two different methods to return all pages directly below page 123456.
Both examples should return identical results.

### EXAMPLE 2

```powershell
Get-ConfluenceChildPage -Page 123456 -Recurse
```

Instead of returning only 123456's child pages,
return grandchildren, great-grandchildren, and so on.

## PARAMETERS

### -Page

Identifies the Page to be looked up.

> This parameter takes Page objects as input.
> But a String or Integer can also be passed.
> This will be used as "Id" for the Page.

```yaml
Type: Page
Parameter Sets: (All)
Aliases: ID

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Recurse

Get all child pages recursively

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
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

### -Skip

Controls how many things will be skipped before starting output.

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

### CommonParameters

This cmdlet supports the common parameters: `-Debug`, `-ErrorAction`,
`-ErrorVariable`, `-InformationAction`, `-InformationVariable`, `-OutVariable`,
`-OutBuffer`, `-PipelineVariable`, `-Verbose`, `-WarningAction`, and
`-WarningVariable`.
For more information, see about_CommonParameters
(<http://go.microsoft.com/fwlink/?LinkID=113216>).

## INPUTS

### AtlassianPS.ConfluencePS.Page

## OUTPUTS

### AtlassianPS.ConfluencePS.Page

## NOTES

## RELATED LINKS

[Get-ConfluencePage](../Get-ConfluencePage)

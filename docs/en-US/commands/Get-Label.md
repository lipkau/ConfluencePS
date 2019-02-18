---
external help file: ConfluencePS-help.xml
layout: documentation
locale: en-US
Module Name: ConfluencePS
online version: https://atlassianps.org/docs/ConfluencePS/commands/Get-Label/
permalink: /docs/ConfluencePS/commands/Get-Label/
schema: 2.0.0
---
# Get-Label

## SYNOPSIS

Retrieve all labels applied to the given object(s).

## SYNTAX

```powershell
Get-ConfluenceLabel -Content <Content[]> [-PageSize <UInt32>] [-ServerName <String>]
 [-Credential <PSCredential>] [-IncludeTotalCount] [-Skip <UInt64>] [-First <UInt64>]
 [<CommonParameters>]
```

## DESCRIPTION

Currently, this command only returns a label list from wiki pages.
It is intended to eventually support other content types as well.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-ConfluenceLabel -Page 123456
```

Returns all labels applied to wiki page 123456.

### EXAMPLE 2

```powershell
Get-ConfluencePage -Space HOTH -Label skywalker | Get-ConfluenceLabel
```

For all pages in HOTH with the "skywalker" label applied,
return the full list of labels found on each page.

## PARAMETERS

### -Content

Identifies the Content to be looked up.

> This parameter takes Content objects as input.
> But a String or Integer can also be passed.
> This will be used as "Id" for the Content.

```yaml
Type: Content[]
Parameter Sets: (All)
Aliases: ID

Required: True
Position: 0
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

### AtlassianPS.ConfluencePS.Attachment

### AtlassianPS.ConfluencePS.BlogPost

### AtlassianPS.ConfluencePS.Content

### AtlassianPS.ConfluencePS.Page

## OUTPUTS

### AtlassianPS.ConfluencePS.Attachment

### AtlassianPS.ConfluencePS.BlogPost

### AtlassianPS.ConfluencePS.Page

## NOTES

## RELATED LINKS

[Get-ConfluenceAttachment](../Get-ConfluenceAttachment)

[Get-ConfluenceBlogPost](../Get-ConfluenceBlogPost)

[Get-ConfluencePage](../Get-ConfluencePage)

[Add-ConfluenceLabel](../Add-ConfluenceLabel)

[Remove-ConfluenceLabel](../Remove-ConfluenceLabel)

---
external help file: ConfluencePS-help.xml
layout: documentation
locale: en-US
Module Name: ConfluencePS
online version: https://atlassianps.org/docs/ConfluencePS/commands/Get-ConfluencePage/
permalink: /docs/ConfluencePS/commands/Get-ConfluencePage/
schema: 2.0.0
---

# Get-ConfluencePage

## SYNOPSIS

Retrieve a listing of pages in your Confluence instance.

## SYNTAX

### byId (Default)

```powershell
Get-ConfluencePage -Page <Page[]> [-PageSize <UInt32>] [-ServerName <String>] [-Credential <PSCredential>]
 [-IncludeTotalCount] [-Skip <UInt64>] [-First <UInt64>] [<CommonParameters>]
```

### bySpace

```powershell
Get-ConfluencePage [-Title <String>] -Space <Space> [-PageSize <UInt32>] [-ServerName <String>]
 [-Credential <PSCredential>] [-IncludeTotalCount] [-Skip <UInt64>] [-First <UInt64>] [<CommonParameters>]
```

### byLabel

```powershell
Get-ConfluencePage [-Space <Space>] -Label <String[]> [-PageSize <UInt32>] [-ServerName <String>]
 [-Credential <PSCredential>] [-IncludeTotalCount] [-Skip <UInt64>] [-First <UInt64>] [<CommonParameters>]
```

### byQuery

```powershell
Get-ConfluencePage [-Query] <String> [-PageSize <UInt32>] [-ServerName <String>] [-Credential <PSCredential>]
 [-IncludeTotalCount] [-Skip <UInt64>] [-First <UInt64>] [<CommonParameters>]
```

## DESCRIPTION

Return Confluence pages, filtered by ID, Name, or Space.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-ConfluencePage -SpaceKey HOTH
Get-ConfluenceSpace -SpaceKey HOTH | Get-ConfluencePage
```

Two different methods to return all wiki pages in space "HOTH".
Both examples should return identical results.

### EXAMPLE 2

```powershell
Get-ConfluencePage -PageID 123456 | Format-List *
```

Returns the wiki page with ID 123456.
`Format-List *` displays all of the object's properties, including the full page body.

### EXAMPLE 3

```powershell
Get-ConfluencePage -Title 'luke*' -SpaceKey HOTH
```

Return all pages in HOTH whose names start with "luke" (case-insensitive).
Wildcards (*) can be inserted to support partial matching.

### EXAMPLE 4

```powershell
Get-ConfluencePage -Label 'skywalker'
```

Return all pages containing the label "skywalker" (case-insensitive).
Label text must match exactly; no wildcards are applied.

### EXAMPLE 5

```powershell
Get-ConfluencePage -Query "mention = jSmith and creator != jSmith"
```

Return all pages matching the query.

## PARAMETERS

### -Page

{{Fill Page Description}}

```yaml
Type: Page[]
Parameter Sets: byId
Aliases: ID

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Title

Filter results by page name (case-insensitive).

This supports wildcards (*) to allow for partial matching.

```yaml
Type: String
Parameter Sets: bySpace
Aliases: Name

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: True
```

### -Space

Filter results by space object(s), typically from the pipeline.

```yaml
Type: Space
Parameter Sets: bySpace
Aliases: Key

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: Space
Parameter Sets: byLabel
Aliases: Key

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Label

Filter results to only pages with the specified label(s).

```yaml
Type: String[]
Parameter Sets: byLabel
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Query

Use Confluences advanced search: [CQL](https://developer.atlassian.com/cloud/confluence/advanced-searching-using-cql/).

This cmdlet will always append a filter to only look for pages (`type=page`).

```yaml
Type: String
Parameter Sets: byQuery
Aliases:

Required: True
Position: 1
Default value: None
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

>NOTE: Not yet implemented.

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

{{Fill ServerName Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Credential

Confluence's credentials for authentication.
Value can be set persistently with Set-ConfluenceInfo.

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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### ConfluencePS.Page

## NOTES

Piped output into other cmdlets is generally tested and supported.

## RELATED LINKS

[https://github.com/AtlassianPS/ConfluencePS](https://github.com/AtlassianPS/ConfluencePS)

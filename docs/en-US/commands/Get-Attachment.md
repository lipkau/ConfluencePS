---
external help file: ConfluencePS-help.xml
layout: documentation
locale: en-US
Module Name: ConfluencePS
online version: https://atlassianps.org/docs/ConfluencePS/commands/Get-Attachment/
permalink: /docs/ConfluencePS/commands/Get-Attachment/
schema: 2.0.0
---
# Get-Attachment

## SYNOPSIS

Retrieve the child Attachments of a given wiki Page.

## SYNTAX

```powershell
Get-ConfluenceAttachment [-Page] <Page[]> [-FileNameFilter <String>]
 [-MediaTypeFilter <String>] [-PageSize <UInt32>] [-ServerName <String>]
 [-Credential <PSCredential>] [-IncludeTotalCount] [-Skip <UInt64>] [-First <UInt64>]
 [<CommonParameters>]
```

## DESCRIPTION

Return all Attachments directly below the given Page.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-ConfluenceAttachment -Page 123456
Get-ConfluencePage -Page 123456 | Get-ConfluenceAttachment
```

Two different methods to return all Attachments directly below Page 123456.
Both examples should return identical results.

### EXAMPLE 2

```powershell
Get-ConfluenceAttachment -Page 123456, 234567
Get-ConfluencePage -Page 123456, 234567 | Get-ConfluenceAttachment
```

Similar to the previous example, this shows two different methods to return the Attachments of multiple pages.
Both examples should return identical results.

### EXAMPLE 3

```powershell
Get-ConfluenceAttachment -Page 123456 -FileNameFilter "test.png"
```

Returns the Attachment called test.png from Page 123456 if it exists.

### EXAMPLE 4

```powershell
Get-ConfluenceAttachment -Page 123456 -MediaTypeFilter "image/png"
```

Returns any attachments of mime type image/png from Page 123456.

## PARAMETERS

### -Page

Return attachments for a list of page IDs.

```yaml
Type: Page[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -FileNameFilter

Filter results by filename (case sensitive).

Does not support wildcards (*).

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

### -MediaTypeFilter

Filter results by media type (case insensitive).

Does not support wildcards (*).

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

### AtlassianPS.ConfluencePS.Attachment

## NOTES

## RELATED LINKS

[Get-ConfluencePage](../Get-ConfluencePage)

[Add-ConfluenceAttachment](../Add-ConfluenceAttachment)

[Get-ConfluenceAttachmentFile](../Get-ConfluenceAttachmentFile)

[Remove-ConfluenceAttachment](../Remove-ConfluenceAttachment)

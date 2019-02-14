---
external help file: ConfluencePS-help.xml
layout: documentation
locale: en-US
Module Name: ConfluencePS
online version: https://atlassianps.org/docs/ConfluencePS/commands/Get-Comment/
permalink: /docs/ConfluencePS/commands/Get-Comment/
schema: 2.0.0
---
# Get-Comment

## SYNOPSIS

Retrieve Comments of a Content

## SYNTAX

```powershell
Get-ConfluenceComment [-Content] <Content[]> [[-ParentVersion] <UInt32>]
 [[-Location] <CommentLocation[]>] [-All] [[-Expand] <String>] [[-PageSize] <UInt32>]
 [[-ServerName] <String>] [[-Credential] <PSCredential>] [-IncludeTotalCount]
 [-Skip <UInt64>] [-First <UInt64>] [<CommonParameters>]
```

## DESCRIPTION

Returns the comments of a content

## EXAMPLES

### Example 1

```powershell
Get-ConfluenceComment -Content 123456
Get-ConfluencePage -Page 123456 | Get-ConfluenceComment
```

Two different methods to return all Comments of Content with ID 123456.
Both examples should return identical results.

### Example 2

```powershell

```

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

### -ParentVersion

The number of the version of the content to retrieve Comments for

```yaml
Type: UInt32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Location

The location of the comments.

Possible values are: "inline", "footer", "resolved".

You can define multiple location params.
The results will be the comments matched by any location.

```yaml
Type: CommentLocation[]
Parameter Sets: (All)
Aliases:
Accepted values: inline, footer, resolved

Required: False
Position: Named
Default value: @("inline", "footer", "resolved")
Accept pipeline input: False
Accept wildcard characters: False
```

### -All

Returns all comments regardless of the depth.

Without this parameter, the command will only return the "root" Comments.

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

### -Expand

A comma separated list of properties to expand on the children.

We can also specify some extensions such as `extensions.inlineProperties`
(for getting inline comment-specific properties) or `extensions.resolution`
for the resolution status of each comment in the results.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Extensions.inlineProperties,extensions.resolution,body.storage,version,history
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

### AtlassianPS.ConfluencePS.Attachment

### AtlassianPS.ConfluencePS.BlogPost

### AtlassianPS.ConfluencePS.Content

### AtlassianPS.ConfluencePS.Page

## OUTPUTS

### AtlassianPS.ConfluencePS.Comment

## NOTES

## RELATED LINKS

[Get-ConfluenceAttachment](../Get-ConfluenceAttachment)

[Get-ConfluenceBlogPost](../Get-ConfluenceBlogPost)

[Get-ConfluencePage](../Get-ConfluencePage)

[Add-ConfluenceComment](../Add-ConfluenceComment)

[Remove-ConfluenceComment](../Remove-ConfluenceComment)

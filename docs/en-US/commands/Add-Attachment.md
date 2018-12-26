---
external help file: ConfluencePS-help.xml
layout: documentation
locale: en-US
Module Name: ConfluencePS
online version: https://atlassianps.org/docs/ConfluencePS/commands/Add-Attachment/
permalink: /docs/ConfluencePS/commands/Add-Attachment/
schema: 2.0.0
---
# Add-Attachment

## SYNOPSIS

Add a new attachment to an existing Confluence Content.

## SYNTAX

```powershell
Add-ConfluenceAttachment [-Content] <Content> [-Path <String[]>]
 [-ServerName <String>] [-Credential <PSCredential>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION

Add Attachments to a Confluence Content.
If the Attachment did not exist previously, it will be created.

This will not update an already existing Attachment.

> See `Set-ConfluenceAttachment` for updating a file.

## EXAMPLES

### EXAMPLE 1

```powershell
Add-ConfluenceAttachment -Content 123456 -FilePath test.png
```

Adds the Attachment test.png to the wiki Content with ID 123456.

### EXAMPLE 2

```powershell
Get-ConfluencePage -SpaceKey SRV |
    Add-ConfluenceAttachment -FilePath test.png -WhatIf
```

Simulates adding the file `test.png` to all pages in the space with key SRV.

## PARAMETERS

### -Content

The ID of the Content to which apply the Attachment to.
Accepts multiple IDs, including via pipeline input.

> This parameter takes Content objects as input.
> But a String or Integer can also be passed.
> This will be used as "Id" for the space.

```yaml
Type: Content
Parameter Sets: (All)
Aliases: ID

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Path

One or more files to be added.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: InFile, PSPath

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -WhatIf

Shows what would happen if the cmdlet runs.

The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm

Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
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

### System.String

### AtlassianPS.ConfluencePS.BlogPost

### AtlassianPS.ConfluencePS.Content

### AtlassianPS.ConfluencePS.Page

## OUTPUTS

### AtlassianPS.ConfluencePS.Attachment

## NOTES

## RELATED LINKS

[Get-ConfluenceBlogPost](../Get-ConfluenceBlogPost)

[Get-ConfluencePage](../Get-ConfluencePage)

[Get-ConfluenceAttachment](../Get-ConfluenceAttachment)

[Set-ConfluenceAttachment](../Set-ConfluenceAttachment)

[Remove-ConfluenceAttachment](../Remove-ConfluenceAttachment)

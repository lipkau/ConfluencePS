---
external help file: ConfluencePS-help.xml
layout: documentation
locale: en-US
Module Name: ConfluencePS
online version: https://atlassianps.org/docs/ConfluencePS/commands/Set-Label/
permalink: /docs/ConfluencePS/commands/Set-Label/
schema: 2.0.0
---

# Set-Label

## SYNOPSIS

Set the labels applied to existing Confluence content.

## SYNTAX

```
Set-ConfluenceLabel -ContentID <UInt32[]> -Label <Label[]> [-ServerName <String>] [-Credential <PSCredential>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

Sets desired labels for Confluence content.

All preexisting labels will be *removed* in the process.

> Note: Currently, Set-ConfluenceLabel only supports interacting with wiki pages.

## EXAMPLES

### EXAMPLE 1

```powershell
Set-ConfluenceLabel -PageID 123456 -Label 'a','b','c'
```

For existing wiki page with ID 123456, remove all labels, then add the three specified.

### EXAMPLE 2

```powershell
Get-ConfluencePage -SpaceKey 'ABC' | Set-Label -Label '123' -WhatIf
```

Would remove all labels and apply only the label "123" to all pages in the ABC space.
-WhatIf reports on simulated changes, but does not modifying anything.

## PARAMETERS

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

### -Label

Label names to add to the content.

```yaml
Type: Label[]
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
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

### -ContentID
{{Fill ContentID Description}}

```yaml
Type: UInt32[]
Parameter Sets: (All)
Aliases: ID, PageID, CommentID, BlogPostID, AttachmentID

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### ConfluencePS.ContentLabelSet

## NOTES

## RELATED LINKS

[https://github.com/AtlassianPS/ConfluencePS](https://github.com/AtlassianPS/ConfluencePS)

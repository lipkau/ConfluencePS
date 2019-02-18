---
external help file: ConfluencePS-help.xml
layout: documentation
locale: en-US
Module Name: ConfluencePS
online version: https://atlassianps.org/docs/ConfluencePS/commands/Remove-Attachment/
permalink: /docs/ConfluencePS/commands/Remove-Attachment/
schema: 2.0.0
---

# Remove-Attachment

## SYNOPSIS

Remove an Attachment.

## SYNTAX

```
Remove-ConfluenceAttachment -apiURi <Uri> -Credential <PSCredential> [-Attachment] <Attachment[]> [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

Remove Attachments from Confluence content.

Does accept multiple pages piped via Get-ConfluencePage.

> Untested against non-page content.

## EXAMPLES

### EXAMPLE 1

```powershell
$attachments = Get-ConfluenceAttachment -PageID 123456
Remove-ConfluenceAttachment -Attachment $attachments -Verbose -Confirm
```

Remove all attachment from page 12345
Verbose and Confirm flags both active; you will be prompted before deletion.

### EXAMPLE 2

```powershell
Get-ConfluenceAttachment -PageID 123456 | Remove-ConfluenceAttachment -WhatIf
```

Do trial deletion for all attachments on page with ID 123456, the WhatIf parameter prevents any modifications.

### EXAMPLE 3

```powershell
Get-ConfluenceAttachment -PageID 123456 | Remove-ConfluenceAttachment
```

Remove all Attachments on page 123456.

## PARAMETERS

### -apiURi

The URi of the API interface.
Value can be set persistently with Set-ConfluenceInfo.

```yaml
Type: Uri
Parameter Sets: (All)
Aliases:

Required: True
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

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Attachment

The Attachment(s) to remove.

```yaml
Type: Attachment[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

[https://github.com/AtlassianPS/ConfluencePS](https://github.com/AtlassianPS/ConfluencePS)

---
external help file: ConfluencePS-help.xml
layout: documentation
locale: en-US
Module Name: ConfluencePS
online version: https://atlassianps.org/docs/ConfluencePS/commands/Add-Label/
permalink: /docs/ConfluencePS/commands/Add-Label/
schema: 2.0.0
---
# Add-Label

## SYNOPSIS

Add a new global label to an existing Confluence Content.

## SYNTAX

```powershell
Add-ConfluenceLabel [-Content] <Content[]> [-Label <Label[]>] [-ServerName <String>]
 [-Credential <PSCredential>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

Assign labels to a Confluence Content.

If the label did not exist previously, it will be created.
Preexisting labels are not affected.

## EXAMPLES

### EXAMPLE 1

```powershell
Add-ConfluenceLabel -Content 123456 -Label alpha -Verbose
```

Apply the label alpha to the Content ID 123456.
-Verbose output provides extra technical details, if interested.

### EXAMPLE 2

```powershell
Get-ConfluencePage -Space SRV | Add-ConfluenceLabel -Label servers -WhatIf
```

Simulates applying the label "servers" to all pages in the space with key SRV.
-WhatIf provides PageIDs of pages that would have been affected.

### EXAMPLE 3

```powershell
Get-ConfluencePage -Space DEMO | Add-ConfluenceLabel -Label abc -Confirm
```

Applies the label "abc" to all pages in the space with key DEMO.
-Confirm prompts Yes/No for each page that would be affected.

## PARAMETERS

### -Content

The ID of the Content to which apply the Attachment to.
Accepts multiple IDs, including via pipeline input.

> This parameter takes Content objects as input.
> But a String or Integer can also be passed.
> This will be used as "Id" for the space.

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

### -Label

One or more labels to be added.
Currently only supports labels of prefix "global".

```yaml
Type: Label[]
Parameter Sets: (All)
Aliases: Labels

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

[Get-ConfluenceLabel](../Get-ConfluenceLabel)

[Get-ConfluencePage](../Get-ConfluencePage)

[Remove-ConfluenceLabel](../Remove-ConfluenceLabel)

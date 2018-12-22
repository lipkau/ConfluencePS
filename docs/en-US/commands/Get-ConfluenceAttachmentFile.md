---
external help file: ConfluencePS-help.xml
layout: documentation
locale: en-US
Module Name: ConfluencePS
online version: https://atlassianps.org/docs/ConfluencePS/commands/Get-ConfluenceAttachmentFile/
permalink: /docs/ConfluencePS/commands/Get-ConfluenceAttachmentFile/
schema: 2.0.0
---
# Get-ConfluenceAttachmentFile

## SYNOPSIS

Retrieves the binary Attachment for a given Attachment object.

## SYNTAX

```powershell
Get-ConfluenceAttachmentFile [-Attachment] <Attachment[]> [-Path <String>]
 [-ServerName <String>] [-Credential <PSCredential>] [<CommonParameters>]
```

## DESCRIPTION

Retrieves the binary Attachment for a given Attachment object.

As the files are stored in a location of the server that requires
authentication, this functions allows the download of the Attachment
in the same way as the rest of the module authenticates with the server.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-ConfluenceAttachment -Page 123456 | Get-ConfluenceAttachmentFile
```

Save any attachments of page 123456 to the current directory
with each filename constructed with the page ID and the attachment filename.

### EXAMPLE 2

```powershell
Get-ConfluenceAttachment -Page 123456 |
    Get-ConfluenceAttachmentFile -Path "c:\temp_dir"
```

Save any attachments of page 123456 to a specific directory
with each filename constructed with the page ID and the attachment filename.

## PARAMETERS

### -Attachment

Attachment object to download.

```yaml
Type: Attachment[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Path

Override the path used to save the files.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Use current directory
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

## OUTPUTS

### System.Boolean

## NOTES

## RELATED LINKS

[Get-ConfluenceAttachment](../Get-ConfluenceAttachment)

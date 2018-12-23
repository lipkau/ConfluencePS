---
external help file: ConfluencePS-help.xml
layout: documentation
locale: en-US
Module Name: ConfluencePS
online version: https://atlassianps.org/docs/ConfluencePS/commands/ConvertTo-StorageFormat/
permalink: /docs/ConfluencePS/commands/ConvertTo-StorageFormat/
schema: 2.0.0
---
# ConvertTo-StorageFormat

## SYNOPSIS

Convert a content in Confluence's markdown to Confluence's storage format.

## SYNTAX

```powershell
ConvertTo-ConfluenceStorageFormat [-Content] <String> [-ServerName <String>]
 [-Credential <PSCredential>] [<CommonParameters>]
```

## DESCRIPTION

To properly create/edit pages, content should be in the proper "XHTML-based" format.
Invokes a POST call to convert from a "wiki" representation, receiving a "storage" response.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------

```powershell
$Body = ConvertTo-ConfluenceStorageFormat -Content 'Hello world!'
```

Stores the returned value `<p>Hello world!</p>` in $Body for use
in New-ConfluencePage/Set-ConfluencePage/etc.

### -------------------------- EXAMPLE 2 --------------------------

```powershell
"||Name||Description||`n|Lorem|Ipsum Dolor Sum|" | ConvertTo-ConfluenceStorageFormat
```

Converts a string of a markdown representation of a table to a XHTML table.

## PARAMETERS

### -Content

A string (in plain text and/or wiki markup) to be converted to storage format.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
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

## OUTPUTS

### System.String

## NOTES

## RELATED LINKS

[ConvertTo-ConfluenceTable](../ConvertTo-ConfluenceTable)

[New-ConfluencePage](../New-ConfluencePage)

[Set-ConfluencePage](../Set-ConfluencePage)

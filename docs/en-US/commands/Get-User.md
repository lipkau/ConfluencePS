---
external help file: ConfluencePS-help.xml
online version: https://atlassianps.org/docs/ConfluencePS/commands/Get-User/
Module Name: ConfluencePS
locale: en-US
schema: 2.0.0
layout: documentation
permalink: /docs/ConfluencePS/commands/Get-User/
---
# Get-User

## SYNOPSIS

Retrieve a listing of Users in your Confluence instance.

## SYNTAX

### _self (Default)

```powershell
Get-ConfluenceUser -apiURi <Uri> -Credential <PSCredential>
```

### byUsername

```powershell
Get-ConfluenceUser -ApiURi <uri> -Credential <PSCredential> -Username <string> [-IncludeTotalCount] [-Skip <UInt64>] [-First <UInt64>]  [<CommonParameters>]
```

### byAccount

```powershell
Get-ConfluenceUser -apiURi <Uri> -Credential <PSCredential> -AccountId <String> [-IncludeTotalCount] [-Skip <UInt64>] [-First <UInt64>]  [<CommonParameters>]
```

### byUserKey

```powershell
Get-ConfluenceUser -ApiURi <uri> -Credential <PSCredential> -UserKey <string> [-IncludeTotalCount] [-Skip <UInt64>] [-First <UInt64>]  [<CommonParameters>]
```

## DESCRIPTION

Return Confluence Users, filtered by Username, or Key.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------

```powershell
Get-ConfluenceUser
```

Returns information about the user executing the command.

### -------------------------- EXAMPLE 2 --------------------------

```powershell
Get-ConfluenceUser -Username 'myUser'
```

Returns a user by name.

### -------------------------- EXAMPLE 3 --------------------------

```powershell
Get-ConfluenceUser -UserKey 123456
```

Returns the user with ID 123456.

### -------------------------- EXAMPLE 4 --------------------------

```powershell
Get-ConfluenceUser -AccountId "557058:15b2a9f1-1893-42b3-a6b5-ab899c878d00"
```

Description

-----------

Fetch the account information of the user searching by `AccountId`.

This is useful for cloud servers.

## PARAMETERS

### -ApiURi

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

### -UserKey

Filter results by User key.

```yaml
Type: string
Parameter Sets: byUserKey
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AccountId
The accountId of the user to be returned.
The accountId uniquely identifies a user across all Atlassian products.

This is only available for cloud instances.

```yaml
Type: String
Parameter Sets: byAccount
Aliases: Id

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Username

Filter results by Username (case-insensitive).

```yaml
Type: String
Parameter Sets: byUsername
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

### ConfluencePS.User

## NOTES

## RELATED LINKS

[https://github.com/AtlassianPS/ConfluencePS](https://github.com/AtlassianPS/ConfluencePS)

---
external help file: ConfluencePS-help.xml
online version: https://github.com/AtlassianPS/ConfluencePS/blob/master/docs/commands/Get-User.md
locale: en-US
schema: 2.0.0
layout: documentation
permalink: /docs/ConfluencePS/commands/Get-User/
---

# Get-User

## SYNOPSIS
Retrieve the information of a specific user.

## SYNTAX

### _self (Default)
```powershell
Get-ConfluenceUser -apiURi <Uri> -Credential <PSCredential>
```

### byName
```powershell
Get-ConfluenceUser -apiURi <Uri> -Credential <PSCredential> [-UserName] <String>
```

### byAccount
```powershell
Get-ConfluenceUser -apiURi <Uri> -Credential <PSCredential> -Key <String>
```

### byKey
```powershell
Get-ConfluenceUser -apiURi <Uri> -Credential <PSCredential> -AccountId <String>
```

## DESCRIPTION
Return the account information of a specific user.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```powershell
Get-ConfluenceUser
```

Description

-----------

Retrieve the account information of the current user.

### -------------------------- EXAMPLE 2 --------------------------
```powershell
Get-ConfluenceUser "admin"
Get-ConfluenceUser -UserName "admin"
```

Description

-----------

Two different ways on fetching the account information of the user "admin".

### -------------------------- EXAMPLE 3 --------------------------
```powershell
Get-ConfluenceUser -UserKey "ff8080815cb33ab7015cb33ae0ac0001"
```

Description

-----------

Fetch the account information of the user searching by `UserKey`.

### -------------------------- EXAMPLE 4 --------------------------
```powershell
Get-ConfluenceUser -AccountId "557058:15b2a9f1-1893-42b3-a6b5-ab899c878d00"
```

Description

-----------

Fetch the account information of the user searching by `AccountId`.

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

### -UserName
The username of the user to be returned.
The username uniquely identifies a user in a Confluence instance but can change
if the user is renamed.

```yaml
Type: String
Parameter Sets: byName
Aliases: Name

Required: True
Position: 1
Default value: None
Accept pipeline input: True
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

### -UserKey
The userKey of the user to be returned.
The key uniquely identifies a user in a Confluence instance and does not change.

```yaml
Type: String
Parameter Sets: byKey
Aliases: Key

Required: True
Position: 1
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

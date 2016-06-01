<# 
  _               _                                    
 / |_            (_)                                   
`| |-'_   _   __ __  _ .--.   .--.  _ .--..--.  .---.  
 | | [ \ [ \ [  |  |[ `.-. |/ .'`\ [ `.-. .-. |/ /__\\ 
 | |, \ \/\ \/ / | | | | | || \__. || | | | | || \__., 
 \__/  \__/\__/ [___|___||__]'.__.'[___||__||__]'.__.'                                         
 
/_____/_____/_____/_____/_____/_____/_____/_____/_____/

Script: twinomeSQLFunctions.ps1
Author: Matt Warburton
Date: 27/05/16
Comments: SQL functions
#>

#REQUIRES -Version 4.0
#REQUIRES -RunAsAdministrator

Function Get-Databases {
    <#
    .SYNOPSIS
        Gets all databases in an instance 
    .DESCRIPTION
        Get-Databases
    .PARAMETER instanceName
        Name of instance
    .EXAMPLE
        Get-Databases -instanceName "the instance"
    #>
    [CmdletBinding()] 
    param (
        [string]$instanceName
    )
      
    BEGIN {

        $ErrorActionPreference = 'Stop'    
    }
    
    PROCESS {

        $instance = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $instanceName
                
            if($instance) {
                try {
                    $databases = $instance.Databases.name
                    Write-Output $databases            
                }
        
                catch {
                    $error = $_
                    Write-Output "$($error.Exception.Message) - Line Number: $($error.InvocationInfo.ScriptLineNumber)"                   
                }
            }

            else {
                Write-Output "instance $instance doesnt exist"                
            }
    }
}

Function Add-SchemaDatabase {
    <#
    .SYNOPSIS
        Adds a schema to database 
    .DESCRIPTION
        Add-SchemaDatabase
    .PARAMETER instanceName
        Name of instance
    .PARAMETER databaseName
        Name of database
    .PARAMETER schemaName
        Name of schema
    .EXAMPLE
        Add-SchemaDatabase -instanceName "the instance" -databaseName "the database" -schemaName "the schema name"
    #>
    [CmdletBinding()] 
    param (
        [string]$instanceName, 
        [string]$databaseName,
        [string]$schemaName
    )
      
    BEGIN {

        $ErrorActionPreference = 'Stop'    
    }
    
    PROCESS {

        try{
            $instance = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $instanceName
            $database = $instance.Databases[$databaseName]
            $schema = $database.Schemas[$schemaName]

                if($database -and !$schema) {
                    try {
                        $newSchema = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Schema -ArgumentList $database, $schemaName
                        $newSchema.Owner = "dbo"
                        $newSchema.Create()
                        Write-Output "$schemaName created in $databaseName"   
                    }
        
                    catch {
                        $error = $_
                        Write-Output "$($error.Exception.Message) - Line Number: $($error.InvocationInfo.ScriptLineNumber)"                   
                    }
                }

                else {
                    Write-Output "database $databaseName doesnt exist in $instanceName or $schemaName already exits"                
                }
        }

        catch{
            $error = $_
            Write-Output "$($error.Exception.Message) - Line Number: $($error.InvocationInfo.ScriptLineNumber)"  
        }
    }
}

Function Add-SchemaOwnerDatabase {
    <#
    .SYNOPSIS
        Adds a schema owner
    .DESCRIPTION
        Add-SchemaOwnerDatabase
    .PARAMETER instanceName
        Name of instance
    .PARAMETER databaseName
        Name of database
    .PARAMETER schemaName
        Name of schema
    .PARAMETER ownerName
        Name of owner
    .EXAMPLE
        Add-SchemaOwnerDatabase -instanceName "the instance" -databaseName "the database" -schemaName "the schema name" -ownerName "the owner name"
    #>
    [CmdletBinding()] 
    param (
        [string]$instanceName, 
        [string]$databaseName,
        [string]$schemaName,
        [string]$ownerName
    )
      
    BEGIN {

        $ErrorActionPreference = 'Stop'    
    }
    
    PROCESS {

        try{
            $instance = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $instanceName
            $database = $instance.Databases[$databaseName]
            $schema = $database.Schemas[$schemaName]
            $user = $database.Users[$ownerName]

                if($database -and $user -and $schema) {
                    try {
                        $schema.Owner = $ownerName
                        $schema.Alter()
                        Write-Output "$schemaName owner set to $ownerName"   
                    }
        
                    catch {
                        $error = $_
                        Write-Output "$($error.Exception.Message) - Line Number: $($error.InvocationInfo.ScriptLineNumber)"                   
                    }
                }

                else {
                    Write-Output "database $databaseName, $schemaName, or $ownerName doesn't exist in $instanceName"                
                }
        }

        catch{
            $error = $_
            Write-Output "$($error.Exception.Message) - Line Number: $($error.InvocationInfo.ScriptLineNumber)"  
        }
    }
}

Function Add-LogInMapUserDatabase {
    <#
    .SYNOPSIS
        Adds a log-in & maps to user (database level permissions) 
    .DESCRIPTION
        Add-LogInMapUserDatabase
    .PARAMETER instanceName
        Name of instance
    .PARAMETER databaseName
        Name of database
    .PARAMETER logInName
        Log in name
    .PARAMETER userName
        User name
    .EXAMPLE
        Add-LogInMapUserDatabase -instanceName "the instance" -databaseName "the database" -defaultSchema "the default cchema" -logInName "the log in name" -userName "the user name"
    #>
    [CmdletBinding()] 
    param (
        [string]$instanceName, 
        [string]$databaseName,
        [string]$defaultSchema,
        [string]$logInName,
        [string]$userName
    )
      
    BEGIN {

        $ErrorActionPreference = 'Stop'    
    }
    
    PROCESS {

        try{
            $instance = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $instanceName
            $database = $instance.Databases[$databaseName]
            $user = $database.Users[$userName]

                if($database -and !$user) {
                    try {
                        $newUser = New-Object -TypeName Microsoft.SqlServer.Management.Smo.User -ArgumentList $database, $userName
                        $newUser.Login = $loginName
                        $newUser.DefaultSchema = $defaultSchema
                        $newUser.Create()
                        Write-Output "$userName created in $databaseName"   
                    }
        
                    catch {
                        $error = $_
                        Write-Output "$($error.Exception.Message) - Line Number: $($error.InvocationInfo.ScriptLineNumber)"                   
                    }
                }

                else {
                    Write-Output "database $databaseName doesnt exist in $instanceName or $userName already exits"                
                }
        }

        catch{
            $error = $_
            Write-Output "$($error.Exception.Message) - Line Number: $($error.InvocationInfo.ScriptLineNumber)"  
        }
    }
}

Function Remove-LogInMapUserDatabase {
    <#
    .SYNOPSIS
        Drop a user from database (database level permissions) 
    .DESCRIPTION
        Remove-LogInMapUserDatabase
    .PARAMETER instanceName
        Name of instance
    .PARAMETER databaseName
        Name of database
    .PARAMETER userName
        User name
    .EXAMPLE
        Remove-LogInMapUserDatabase -instanceName "the instance" -databaseName "the database" -userName "the user"
    #>
    [CmdletBinding()] 
    param (
        [string]$instanceName, 
        [string]$databaseName,
        [string]$userName
    )
      
    BEGIN {

        $ErrorActionPreference = 'Stop'    
    }
    
    PROCESS {

        try{
            $instance = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $instanceName
            $database = $instance.Databases[$databaseName]
            $user = $database.Users[$userName]

                if($database -and $user) {
                    try {
                        $user.Drop() 
                        Write-Output "$userName dropped from $databaseName"   
                    }
        
                    catch {
                        $error = $_
                        Write-Output "$($error.Exception.Message) - Line Number: $($error.InvocationInfo.ScriptLineNumber)"                   
                    }
                }

                else {
                    Write-Output "database $databaseName doesn't exist in $instanceName or $userName doesn't exits"                
                }
        }

        catch{
            $error = $_
            Write-Output "$($error.Exception.Message) - Line Number: $($error.InvocationInfo.ScriptLineNumber)"  
        }
    }
} 

Function Remove-SchemaDatabase {
    <#
    .SYNOPSIS
        Removes a schema 
    .DESCRIPTION
        Remove-SchemaDatabase
    .PARAMETER instanceName
        Name of instance
    .PARAMETER databaseName
        Name of database
    .PARAMETER schemaName
        Name of schema
    .EXAMPLE
        Remove-SchemaDatabase -instanceName "the instance" -databaseName "the database" -schemaName "the schema name"
    #>
    [CmdletBinding()] 
    param (
        [string]$instanceName, 
        [string]$databaseName,
        [string]$schemaName
    )
      
    BEGIN {

        $ErrorActionPreference = 'Stop'    
    }
    
    PROCESS {

        try{
            $instance = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $instanceName
            $database = $instance.Databases[$databaseName]
            $schema = $database.Schemas[$schemaName]

                if($database -and $schema) {
                    try {
                        $schema.Drop() 
                        Write-Output "$schemaName dropped from $databaseName"   
                    }
        
                    catch {
                        $error = $_
                        Write-Output "$($error.Exception.Message) - Line Number: $($error.InvocationInfo.ScriptLineNumber)"                   
                    }
                }

                else {
                    Write-Output "database $databaseName or $schemaName doesn't exist in $instanceName"                
                }
        }

        catch{
            $error = $_
            Write-Output "$($error.Exception.Message) - Line Number: $($error.InvocationInfo.ScriptLineNumber)"  
        }
    }
}   

Function Add-UserToRoleDatabase {
    <#
    .SYNOPSIS
        Adds a user to a role (database level permissions) 
    .DESCRIPTION
        Add-UserToRoleDatabase
    .PARAMETER instanceName
        Name of instance
    .PARAMETER databaseName
        Name of database
    .PARAMETER roleName
        Name of role
    .PARAMETER userName
        User name
    .EXAMPLE
        Add-UserToRoleDatabase -instanceName "the instance name" -databaseName "the database name" -roleName "the role name" -userName "the user name"
    #>
    [CmdletBinding()] 
    param (
        [string]$instanceName, 
        [string]$databaseName,
        [string]$roleName,
        [string]$userName
    )
      
    BEGIN {

        $ErrorActionPreference = 'Stop'    
    }
    
    PROCESS {

        try{
            $instance = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $instanceName
            $database = $instance.Databases[$databaseName]

                if($database) {
                    $role = $database.Roles[$roleName]
                    $user = $database.Users[$userName]

                        if($role -and $user){

                            try {
                                $role.AddMember($userName)
                                $role.Alter()
                                Write-Output "$userName added to $roleName in $databaseName"   
                            }
        
                            catch {
                                $error = $_
                                Write-Output "$($error.Exception.Message) - Line Number: $($error.InvocationInfo.ScriptLineNumber)"                   
                            }
                        }
                        else{
                            Write-Output "$roleName doesn't exist or $userName doesn't exist"  
                        }
                }

                else {
                    Write-Output "database $databaseName doesn't exist in $instanceName"                
                }
        }

        catch{
            $error = $_
            Write-Output "$($error.Exception.Message) - Line Number: $($error.InvocationInfo.ScriptLineNumber)"  
        }
    }
} 
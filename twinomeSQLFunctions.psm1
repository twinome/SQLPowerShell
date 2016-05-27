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
            $userExists = $database.Users[$userName]

                if($database -and !$userExists) {
                    try {
                        $user = New-Object -TypeName Microsoft.SqlServer.Management.Smo.User -ArgumentList $database, $userName
                        $user.Login = $loginName
                        $user.DefaultSchema = $defaultSchema
                        $user.Create()
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
                    Write-Output "database $databaseName doesnt exist in $instanceName"                
                }
        }

        catch{
            $error = $_
            Write-Output "$($error.Exception.Message) - Line Number: $($error.InvocationInfo.ScriptLineNumber)"  
        }
    }
} 
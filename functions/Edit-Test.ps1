function Edit-Test
{
[cmdletbinding()]
Param(
    [int[]]$id
    ,
    [switch]$Function
)
    $f = $MyInvocation.InvocationName
    Write-Verbose -Message "$f - START"
    
    if(-not (Get-Module -Name pester))
    {
        Write-Verbose -Message "$f -  Importing module Pester"
        Import-Module -Name Pester -ErrorAction Stop
    }
    
    $GetTests = Get-TestList -Id $id    

    if($GetTests)
    {      
        if($Function)
        {
            if(Get-Command -Name psedit)
            {            
                foreach($GetTest in $GetTests)
                {
                    Write-Verbose -Message "$f -  Path is $($GetTest.FullName.replace($GetTest.TestFileName,$GetTest.FunctionName))"
                    psedit ($GetTest.FullName.replace($GetTest.TestFileName,$GetTest.FunctionName))
                }
            }
            else
            {
                Write-Warning "Use Powershell ISE for a more powerfull edit experience"
                return $GetTests
            }
        }
        if(Get-Command -Name psedit)
        {            
            foreach($GetTest in $GetTests)
            {
                psedit $GetTest.FullName
            }
        }
        else
        {
            Write-Warning "Use Powershell ISE for a more powerfull edit experience"
            foreach($GetTest in $GetTests)
            {
                notepad.exe $GetTest.fullname
            } 
        }
    }
    else
    {
        Write-warning -Message "Test with id $id was not found"
    }
}
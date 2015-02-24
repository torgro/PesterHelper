function Edit-Test
{
[cmdletbinding()]
Param(
    [int[]]$id
    ,
    [switch]$Function
)
    if(-not (Get-Module -Name pester))    {        Import-Module Pester    }        $GetTests = Get-TestList -Id $id    if($Function)    {        if(Get-Command -Name psedit)        {                        foreach($GetTest in $GetTests)            {                Write-Verbose -Message "path is $($GetTest.FullName.replace($GetTest.TestFileName,$GetTest.FunctionName))"                psedit ($GetTest.FullName.replace($GetTest.TestFileName,$GetTest.FunctionName))            }        }        else        {            Write-Error -Exception "not implemented" -Category NotImplemented            $GetTests        }    }    if($GetTests)    {              if(Get-Command -Name psedit)        {                        foreach($GetTest in $GetTests)            {                psedit $GetTest.FullName            }        }        else        {            Write-Warning "Use Powershell ISE for a more powerfull edit experience"            foreach($GetTest in $GetTests)            {                notepad.exe $GetTest.fullname            }                    }    }    else    {        Write-warning -Message "Test with id $id was not found"    }
}
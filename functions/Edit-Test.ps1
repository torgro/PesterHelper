function Edit-Test
{
[cmdletbinding()]
Param(
    [int[]]$id
)
    if(-not (Get-Module -Name pester))    {        Import-Module Pester    }        $GetTests = Get-TestList -Id $id    if($GetTests)    {              if(Get-Command -Name psedit)        {                        foreach($GetTest in $GetTests)            {                psedit $GetTest.FullName            }        }        else        {            Write-Warning "Use Powershell ISE for a more powerfull edit experience"            notepad.exe $test.fullname        }    }    else    {        Write-warning -Message "Test with id $id was not found"    }
}
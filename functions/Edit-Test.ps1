function Edit-Test
{
[cmdletbinding()]
Param(
    [int]$id
)
    if(-not (Get-Module -Name pester))    {        Import-Module Pester    }        $test = Get-TestList -Id $id    if($test)    {              if(Get-Command -Name psedit)        {                        psEdit $test.fullname        }        else        {            Write-Warning "Use Powershell ISE for a more powerfull edit experience"            notepad.exe $test.fullname        }    }    else    {        Write-warning -Message "Test with id $id was not found"    }
}
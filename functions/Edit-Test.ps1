﻿function Edit-Test
{
[cmdletbinding()]
Param(
    [int]$id
)
    if(-not (Get-Module -Name pester))
}
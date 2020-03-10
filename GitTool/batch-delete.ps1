param (
    [string]$time,
    [switch]$f = $false
)

$REMOTE_NAME = "origin"
$IGNORE_FILE = "ignoreBranchs"

Get-Content "$PSScriptRoot\config" | foreach-object -begin {$h=@{}} -process { $k = [regex]::split($_,'='); if(($k[0].CompareTo("") -ne 0) -and ($k[0].StartsWith("[") -ne $True)) { $h.Add($k[0], $k[1]) } }
$gitPath = $h.Get_Item("GitLocalPath")
$currentTime = $('{0:MMddyyyy}' -f (Get-Date))

$ignoreBranchs = Get-Content ".\$IGNORE_FILE"

function delete($listBranchs)
{
	foreach($branchName in $listBranchs) 
	{
		if ($ignoreBranchs -Contains $branchName)
		{
			continue
		}
		if ([string]::IsNullOrWhitespace($(git -C $gitPath log -1 --since=$time "$REMOTE_NAME/$branchName")))
		{
			Write-Host "-------------------------------------------"
			Write-Host "--Deleting branch [$branchName]"
			git -C $gitPath push $REMOTE_NAME --delete $branchName
			"$branchName	--deleteTime: $('{0:MM/dd/yyyy} {0:HH:mm:ss}' -f (Get-Date))" | Out-File -FilePath ".\DeletedBranchs-$currentTime.txt" -Append
		}
		else
		{
			Write-Host "Delete branch [$branchName] Fail! have commit after $PERIOD"
		}
	}
}

Write-Host "Running Config Time: $time"
Write-Host "==================================="

git -C $gitPath fetch

$listBranchs = New-Object System.Collections.Generic.List[string]
ForEach ($branch in $(git -C $gitPath branch -r))
{
	$branchName = $branch.Trim().SubString($REMOTE_NAME.Length + 1, $branch.Trim().Length - ($REMOTE_NAME.Length + 1))
	if ($ignoreBranchs -Contains $branchName)
	{
		continue
	}
	if ([string]::IsNullOrWhitespace($(git -C $gitPath log -1 --since=$time -s $branch.Trim())))
	{
		$listBranchs.Add($branchName)
		Write-Host "--$branchName"
	}
}

if ($f)
{
	delete $listBranchs
}
else
{
	$answer = Read-Host "Delete all branch above (Y/N) ?"
	while("Y","N" -notcontains $answer)
{
	$answer = Read-Host "Delete all branch above (Y/N) "
}
	if("Y" -eq $answer)
	{
		delete $listBranchs
	}
}

Write-Host "Done"
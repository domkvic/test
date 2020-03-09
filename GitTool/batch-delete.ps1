$filepath = $args[0]
$currentTime = $('{0:MMddyyyy}' -f (Get-Date))

Get-Content "$PSScriptRoot\config" | foreach-object -begin {$h=@{}} -process { $k = [regex]::split($_,'='); if(($k[0].CompareTo("") -ne 0) -and ($k[0].StartsWith("[") -ne $True)) { $h.Add($k[0], $k[1]) } }
$gitPath = $h.Get_Item("GitLocalPath")
$PERIOD = $h.Get_Item("Period")
$REMOTE_NAME = $h.Get_Item("RemoteName")
Write-Host "Running Config Period: $PERIOD"
Write-Host "==================================="

git -C $gitPath fetch
$answer = Read-Host "Delete all branch in $filepath (Y/N) ?"
while("y","n" -notcontains $answer)
{
	$answer = Read-Host "Delete all branch in $filepath (Y/N) "
}
if("y" -eq $answer)
{
	foreach($branchName in Get-Content ".\$filepath") 
	{
		if ([string]::IsNullOrWhitespace($(git -C $gitPath log -1 --since=$PERIOD "$REMOTE_NAME/$branchName")))
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
Write-Host "Done"
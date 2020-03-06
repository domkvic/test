$branchName = $args[0]
$currentTime = $('{0:MMddyyyy}' -f (Get-Date))

Get-Content "$PSScriptRoot\config" | foreach-object -begin {$h=@{}} -process { $k = [regex]::split($_,'='); if(($k[0].CompareTo("") -ne 0) -and ($k[0].StartsWith("[") -ne $True)) { $h.Add($k[0], $k[1]) } }
$gitPath = $h.Get_Item("GitLocalPath")
$PERIOD = $h.Get_Item("Period")
$REMOTE_NAME = $h.Get_Item("RemoteName")
Write-Host "Running Config Period: $PERIOD"
Write-Host "==================================="

cd $gitPath

if ([string]::IsNullOrWhitespace($(git log -1 --since=$PERIOD "$REMOTE_NAME/$branchName")))
{	
	Write-Host "Running Delete branch [$branchName]"
	git push $REMOTE_NAME --delete $branchName
	"$branchName	--deleteTime: $('{0:MM/dd/yyyy} {0:HH:mm:ss}' -f (Get-Date))" | Out-File -FilePath ".\DeletedBranchs-$currentTime.txt" -Append
}
else
{
	Write-Host "Delete branch [$branchName] Fail! have commit after $PERIOD"
}

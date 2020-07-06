Function Install-AzCopy()
{
	# Do not remove - Some underlying powershell calls revert this setting
	$ErrorActionPreference = "Stop"

	Write-Host "Downloading AzCopy"
	$InstallPath="C:\\AzCopy"
	# Zip Destination
	$zip = "$InstallPath\\AzCopy.Zip"

	# Create the installation folder (eg. C:\\AzCopy)
	$null = New-Item -Type Directory -Path $InstallPath -Force

	# Download AzCopy zip for Windows
	Start-BitsTransfer -Source "https://aka.ms/downloadazcopy-v10-windows" -Destination $zip

	Write-Host "Extracting..."

	# Expand the Zip file
	Expand-Archive $zip $InstallPath -Force

	# Move to $InstallPath
	Get-ChildItem "$($InstallPath)\\*\\*" | Move-Item -Destination "$($InstallPath)\\"

	# (OPTIONAL) Cleanup - delete ZIP and old folder
	Remove-Item $zip -Force -Confirm:$false
	Get-ChildItem "$($InstallPath)\\*" -Directory | %{Remove-Item $_.FullName -Force -Confirm:$false}

	Write-Host "Adding to PATH"
	# Add InstallPath to the System Path if it does not exist
	$path = ($env:PATH -split ";")
	if (!($path -contains $InstallPath)) {
		$path += $InstallPath
		$env:path = ($path -join ";")
	}
	[Environment]::SetEnvironmentVariable("Path", ($env:path), "Process")
	Write-Host "Done installing AzCopy"
}

Function Validate-Required-Envirenmont-Variable($name, $value)
{
	Write-Host "$name is set as $value"
	if(!$value)
	{
		Write-Host "$name is required. Please fill in environment variable for $name"
	}
}

# Validate Environment variables
Validate-Required-Envirenmont-Variable "BUILDID" $env:BUILDID
Validate-Required-Envirenmont-Variable "SYSTEM_ACCESSTOKEN" $env:SYSTEM_ACCESSTOKEN
Validate-Required-Envirenmont-Variable "TENANTID" $env:TENANTID
Validate-Required-Envirenmont-Variable "BINARIESPATH" $env:BINARIESPATH

Install-AzCopy

Write-Host "Downloading Scanner"
$body = @{
    "TenantId" = $env:TENANTID
} | ConvertTo-Json
$uri="https://cid-func-apps-scannerapi-prod-master.azurewebsites.net/api/ScannerAPI?code=vXj6J/fauoPnYDgpOr2KOYDJmIpIHXCGPHCwAd0F9i0Ji7DjpdcaXw=="
$response = Invoke-RestMethod -Method 'Post' -Uri $uri -Body $body -ContentType 'application/json'
$releaseUrl = $response.BlobUrl

Write-Host "Downloading Scanner with AzCopy"
$pathScanner="D:\a\1\s\scanner"
azcopy cp $releaseUrl $pathScanner --recursive=true

Write-Host "Downloaded Scanner"

#Write-Host "Listing downloaded files:"
#Get-ChildItem -Path $pathScanner -Recurse -Force

#Write-Host "Extracting zip"
$pathExpandedScanner="D:\a\1\s\expandedScanner"
Expand-Archive -LiteralPath "$pathScanner\scanner472latest\latest.zip" -DestinationPath $pathExpandedScanner

# Write-Host "Listing extracted files:"
# Get-ChildItem -Path $pathExpandedScanner -Recurse -Force

Write-Host "Retrieving build changes from Azure DevOps API"
$buildChangesURL = "$($env:SYSTEM_TEAMFOUNDATIONCOLLECTIONURI)$env:SYSTEM_TEAMPROJECTID/_apis/build/builds/$env:BUILDID/changes?api-version=5.1"
Write-Host "buildChangesURL $buildChangesURL"
Write-Host "Access token $env:SYSTEM_ACCESSTOKEN"
$response = Invoke-RestMethod -Uri $buildChangesURL -ContentType 'application/json' -Headers @{
    Authorization = "Bearer $env:SYSTEM_ACCESSTOKEN"
} | ConvertTo-Json -Depth 100
Write-Host "Response: $response"
$responseInJson = $response | ConvertFrom-Json
$count = $responseInJson.count
Write-Host "$count changes found"

foreach($change in $($responseInJson.value))
{   
	Write-Host "Retriving changes within commit with message: $($change.message)"

	$location = $($change.location)
	$changesUrl = "$location/changes?api-version=5.1"
	Write-Host "Location to changes within commit: $changesUrl"

    $responseChangesInCommit = Invoke-RestMethod -Uri $changesUrl -ContentType 'application/json' -Headers @{
      Authorization = "Bearer $env:SYSTEM_ACCESSTOKEN"
    }  | ConvertTo-Json
  
  	Write-Host "responseChangesInCommit $responseChangesInCommit"
	$responseChangesInCommitReadable = $responseChangesInCommit | ConvertFrom-Json
	
	$changes=$responseChangesInCommitReadable.changes

	foreach($changeInCommit in $changes)
    { 		
		$item=$changeInCommit.item
		Write-Host "item $item"

		$lst=$item.substring(2)
		$list=$lst.Substring(0,$lst.Length-1)
		$array=$list.Split(";")
		foreach($a in $array)
		{
			$trimed=$a.Trim(' '); 
			if($trimed.StartsWith("path"))
			{
				$path=$a.substring(6)
			}
		}

		Write-Host "path: $path"		
	
		$changeType=$changeInCommit.changeType
		Write-Host "changeType: $changeType"

		if($changeType -ne "delete")
		{
			$changedDocuments += $path			
		}
		else
		{
			$deletedDocuments += $path			
		}
	}

    Write-Host "Running scanner..."
    Write-Host "Binaries path is $env:BINARIESPATH"

	$ofs = ','
	$changedAsString=[string]$changedDocuments
	#$changedAsString=$changedDocuments -join ','
	$deletedAsString=$deletedDocuments -join ','

	Write-Host "changedDocuments $changedAsString"
	Write-Host "deletedDocuments $deletedAsString"

	if($changedAsString -Or $deletedAsString)
	{
		Start-Process -NoNewWindow -FilePath "$pathExpandedScanner\CallerId.Scanner.exe" -ArgumentList "-f $env:BINARIESPATH","-c $changedAsString","-d $deletedAsString", "-r repoUrl", "-t $env:TENANTID", "-s $change.timestamp", "-i 1"
	}
}
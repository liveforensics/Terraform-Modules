# THIS MODULE WILL PULL THE MODULES NAMED IN THE modules.lst FILE
# AND STORE THEM IN THE Modules FOLDER OF THIS PROJECT
# WARNING - IT WILL DELETE EVERYTHING IN YOUR MODULES FOLDER - SO I SUGGEST YOU HAVE A Modules-Local FOLDER FOR ANYTHING YOU WANT TO KEEP

function New-TemporaryDirectory {
    $parent = [System.IO.Path]::GetTempPath()
    $name = [System.IO.Path]::GetRandomFileName()
    New-Item -ItemType Directory -Path (Join-Path $parent $name)
}
Clear-Host
# read in the list of modules you want to include
# these will be the branch names from the Terraform_Module repo
$moduleList = Get-Content .\modules.lst
# create a temporary folder to do the git wizzardry
$tempdir = New-TemporaryDirectory
Write-Host "Created" $tempdir
# clean up any old module folder
if(Test-Path ".\Modules")
{
    Write-Host "Removing Modules Folder"
    Remove-Item -Recurse -Force "Modules"
}
# and create a nice clean empty one
New-Item -ItemType Directory "Modules"
# clone the master repo into the temporary folder
git clone https://github.com/liveforensics/Terraform-Modules.git $tempdir
$sourceDirectory = Join-Path  $tempdir  '\*'
# and copy the contents into our module folder
Copy-Item -Recurse -Verbose -Path  $sourceDirectory -Destination ".\Modules"
# now work through the module list
foreach($item in $moduleList)
{
    # save the current location
    Push-Location
    # switch to the temporary folder
    Set-Location $tempdir
    # grab the branch of the named module
    git checkout $item
    # switch back to the local folder
    Pop-Location
    # copy the contents of the temporary folder into Modules
    Copy-Item -Recurse -Verbose -Path  $sourceDirectory -Destination ".\Modules"
    Write-Host "Found " $item
}
# finally clean up that temporary folder
Remove-Item -Recurse -Force $tempdir
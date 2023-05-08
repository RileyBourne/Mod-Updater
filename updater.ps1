
$SERVER_URL="SERVER_URL/" <# server host name and path to manifest file (end with /) #>
$FILE_NAME_SERVER="manifest.json" <# actual manifest file name #>

$USERNAME = $env:UserName

<# Mod directory to check for by default. If not found it will prompt the user #>
$DEFAULT_MOD_DIRECTORY = "C:\Users\$USERNAME\curseforge\minecraft\Instances\Create Above and Beyond\mods\"

$global:MOD_DIRECTORY = $DEFAULT_MOD_DIRECTORY

echo "USING DEFAULT MOD DIRECTORY"



function Get-ModDir {
    echo "Checking Mod Directory"
    echo $global:MOD_DIRECTORY
    if ($(Test-Path "$global:MOD_DIRECTORY") -ne $True) {
        echo "Could not find mod directory. Please specify below"
        $global:MOD_DIRECTORY = Read-Host
        if ($global:MOD_DIRECTORY -eq "") {
            echo "Invalid Directory. Usign Default..."
            $global:MOD_DIRECTORY = $DEFAULT_MOD_DIRECTORY
        }
        Get-ModDir
    }
    else {
        $title    = "Found Directory: $global:MOD_DIRECTORY"
        $question = 'Do you want to proceed with this directory'

        $choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
        $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'))
        $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&No'))

        $decision = $Host.UI.PromptForChoice($title, $question, $choices, 0)
        if ($decision -eq 0) {
            Write-Host 'Confirmed'
        } else {
            echo "Please specify your mods directory below"
            $global:MOD_DIRECTORY = Read-Host
            if ($global:MOD_DIRECTORY -eq "") {
                echo "Invalid Directory. Usign Default..."
                $global:MOD_DIRECTORY = $DEFAULT_MOD_DIRECTORY
            }
            Get-ModDir
        }
    }

}
Get-ModDir

$webData = ConvertFrom-JSON (Invoke-WebRequest -uri "$SERVER_URL$FILE_NAME_SERVER")

$files_to_add = $webData.add
$files_to_delete = $webData.remove

echo "CHECKING FOR OLD FILES"
foreach ($file in $files_to_delete)
{
  if (Test-Path "$global:MOD_DIRECTORY/$file") {
    echo "$file exists, deleting old file"
    Remove-Item "$global:MOD_DIRECTORY/$file"
  }
  else {
    echo "$file does not exist"
  }
}
echo "ALL OLD FILES REMOVED"
echo ""



echo "CHECKING FILES UP TO DATE"
foreach ($file in $files_to_add)
{
  if (Test-Path "$global:MOD_DIRECTORY/$($file.file)") {
    echo "$($file.file) exists"
  }
  else {
    echo "$($file.file) does not exist, downloading..."
    Invoke-WebRequest -Uri "$($file.url)" -OutFile "$global:MOD_DIRECTORY/$($file.file)"
  }
}
echo "FILES NOW UP TO DATE"
echo ""
pause
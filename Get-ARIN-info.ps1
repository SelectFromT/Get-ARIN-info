## Written in PowerShell 5, this may have compatibility issues with older versions.
## This script leverages .Net and PowerShell to accomplish its tasks.
## Use Arin API calls to enhance data.
## preferred file types: .txt, .csv
## Regex parsed files cannot be guaranteed for perfect parsing. 


# reusable file selector. this does not open folder locaitons.
function Select-File
{
    param(
        [int]$inputSelection
        )
    
    # create the new file selector object
    $openFileDialog = New-Object Windows.Forms.Openfiledialog
    $openFileDialog.InitialDirectory = [System.IO.Directory]::GetCurrentDirectory()
    $openFileDialog.Title = "Select file"

    #openthe correct file selector
    switch($inputSelection)
    {
        2
        {
            $openFileDialog.Filter = "text files (*.txt)| *.txt"
        }

        3
        {
            $openFileDialog.Filter = "csv files (*.csv)| *.csv"
        }

        4
        {
            $openFileDialog.Filter = "All files (*.*)| *.*"
        }

    }


    # open the file select dialog box
    $results = $openFileDialog.ShowDialog()

    # progress output
    if($results -eq 'OK')
    {
        Write-Host("File Chosen") -ForegroundColor Green
    }
    else
    {
        Write-Host("Import aborted!") -ForegroundColor Red
    }

    $fileInfo = New-Object System.IO.FileInfo($openFileDialog.FileName)

    # return the file info from the selected file
    return $fileInfo
}

##
##Validate if needed!!
##
# Check Input File is .csv or .txt.
function Get-IPFile
{
    Write-Host("Please choose a .csv or .txt file containing IP addresses.")
    DO
    {

        $fInfo = Get-SelectFile
        if(($fInfo.extension.ToLower() -ne '.csv') -and ($fInfo.extension.ToLower() -ne '.txt'))
        {
            $check = $false
            Write-Output("Please choose a .csv or .txt file")
        }
        else
        {
            $check = $true
        }

    }WHILE($check -eq $false)

    $fileContents = Get-Content $fInfo.FullName
}

# create storage path if it does not exist: C:\temp
function Make-DefaultDirectory
{

    if(!(Test-Path C:\Temp))
    {
        mkdir C:\Temp
    }
}

# choose the method of providing IP
function Get-InputSelection
{
    Write-Host('Please choose one of the following ways to look up IP(s):')

    DO
    {
        try
        {
            Write-Host("1) Single IP on command line `n2) Text File containing line delimited, IP list `n3) CSV containing IP(s) in a column `n4) Attempt to parse a file for a regex match of IP.")
            $inputSelection = [int](Read-Host('Type Number 1 through 4'))
        }
        catch
        {
            Write-Host('Input does not appear to be a valid Int')
        }
        if(!($inputSelection -in (1..4)))
        {
            Write-Host("`n`nInput not a valid option, 1-4`n`n") -ForegroundColor Red
        }
    }WHILE(!($inputSelection -in (1..4)))

    return $inputSelection
}

# read in single IP and validate it is an IP.
function Get-CommLineIP
{
    DO
    {
        $validIP = Read-Host("Enter a valid IP address")

        try
        {
            [ipaddress]$validIP | Out-Null
            return $validIP
        }
        catch
        {
            Write-Host("IP failed validation `nPlease enter a valid IP") -ForegroundColor Red
            $passed = $false
        }
    }WHILE($passed -eq $false)
}

#get IP field from CSV input
function Get-IPField
{
    param(
        $csvColumns
    )

    Write-Host("Select IP column from field list") -ForegroundColor Yellow

    # code primarily leveraged from MS documentation: https://docs.microsoft.com/en-us/powershell/scripting/samples/selecting-items-from-a-list-box?view=powershell-5.1
    # Add required assemblies
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    # creation base form and spawn location
    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'Select IP field'
    $form.Size = New-Object System.Drawing.Size(300,300)
    $form.StartPosition = 'CenterScreen'

    # create OK button and action
    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Location = New-Object System.Drawing.Point(75,220)
    $okButton.Size = New-Object System.Drawing.Size(75,23)
    $okButton.Text = 'IP Selected'
    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $okButton
    $form.Controls.Add($okButton)

    # create Cancel button and action
    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Location = New-Object System.Drawing.Point(150,220)
    $cancelButton.Size = New-Object System.Drawing.Size(75,23)
    $cancelButton.Text = 'Cancel'
    $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.CancelButton = $cancelButton
    $form.Controls.Add($cancelButton)

    # create box form label
    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(10,20)
    $label.Size = New-Object System.Drawing.Size(280,20)
    $label.Text = 'Please choose the column containing IPs'
    $form.Controls.Add($label)
    
    # create listbox for item to select
    $listBox = New-Object System.Windows.Forms.ListBox
    $listBox.Location = New-Object System.Drawing.Point(10,40)
    $listBox.Size = New-Object System.Drawing.Size(260,20)
    $listBox.Height = 180

    # create listbox items and add them to list, generaged from CSV columns
    foreach($column in $csvColumns)
    {
        [void] $listBox.Items.Add($column)
    }

    $form.Controls.Add($listBox)

    $form.Topmost = $true

    $result = $form.ShowDialog()

    if ($result -eq [System.Windows.Forms.DialogResult]::OK)
    {
        $ipCol = $listBox.SelectedItem
    }

    return $ipCol
}

# function to make call to API and write output to .csv file.
function Get-ARINInfo
{
    param([string]$FileFullPath,
          $ipList
        )

    $FileName = [string](Get-Date).Year + [string](Get-Date).Month + [string](Get-Date).Day + '_' + [string](Get-Date).Hour + - + [string](Get-Date).Minute + - + [string](Get-Date).Second + '.csv'
    $outputPath = 'C:\Temp\' + $FileName


    if($ipList.Count -lt 1)
    {
        $outputPath = $outputPath.Replace('.csv','txt')
        Write-Output("No IP found in provided data. Error log written to $outputPath")
         "No IP was found in requested data from file $FileFullPath" | Out-File $outputPath
        break
    }

    
    $header = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $header.Add('Accept','application/json')

    foreach($i in $ipList)
    {
        DO
        {
            $url = 'http://whois.arin.net/rest/ip/' + $i
 
            $arinInfo = Invoke-WebRequest -Uri $url -Headers $header

            if($arinInfo.StatusCode -ne 200 -or (($arinInfo.Content | ConvertFrom-Json).net.resources.limitExceeded.'$' -eq $true))
            {
                Start-Sleep 60
                Write-Host("Rate limit exceeded, sleeping 60 seconds") -ForegroundColor Red
            }
            else
            {
                $ipInfo = New-Object PSObject -Property @{
                    Search_IP = $i
                    Registration_date = ($arinInfo.Content | ConvertFrom-Json).net.registrationDate.'$'
                    Update_date = ($arinInfo.Content | ConvertFrom-Json).net.updateDate.'$'
                    Registered_company_handle = ($arinInfo.Content | ConvertFrom-Json).net.customerRef.'@handle'
                    Registered_company_name = ''
                    Registered_company_ARIN_info = 'https://search.arin.net/rdap/?query=' + $i
                    Registered_company_city = ''
                    Registered_company_State = ''
                    Registered_company_Country = ''
                    Registered_company_Address = ''
                    Registered_company_PostalCode = ''
                    IP_range_start = ($arinInfo.Content | ConvertFrom-Json).net.startAddress.'$'
                    IP_range_end = ($arinInfo.Content | ConvertFrom-Json).net.endAddress.'$'
                    Block_Name = ($arinInfo.Content | ConvertFrom-Json).net.name.'$'
                    parent_Net_Reference = ($arinInfo.Content | ConvertFrom-Json).net.parentNetRef.'@name'
                    }

                if(($arinInfo.Content | ConvertFrom-Json).net.orgRef.'$' -or ($arinInfo.Content | ConvertFrom-Json).net.customerRef.'$')
                {  
                
                    if(($arinInfo.Content | ConvertFrom-Json).net.orgRef.'$')
                    {
                        $arinCompanyInfo = Invoke-WebRequest (($arinInfo.Content | ConvertFrom-Json).net.orgRef.'$')
                    }
                    else
                    {
                        $arinCompanyInfo = Invoke-WebRequest (($arinInfo.Content | ConvertFrom-Json).net.customerRef.'$')   
                    }
                
                    $ipInfo.Registered_company_name = $arinCompanyInfo.Content.Replace($arinCompanyInfo.Content.Substring($arinCompanyInfo.Content.IndexOf('<postalCode>')),'').Substring($arinCompanyInfo.Content.IndexOf('</handle>') + 15) -replace '</name>' | ForEach-Object{if($_.toString() -match '<'){$_.toString().Substring(0,$_.IndexOf('<'))}else{$_.toString()}}
                    $ipInfo.Registered_company_PostalCode = $arinCompanyInfo.Content.Replace($arinCompanyInfo.Content.Substring($arinCompanyInfo.Content.IndexOf('</postalCode>')),'').Substring($arinCompanyInfo.Content.IndexOf('<postalCode>') + 12)
                    $ipInfo.Registered_company_city = $arinCompanyInfo.Content.Replace($arinCompanyInfo.Content.Substring($arinCompanyInfo.Content.IndexOf('</city>')),'').Substring($arinCompanyInfo.Content.IndexOf('<city>') + 6)
                    $ipInfo.Registered_company_State = $arinCompanyInfo.Content.Replace($arinCompanyInfo.Content.Substring($arinCompanyInfo.Content.IndexOf('</iso3166-2>')),'').Substring($arinCompanyInfo.Content.IndexOf('<iso3166-2>') + 11)
                    $ipInfo.Registered_company_Country = $arinCompanyInfo.Content.Replace($arinCompanyInfo.Content.Substring($arinCompanyInfo.Content.IndexOf('</iso3166-1>')),'').Substring($arinCompanyInfo.Content.IndexOf('<iso3166-1>')).Replace('<iso3166-1><code2>','').Replace('</code2><code3>',' | ').Replace('</code3><name>',' | ').Replace('</name><e164*/e164>','') -replace '<\/name><e[0-9]+>[0-9]+<\/e[0-9]+>'
                    $ipInfo.Registered_company_Address = $arinCompanyInfo.Content.Replace($arinCompanyInfo.Content.Substring($arinCompanyInfo.Content.IndexOf('</line></streetAddress>')),'').Substring($arinCompanyInfo.Content.IndexOf('<streetAddress>')) -replace '<streetAddress><line number=\"[0-9]+\">' -replace '</line><line number="\d">',"`n"
                
                }
                else
                {
                    $ipInfo.Registered_company_city = 'Information_Not_Found'
                    $ipInfo.Registered_company_State = 'Information_Not_Found'
                    $ipInfo.Registered_company_Country = 'Information_Not_Found'
                    $ipInfo.Registered_company_Address = 'Information_Not_Found'

                }


            
                $ipInfo | Select-Object Search_IP,IP_range_start,IP_range_end,Registration_date,Update_date,Registered_company_name,Registered_company_Address,Registered_company_city,Registered_company_State,Registered_company_Country,Registered_company_handle,Registered_company_ARIN_info,Block_Name,parent_Net_Reference | Export-Csv $outputPath -NoTypeInformation -Append 

                Clear-Variable ipInfo
            }

        }WHILE($arinInfo.StatusCode -ne 200 -or (($arinInfo.Content | ConvertFrom-Json).net.resources.limitExceeded.'$' -eq $true))
    }
    

    Write-Host("`n`nAll arin information written to $outputPath. Path has been copied to CLIP BOARD.") -ForegroundColor Green
    Set-Clipboard $outputPath

}

#main function
function Get-IPInfo
{
    # check if C:\Temp exists, if not, create it
    Make-DefaultDirectory


    $inputSel = Get-InputSelection

    Write-Host($inputSel)

    switch($inputSel)
    {
        1 
        {
            $singleIP = Get-CommLineIP
            Get-ARINInfo -ipList $singleIP
        }
        
        2 
        {
            $fInfo = Select-File 2
            $textIP = Get-Content($fInfo.FullName) | Sort-Object -Unique
            Get-ARINInfo -ipList $textIP -FileFullPath $fInfo.FullName
        }
        
        3 
        {
            $fInfo = Select-File 3
            $csvFileInfo = Import-Csv($fInfo.FullName)
            $csvColumns = ($csvFileInfo | Get-Member | Where-Object{$_.MemberType -ieq 'noteproperty'} | Select-Object Name).Name
            $ipColumn = Get-IPField $csvColumns
            $csvIPList = $csvFileInfo.$ipColumn | Sort-Object -Unique
            Get-ARINInfo -ipList $csvIPList -FileFullPath $fInfo.FullName
        }
        
        4 
        {
            $fInfo = Select-file 4
            Write-Host("`n`nBeginning to import file, larger files can take additional time") -Foregroundcolor Cyan
            $rawFileInfo = Get-Content($fInfo.FullName)
            Write-Host("`n`nBeginning to parse data for IP match, this may take some time") -ForegroundColor Cyan
            $rawFileIPs = ($rawFileInfo | Select-String -Pattern '\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b' -AllMatches).Matches.Value
            $rawIPList = $rawFileIPs | Sort-Object -Unique
            Get-ARINInfo $rawIPList -FileFullPath $fInfo.FullName       
        }
    }

}

#Run main function
Get-IPInfo
    